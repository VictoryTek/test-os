#!/usr/bin/env bash

# Remove leftover Waydroid desktop entries that are not needed.
# Runs during image build via the script module.

set -oue pipefail

TARGET_DIR="/usr/share/applications"
# List of entries (files or directories) to remove
ITEMS=(
  "Waydroid"
  "Waydroid.desktop"
  "waydroid.app.install.desktop"
  "waydroid.market.desktop"
  "waydroid-container-restart.desktop"
)

echo "::group:: Remove Waydroid desktop entries"

for item in "${ITEMS[@]}"; do
  path="${TARGET_DIR}/${item}"
  if [ -e "$path" ]; then
    echo "Removing $path"
    rm -rf "$path"
  else
    echo "Not present: $path (skipping)"
  fi
done

echo "::endgroup::"
