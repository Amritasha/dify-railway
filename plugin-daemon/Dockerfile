FROM langgenius/dify-plugin-daemon:0.6.14-local

# Since Dify 1.0 every model provider -- OpenAI, Anthropic, your local gateway --
# is a plugin, and this daemon installs and runs them. Without it the model list
# in the console is empty, which is the most common way a self-hosted Dify looks
# broken.
#
# The image runs as the unprivileged "dify" user, and a Railway volume mounts
# owned by root. The daemon then cannot create /app/storage/assets and every
# plugin install fails with "permission denied ... failed to save package" --
# after the download has already succeeded, so it looks like a marketplace
# problem rather than a filesystem one. Fix the ownership at boot, as root, then
# drop back to dify before starting anything.
USER root

COPY entrypoint.sh /usr/local/bin/dify-plugin-entrypoint.sh
RUN chmod +x /usr/local/bin/dify-plugin-entrypoint.sh

EXPOSE 5002

ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/usr/local/bin/dify-plugin-entrypoint.sh"]
