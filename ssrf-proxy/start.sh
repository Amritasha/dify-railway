#!/bin/sh
set -e
: "${PORT:=3128}"
sed -i "s/^http_port .*/http_port ${PORT}/" /etc/squid/squid.conf
squid -k parse
echo "SSRF proxy listening on ${PORT}"
exec squid -N -d1 -f /etc/squid/squid.conf
