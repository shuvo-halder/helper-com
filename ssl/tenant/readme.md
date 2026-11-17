Niche final version gulo ekshathe dilam, ager conversation er sob fix (port 3001, host fix, CORS, retry logic) shoho. Placeholder gulo (`EMAIL`, `PASSWORD`) apnar value diye bodle nin.

## Step 1: DNS ar ACME webroot

Subdomain tenant er jonno ekbar `*.foodbazaar.fr` A record `103.131.144.58` te rakhun. Custom domain hole tenant nijer A record ei IP te point korbe.

```bash
mkdir -p /var/www/acme
chown -R www-data:www-data /var/www/acme
a2enmod ssl rewrite headers proxy proxy_http proxy_wstunnel
```

`/etc/apache2/sites-available/000-acme-default.conf`

```apache
<VirtualHost *:80>
    ServerName acme-default.foodbazaar.fr
    DocumentRoot /var/www/acme

    <Directory /var/www/acme>
        Require all granted
    </Directory>

    RewriteEngine On
    RewriteCond %{REQUEST_URI} !^/\.well-known/acme-challenge/
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
</VirtualHost>
```

```bash
a2ensite 000-acme-default.conf
apachectl configtest && systemctl reload apache2
```

## Step 2: Database (migration ar limited user)

Laravel migration (ba direct SQL):

```php
Schema::table('restaurants', function (Blueprint $t) {
    $t->string('custom_domain')->nullable()->unique()->after('slug');
    $t->enum('ssl_status', ['pending','active','failed'])->default('pending');
    $t->timestamp('ssl_checked_at')->nullable();
});
```

Limited DB user (notun strong password din, `openssl rand -base64 24` diye generate korun):

```sql
CREATE USER 'sslsync'@'localhost' IDENTIFIED BY 'NEW_STRONG_PASSWORD';
GRANT SELECT (id, slug, custom_domain, status, ssl_status, ssl_checked_at)
  ON foodbazar.restaurants TO 'sslsync'@'localhost';
GRANT UPDATE (ssl_status, ssl_checked_at)
  ON foodbazar.restaurants TO 'sslsync'@'localhost';
FLUSH PRIVILEGES;
```

Jodi user ager thekei ache, password bodlan: `ALTER USER 'sslsync'@'localhost' IDENTIFIED BY 'NEW_STRONG_PASSWORD';`

```bash
cat > /root/.sslsync.cnf <<'EOF'
[client]
user=sslsync
password="NEW_STRONG_PASSWORD"
EOF
chmod 600 /root/.sslsync.cnf

mysql --defaults-extra-file=/root/.sslsync.cnf -N -B foodbazar -e "SELECT id, slug FROM restaurants LIMIT 3"
```

## Step 3: `/opt/tenant/tenant-ssl.sh`

```bash
#!/bin/bash
set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

DOMAIN="${1:-}"
EMAIL="you@yourmail.com"      # apnar email
UPSTREAM_PORT="3001"          # tenant app (restaurant/partner Next.js)

[[ "$DOMAIN" =~ ^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$ ]] || { echo "invalid domain"; exit 1; }

NAME="tenant-${DOMAIN//./-}"
CONF="/etc/apache2/sites-available/${NAME}.conf"

certbot certonly --webroot -w /var/www/acme \
  -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL" --keep-until-expiring

cat > "$CONF" <<EOF
<VirtualHost *:443>
    ServerName ${DOMAIN}

    SSLEngine on
    SSLCertificateFile    /etc/letsencrypt/live/${DOMAIN}/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/${DOMAIN}/privkey.pem

    Header always set Strict-Transport-Security "max-age=31536000"

    ProxyPreserveHost On
    ProxyRequests Off
    ProxyTimeout 120
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"

    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} =websocket [NC]
    RewriteRule /(.*) ws://127.0.0.1:${UPSTREAM_PORT}/\$1 [P,L]

    ProxyPass        / http://127.0.0.1:${UPSTREAM_PORT}/ retry=0
    ProxyPassReverse / http://127.0.0.1:${UPSTREAM_PORT}/

    ErrorLog \${APACHE_LOG_DIR}/${NAME}-error.log
    CustomLog \${APACHE_LOG_DIR}/${NAME}-access.log combined
</VirtualHost>
EOF

a2ensite "${NAME}.conf" >/dev/null
if ! apachectl configtest; then
  a2dissite "${NAME}.conf" >/dev/null
  rm -f "$CONF"
  exit 1
fi
systemctl reload apache2
echo "OK ${DOMAIN}"
```

