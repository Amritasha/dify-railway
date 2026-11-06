FROM langgenius/dify-plugin-daemon:0.6.14-local

# Since Dify 1.0 every model provider -- OpenAI, Anthropic, your local gateway --
# is a plugin. This daemon installs and runs them. Without it the model list in
# the console is empty and nothing can be configured, which is the single most
# common way a self-hosted Dify looks broken.
EXPOSE 5002
