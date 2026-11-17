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