`X-Forwarded-Proto` ekhane `"https"` dewa hoyeche, karon Step 6 er `proxy.ts` fix ei header theke public URL banay. Jodi tao `EPROTO` error ashe, ei line `"http"` kore `sed -i` diye existing vhost gulo-o bodle din.

## Step 4: `/opt/tenant/sync-tenant-ssl.sh`

```bash
#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

SERVER_IP="103.131.144.58"
BASE="foodbazaar.fr"
DB="foodbazar"
RESERVED=" www api backend partner admin mail ftp acme "
MY="mysql --defaults-extra-file=/root/.sslsync.cnf -N -B $DB"
DOMAIN_RE='^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$'

exec 9>/var/run/sync-tenant-ssl.lock
flock -n 9 || exit 0

ROWS=$($MY -e "
  SELECT id,
         LOWER(COALESCE(NULLIF(custom_domain,''), CONCAT(slug,'.${BASE}'))) AS d,
         COALESCE(NULLIF(custom_domain,''), '-') AS cd,
         slug
  FROM restaurants
  WHERE status = 'running'
    AND slug IS NOT NULL
    AND (ssl_status = 'pending'
         OR (ssl_status = 'failed' AND ssl_checked_at < NOW() - INTERVAL 1 HOUR))
") || exit 1

while IFS=$'\t' read -r id d cd slug; do
  [[ "$id" =~ ^[0-9]+$ ]] || continue
  [[ "$d" =~ $DOMAIN_RE ]] || { echo "$(date) invalid domain id=$id"; continue; }

  if [ "$cd" = "-" ] && [[ "$RESERVED" == *" ${slug} "* ]]; then
    echo "$(date) skip reserved slug $slug"
    continue
  fi

  ip=$(dig +short A "$d" | tail -1)
  if [ "$ip" != "$SERVER_IP" ]; then
    echo "$(date) skip $d dns=$ip"
    continue
  fi

  echo "$(date) adding $d (restaurant $id)"
  if /opt/tenant/tenant-ssl.sh "$d"; then
    $MY -e "UPDATE restaurants SET ssl_status='active', ssl_checked_at=NOW() WHERE id=$id"
  else
    echo "$(date) FAILED $d"
    $MY -e "UPDATE restaurants SET ssl_status='failed', ssl_checked_at=NOW() WHERE id=$id"
  fi
done <<< "$ROWS"
```

```bash
chmod 700 /opt/tenant/*.sh
```

## Step 5: systemd timer ar renewal hook

`/etc/systemd/system/tenant-ssl-sync.service`

```ini
[Unit]
Description=Sync tenant SSL certificates

[Service]
Type=oneshot
ExecStart=/opt/tenant/sync-tenant-ssl.sh
```

`/etc/systemd/system/tenant-ssl-sync.timer`

```ini
[Unit]
Description=Run tenant SSL sync every minute

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min

[Install]
WantedBy=timers.target
```

```bash
systemctl daemon-reload
systemctl enable --now tenant-ssl-sync.timer

cat > /etc/letsencrypt/renewal-hooks/deploy/reload-apache.sh <<'EOF'
#!/bin/bash
systemctl reload apache2
EOF
chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-apache.sh

certbot renew --dry-run
journalctl -u tenant-ssl-sync.service -f
```

## Step 6: Next.js tenant app `src/proxy.ts`

```ts
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { tenantSlugFromHost } from "@/lib/tenant-host";

const PANEL_SHORT_PATHS = ["/", "/menu", "/tables", "/team", "/roles", "/details", "/setup", "/verify-phone", "/orders", "/reservations", "/customers", "/settings", "/inventory", "/transactions", "/reviews", "/offers", "/dashboard", "/activity", "/pos"];

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const hasToken = Boolean(request.cookies.get("fb_token")?.value);
  const rawHost = request.headers.get("x-forwarded-host") ?? request.headers.get("host");
  const slug = tenantSlugFromHost(rawHost);

  const requestHeaders = new Headers(request.headers);
  requestHeaders.set("x-pathname", pathname);

  // URL always public host diye banano (localhost:3001 na)
  const proto = request.headers.get("x-forwarded-proto") ?? "https";
  const publicUrl = (path: string) => {
    const u = request.nextUrl.clone();
    if (rawHost) {
      u.host = rawHost;
      u.protocol = proto;
    }
    u.pathname = path;
    return u;
  };

  if (slug && PANEL_SHORT_PATHS.includes(pathname)) {
    if (!hasToken) return NextResponse.redirect(publicUrl("/login"));
    const target = pathname === "/" ? "/restaurant" : `/restaurant${pathname}`;
    return NextResponse.rewrite(publicUrl(target), { request: { headers: requestHeaders } });
  }

  if (pathname.startsWith("/admin") || pathname.startsWith("/account") || pathname.startsWith("/restaurant")) {
    if (!hasToken) return NextResponse.redirect(publicUrl("/login"));
  }

  return NextResponse.next({ request: { headers: requestHeaders } });
}

// export const config = { matcher: [...] }  // apnar ager matcher hobuhu thakbe
```

