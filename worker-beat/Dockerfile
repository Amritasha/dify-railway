FROM langgenius/dify-api:1.19.0

# Celery beat: the scheduler that enqueues Dify's periodic jobs -- workspace
# cleanup, trial expiry, scheduled workflow triggers.
ENV MODE=beat
ENV MIGRATION_ENABLED=false
