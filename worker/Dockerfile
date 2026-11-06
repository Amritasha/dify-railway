FROM langgenius/dify-api:1.19.0

# Same image as the API, different MODE. The worker runs indexing, document
# extraction, scheduled workflows and mail; without it, uploading a document to
# a knowledge base appears to work and then never finishes embedding.
ENV MODE=worker

# Migrations belong to the API service alone. Two containers running them at
# once race on the same Alembic version row.
ENV MIGRATION_ENABLED=false