Layout e `headers().get("host")` thakle sekhane-o `x-forwarded-host ?? host` use korun. Build:

```bash
cd /var/www/foodbazar-restaurant
pm2 stop foodbazar-restaurant
rm -rf .next
npm run build
pm2 start foodbazar-restaurant
```

## Step 7: Laravel CORS (subdomain + custom domain)

`app/Http/Middleware/TenantCors.php`

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use App\Models\Restaurant;

class TenantCors
{
    public function handle(Request $request, Closure $next)
    {
        $origin  = $request->headers->get('Origin');
        $allowed = $origin && $this->isAllowed($origin);

        $response = ($request->isMethod('OPTIONS') && $allowed)
            ? response('', 204)
            : $next($request);

        if ($allowed) {
            $response->headers->set('Access-Control-Allow-Origin', $origin);
            $response->headers->set('Vary', 'Origin');
            $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
            $response->headers->set('Access-Control-Allow-Headers',
                $request->headers->get('Access-Control-Request-Headers', 'Content-Type, Authorization, Accept'));
            $response->headers->set('Access-Control-Max-Age', '3600');
            // cookie auth hole uncomment korun:
            // $response->headers->set('Access-Control-Allow-Credentials', 'true');
        }

        return $response;
    }

    private function isAllowed(string $origin): bool
    {
        $host   = strtolower((string) parse_url($origin, PHP_URL_HOST));
        $scheme = parse_url($origin, PHP_URL_SCHEME);
        if ($scheme !== 'https' || $host === '') return false;

        if (preg_match('/^([a-z0-9-]+\.)?foodbazaar\.fr$/', $host)) return true;

        return Cache::remember("cors:host:$host", 300, fn () =>
            Restaurant::where('custom_domain', $host)->exists()
        );
    }
}
```

`bootstrap/app.php`:

```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->prepend(\App\Http\Middleware\TenantCors::class);
})
```

`config/cors.php` e built-in CORS bondho rakhun (duplicate header na hoy):

```php
return [
    'paths' => [],
    'allowed_methods' => ['*'],
    'allowed_origins' => [],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

## Step 8: Restaurant create/update validation (Laravel)

Slug ar custom domain validate korun, ar domain bodlale SSL abar pending korun:

```php
use Illuminate\Validation\Rule;

$request->validate([
    'slug' => [
        'required', 'regex:/^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$/',
        Rule::unique('restaurants', 'slug')->ignore($restaurant->id ?? null),
        Rule::notIn(['www','api','backend','partner','admin','mail','ftp','acme']),
    ],
    'custom_domain' => [
        'nullable',
        'regex:/^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$/',
        Rule::unique('restaurants', 'custom_domain')->ignore($restaurant->id ?? null),
    ],
]);

// update er por
if ($restaurant->wasChanged(['custom_domain', 'slug'])) {
    $restaurant->update(['ssl_status' => 'pending']);
}
```

Notun restaurant `status='running'` hole ar DNS thik thakle, 1 minute er moddhe timer cert nebe, vhost banabe ar `ssl_status='active'` korbe.

## Step 9: Existing vhost gulo ekbar sync korun

Port ar proto existing tenant vhost e jodi ekhono vul thake:

```bash
grep -h "ProxyPass \|X-Forwarded-Proto" /etc/apache2/sites-available/tenant-*.conf | sort | uniq -c
# port 3001 er bodole onno kichu thakle:
# sed -i 's/127\.0\.0\.1:3002/127.0.0.1:3001/g' /etc/apache2/sites-available/tenant-*.conf
apachectl configtest && systemctl reload apache2
```

## Step 10: Test

```bash
# manual ekta domain
/opt/tenant/tenant-ssl.sh test.foodbazaar.fr
curl -I https://test.foodbazaar.fr

# CORS preflight
curl -i -X OPTIONS https://backend.foodbazaar.fr/api/auth/login \
  -H "Origin: https://meat-theory.foodbazaar.fr" \
  -H "Access-Control-Request-Method: POST"

journalctl -u tenant-ssl-sync.service --since "10 min ago"
```

Note: "user create" namok kono alada script amra banai nai. Ekhane shudhu `sslsync` DB user (Step 2) ache. Restaurant owner/user toiri Laravel app er nijer registration flow diye hoy. Jodi tenant remove korle vhost ar cert cleanup er script lage (`a2dissite` + `certbot delete`), bolun, likhe dibo.
