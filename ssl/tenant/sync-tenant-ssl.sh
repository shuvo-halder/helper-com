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
