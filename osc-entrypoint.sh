#!/bin/bash

if [ -n "$OSC_HOSTNAME" ]; then
  export APP_URL="https://$OSC_HOSTNAME"
else
  export APP_URL="http://localhost:8080"
fi
# Kept for compatibility with the tiredofit 1.x image
export SITE_URL="$APP_URL"

if [ -n "$DB_URL" ]; then
  # Extract components from DB_URL
  # Format: mysql://user:password@host:port/database
  export DB_TYPE="mysql"
  export DB_USER=$(echo "$DB_URL" | sed 's|mysql://||' | sed 's|:.*||')
  export DB_PASS=$(echo "$DB_URL" | sed 's|mysql://[^:]*:||' | sed 's|@.*||')
  export DB_HOST=$(echo "$DB_URL" | sed 's|mysql://[^@]*@||' | sed 's|:[0-9]*.*||')
  export DB_PORT=$(echo "$DB_URL" | sed 's|.*:||' | sed 's|/.*||')
  export DB_NAME=$(echo "$DB_URL" | sed 's|.*/||')
else
  echo "DB_URL is not set. Please set it to your database connection string."
  exit 1
fi

export NGINX_LISTEN_PORT="${PORT:-8080}"

# nfrastack 2.x keeps the config at /data/config/config; tiredofit 1.x stored
# it as the plain file /data/config. Migrate an existing volume in place.
DATA_DIR="${DATA_PATH:-/data}"
if [ -f "$DATA_DIR/config" ]; then
  mv "$DATA_DIR/config" "$DATA_DIR/config.bak" \
    && mkdir -p "$DATA_DIR/config" \
    && mv "$DATA_DIR/config.bak" "$DATA_DIR/config/config"
fi

if [ $# -gt 0 ]; then
  exec "$@"
fi

exec /init
