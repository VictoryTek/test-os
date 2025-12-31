#!/usr/bin/env bash
set -euo pipefail

STAMP="$HOME/.firstboot-login-done"
SYSTEM_SCRIPT_DIR="/usr/lib/firstboot-scripts/login/system"
USER_SCRIPT_DIR="/usr/lib/firstboot-scripts/login/user"

if [[ -f "$STAMP" ]]; then
    echo "First login tasks already completed for $(whoami)."
    exit 0
fi

echo "Running first login tasks for $(whoami)..."

# Run system login scripts (scripts must handle elevation themselves if needed)
if [[ -d "$SYSTEM_SCRIPT_DIR" ]]; then
    echo "Running system login scripts..."
    for script in "$SYSTEM_SCRIPT_DIR"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            echo "Executing system login script: $script"
            "$script"
        fi
    done
fi

# Run user login scripts as current user
if [[ -d "$USER_SCRIPT_DIR" ]]; then
    echo "Running user login scripts..."
    for script in "$USER_SCRIPT_DIR"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            echo "Executing user login script: $script"
            "$script"
        fi
    done
fi

touch "$STAMP"

echo "First login tasks complete for $(whoami)."
exit 0
