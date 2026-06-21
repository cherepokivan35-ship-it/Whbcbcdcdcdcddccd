#!/bin/sh
set -eu

mkdir -p "$RNS_CONFIG_DIR"

if [ ! -f "$RNS_CONFIG_DIR/config" ]; then
  cp /defaults/config "$RNS_CONFIG_DIR/config"
fi

exec "$@"
