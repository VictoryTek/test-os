#!/usr/bin/env bash
set -euo pipefail

STAMP="/var/lib/firstboot-done"
SCRIPT_DIR="/usr/lib/firstboot-scripts/tasks"

if [[ -f "$STAMP" ]]; then
    echo "First boot tasks already completed."
    exit 0
fi

echo "Running first boot tasks..."

if [[ -d "$SCRIPT_DIR" ]]; then
    for script in "$SCRIPT_DIR"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            echo "Executing $script"
            "$script"
        fi
    done
fi

mkdir -p /var/lib
touch "$STAMP"

echo "First boot tasks complete."
exit 0
