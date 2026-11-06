#!/bin/bash
set -e

STORAGE="${PLUGIN_STORAGE_LOCAL_ROOT:-/app/storage}"
START='/app/commandline migrate && exec /app/main'

# Railway mounts the volume as root. Hand it to the user the daemon actually
# runs as, before dropping privileges.
mkdir -p "$STORAGE"
chown -R dify:dify "$STORAGE" 2>/dev/null || true

# Drop to the dify user with whatever this image provides. If none of these
# exist, run as root rather than refusing to start -- a running daemon with the
# wrong uid is better than a Dify with no model providers at all.
if command -v setpriv >/dev/null 2>&1; then
  exec setpriv --reuid=dify --regid=dify --init-groups /bin/bash -c "$START"
elif command -v gosu >/dev/null 2>&1; then
  exec gosu dify /bin/bash -c "$START"
elif command -v su-exec >/dev/null 2>&1; then
  exec su-exec dify /bin/bash -c "$START"
elif command -v su >/dev/null 2>&1; then
  exec su dify -s /bin/bash -c "$START"
else
  echo "No way to drop privileges found; running as root." >&2
  exec /bin/bash -c "$START"
fi
