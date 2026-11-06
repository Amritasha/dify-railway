#!/bin/bash
# Runs once, on first boot, before Postgres accepts outside connections.
set -e

: "${PLUGIN_DB_NAME:=dify_plugin}"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<SQL
  CREATE EXTENSION IF NOT EXISTS vector;
SQL

# The plugin daemon will not start without its own database.
if ! psql -tAc "SELECT 1 FROM pg_database WHERE datname='${PLUGIN_DB_NAME}'" \
      --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" | grep -q 1; then
  createdb --username "$POSTGRES_USER" "${PLUGIN_DB_NAME}"
fi

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${PLUGIN_DB_NAME}" <<SQL
  CREATE EXTENSION IF NOT EXISTS vector;
SQL

echo "Dify databases ready: ${POSTGRES_DB} (app + vectors), ${PLUGIN_DB_NAME} (plugins)"
