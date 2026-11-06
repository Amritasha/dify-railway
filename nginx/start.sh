#!/bin/sh
set -e

: "${PORT:=8080}"
: "${CLIENT_MAX_BODY_SIZE:=100M}"
: "${PROXY_READ_TIMEOUT:=3600}"

for v in API_HOST WEB_HOST PLUGIN_DAEMON_HOST; do
  eval "val=\$$v"
  if [ -z "$val" ]; then
    echo "FATAL: $v is not set. It should be the private domain of that service," >&2
    echo "for example \${{api.RAILWAY_PRIVATE_DOMAIN}}." >&2
    exit 1
  fi
done

: "${API_PORT:=5001}"
: "${WEB_PORT:=3000}"
: "${PLUGIN_DAEMON_PORT:=5002}"

export PORT CLIENT_MAX_BODY_SIZE PROXY_READ_TIMEOUT \
       API_HOST API_PORT WEB_HOST WEB_PORT PLUGIN_DAEMON_HOST PLUGIN_DAEMON_PORT

envsubst '${PORT} ${CLIENT_MAX_BODY_SIZE} ${PROXY_READ_TIMEOUT} ${API_HOST} ${API_PORT} ${WEB_HOST} ${WEB_PORT} ${PLUGIN_DAEMON_HOST} ${PLUGIN_DAEMON_PORT}' \
  < /etc/nginx/templates/dify.conf.template > /etc/nginx/conf.d/dify.conf

echo "Routing: api -> ${API_HOST}:${API_PORT}, web -> ${WEB_HOST}:${WEB_PORT}, plugins -> ${PLUGIN_DAEMON_HOST}:${PLUGIN_DAEMON_PORT}"
nginx -t
exec nginx -g 'daemon off;'
