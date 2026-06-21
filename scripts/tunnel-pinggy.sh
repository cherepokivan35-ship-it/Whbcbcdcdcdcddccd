#!/usr/bin/env bash
set -euo pipefail

LOCAL_PORT="${1:-4242}"
REMOTE_SPEC="0:localhost:${LOCAL_PORT}"

echo "Starting a free temporary Pinggy TCP tunnel to localhost:${LOCAL_PORT}"
echo "Keep this terminal open. Copy the host and port printed by Pinggy into client-config-example."
exec ssh -p 443 -o ServerAliveInterval=30 -o ExitOnForwardFailure=yes -R "${REMOTE_SPEC}" tcp@a.pinggy.io
