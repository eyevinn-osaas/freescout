#!/bin/sh

if [[ ! -z "$OSC_HOSTNAME" ]]; then
  export SITE_URL="https://$OSC_HOSTNAME"
else
  export SITE_URL="http://localhost:8080"
fi

if [[ ! -z "$DB_URL" ]]; then
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

export NGINX_LISTEN_PORT=8080

if [ "$@" ]; then
  exec "$@"
fi

exec /init