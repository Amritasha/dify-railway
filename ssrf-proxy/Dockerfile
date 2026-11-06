# Squid from Alpine's package index rather than ubuntu/squid: that image only
# publishes moving tags, and a proxy that sits in the egress path of every
# workflow is not something you want silently changing version under you.
FROM alpine:3.21

RUN apk add --no-cache squid \
 && mkdir -p /var/cache/squid /var/log/squid \
 && chown -R squid:squid /var/cache/squid /var/log/squid

COPY squid.conf /etc/squid/squid.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3128
CMD ["/start.sh"]
