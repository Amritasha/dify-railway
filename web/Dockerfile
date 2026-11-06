FROM langgenius/dify-web:1.19.0

# Next.js standalone reads HOSTNAME for its bind address; :: is needed for the
# same IPv6 reason as the API.
ENV HOSTNAME=::
ENV PORT=3000

EXPOSE 3000
