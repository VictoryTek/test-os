#!/usr/bin/env bash
set -euo pipefail

STAMP="/var/lib/firstboot-done"
RESULTS_FILE="/var/lib/firstboot-boot-results"
SYSTEM_SCRIPT_DIR="/usr/lib/firstboot-scripts/boot/system"
USER_SCRIPT_DIR="/usr/lib/firstboot-scripts/boot/user"

if [[ -f "$STAMP" ]]; then
    echo "First boot tasks already completed."
    exit 0
fi

echo "Running first boot tasks..."

FAILED_SCRIPTS=()
SUCCESS_COUNT=0
TOTAL_SCRIPTS=0

# Run system scripts as root
if [[ -d "$SYSTEM_SCRIPT_DIR" ]]; then
    echo "Running system scripts..."
    for script in "$SYSTEM_SCRIPT_DIR"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
            echo "Executing system script: $script"
            if "$script"; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAILED_SCRIPTS+=("$(basename "$script") (system boot)")
            fi
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
                    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
                    echo "Executing user script as $username: $script"
                    if su - "$username" -c "$script"; then
                        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
                    else
                        FAILED_SCRIPTS+=("$(basename "$script") (user boot)")
                    fi
                fi
            done
        fi
    done < /etc/passwd
fi

mkdir -p /var/lib
touch "$STAMP"

# Save results for login notification
{
    echo "TOTAL=$TOTAL_SCRIPTS"
    echo "SUCCESS=$SUCCESS_COUNT"
    echo "FAILED=${#FAILED_SCRIPTS[@]}"
    if [[ ${#FAILED_SCRIPTS[@]} -gt 0 ]]; then
        printf 'FAILED_SCRIPT=%s\n' "${FAILED_SCRIPTS[@]}"
    fi
} > "$RESULTS_FILE"
chmod 644 "$RESULTS_FILE"

echo "First boot tasks complete."
exit 0
