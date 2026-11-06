FROM langgenius/dify-api:1.19.0

# Railway's private network is IPv6-only. Gunicorn's default bind of 0.0.0.0
# leaves the API unreachable from nginx and the plugin daemon, so the whole
# stack comes up green and then 502s. :: binds both families.
# The bracketed form matters: gunicorn builds its bind string as
# "$DIFY_BIND_ADDRESS:$DIFY_PORT", so a bare :: produces ":::5001" and gunicorn
# rejects it with "'' is not a valid port number".
ENV DIFY_BIND_ADDRESS=[::]

EXPOSE 5001
