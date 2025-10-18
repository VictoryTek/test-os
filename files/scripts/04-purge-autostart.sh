#!/usr/bin/env bash

# Remove leftover Waydroid desktop entries that are not needed.
# Runs during image build via the script module.

set -oue pipefail

# List of directories to check for autostart entries
TARGET_DIRS=(
  "/etc/xdg/autostart"
  "/usr/etc/xdg/autostart"
  "/etc/skel/.config/autostart"
  "/usr/etc/skel/.config/autostart"
)

# List of entries (files or directories) to remove
ITEMS=(
  "steam.desktop"
)

echo "::group:: Remove autostart desktop entries"

for target_dir in "${TARGET_DIRS[@]}"; do
  for item in "${ITEMS[@]}"; do
    path="${target_dir}/${item}"
    if [ -e "$path" ]; then
      echo "Removing $path"
      rm -rf "$path"
    else
      echo "Not present: $path (skipping)"
    fi
  done
done

echo "::endgroup::"
