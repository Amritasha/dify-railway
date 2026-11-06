# Dify needs two things from Postgres that the stock image does not give you:
#   1. the pgvector extension, so the knowledge base can live in the same database
#   2. a second database for the plugin daemon, which keeps its own schema
FROM pgvector/pgvector:pg16

COPY init-dify.sh /docker-entrypoint-initdb.d/10-init-dify.sh
