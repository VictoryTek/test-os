#!/usr/bin/env bash
set -euo pipefail

STAMP="/var/lib/firstboot-done"
SYSTEM_SCRIPT_DIR="/usr/lib/firstboot-scripts/system"
USER_SCRIPT_DIR="/usr/lib/firstboot-scripts/user"

if [[ -f "$STAMP" ]]; then
    echo "First boot tasks already completed."
    exit 0
fi

echo "Running first boot tasks..."

# Run system scripts as root
if [[ -d "$SYSTEM_SCRIPT_DIR" ]]; then
    echo "Running system scripts..."
    for script in "$SYSTEM_SCRIPT_DIR"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            echo "Executing system script: $script"
            "$script"
        fi
    done
fi

# Run user scripts for each user with UID >= 1000
if [[ -d "$USER_SCRIPT_DIR" ]]; then
    echo "Running user scripts..."
    while IFS=: read -r username _ uid _ _ homedir _; do
        if [[ $uid -ge 1000 && $uid -lt 65534 && -d "$homedir" ]]; then
            echo "Running user scripts for: $username"
            for script in "$USER_SCRIPT_DIR"/*; do
                if [[ -f "$script" && -x "$script" ]]; then
                    echo "Executing user script as $username: $script"
                    su - "$username" -c "$script"
                fi
            done
        fi
    done < /etc/passwd
fi

mkdir -p /var/lib
touch "$STAMP"

echo "First boot tasks complete."
exit 0
