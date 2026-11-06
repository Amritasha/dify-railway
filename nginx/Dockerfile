FROM nginx:1.27-alpine

# gettext gives us envsubst, so the upstream hostnames can come from Railway
# variables instead of being baked into the image.
RUN apk add --no-cache gettext curl

COPY nginx.conf.template /etc/nginx/templates/dify.conf.template
COPY start.sh /start.sh
RUN chmod +x /start.sh && rm -f /etc/nginx/conf.d/default.conf

CMD ["/start.sh"]
