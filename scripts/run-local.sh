#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${RNS_CONFIG_DIR:-$PWD/.reticulum}"
mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_DIR/config" ]; then
  cp "$(dirname "$0")/../reticulum/config" "$CONFIG_DIR/config"
  echo "Created $CONFIG_DIR/config"
fi

exec rnsd --config "$CONFIG_DIR" -v
