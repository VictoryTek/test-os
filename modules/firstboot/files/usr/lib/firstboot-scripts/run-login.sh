#!/usr/bin/env bash
set -euo pipefail

STAMP="$HOME/.firstboot-login-done"
BOOT_RESULTS_FILE="/var/lib/firstboot-boot-results"
SYSTEM_SCRIPT_DIR="/usr/lib/firstboot-scripts/login/system"
USER_SCRIPT_DIR="/usr/lib/firstboot-scripts/login/user"

if [[ -f "$STAMP" ]]; then
    echo "First login tasks already completed for $(whoami)."
    exit 0
fi

echo "Running first login tasks for $(whoami)..."

FAILED_SCRIPTS=()
SUCCESS_COUNT=0
TOTAL_SCRIPTS=0

# Read boot script results
BOOT_SUCCESS=0
BOOT_TOTAL=0
BOOT_FAILED_SCRIPTS=()

if [[ -f "$BOOT_RESULTS_FILE" ]]; then
    while IFS='=' read -r key value; do
        case "$key" in
            TOTAL) BOOT_TOTAL="$value" ;;
            SUCCESS) BOOT_SUCCESS="$value" ;;
            FAILED_SCRIPT) BOOT_FAILED_SCRIPTS+=("$value") ;;
        esac
    done < "$BOOT_RESULTS_FILE"
fi

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
    if command -v notify-send &> /dev/null; then
        notify-send -u "$urgency" "$title" "$message"
    fi
}

# Run system login scripts (scripts must handle elevation themselves if needed)
if [[ -d "$SYSTEM_SCRIPT_DIR" ]]; then
    echo "Running system login scripts..."
    for script in "$SYSTEM_SCRIPT_DIR"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
            echo "Executing system login script: $script"
            if "$script"; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAILED_SCRIPTS+=("$(basename "$script") (system)")
            fi
        fi
    done
fi

# Run user login scripts as current user
if [[ -d "$USER_SCRIPT_DIR" ]]; then
    echo "Running user login scripts..."
    for script in "$USER_SCRIPT_DIR"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
            echo "Executing user login script: $script"
            if "$script"; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAILED_SCRIPTS+=("$(basename "$script") (user)")
            fi
        fi
    done
fi

touch "$STAMP"

# Combine boot and login results
COMBINED_SUCCESS=$((BOOT_SUCCESS + SUCCESS_COUNT))
COMBINED_TOTAL=$((BOOT_TOTAL + TOTAL_SCRIPTS))
COMBINED_FAILED=()
[[ ${#BOOT_FAILED_SCRIPTS[@]} -gt 0 ]] && COMBINED_FAILED+=("${BOOT_FAILED_SCRIPTS[@]}")
[[ ${#FAILED_SCRIPTS[@]} -gt 0 ]] && COMBINED_FAILED+=("${FAILED_SCRIPTS[@]}")

# Send completion notification
if [[ ${#COMBINED_FAILED[@]} -eq 0 ]]; then
    if [[ $COMBINED_TOTAL -gt 0 ]]; then
        MESSAGE="Successfully completed $COMBINED_SUCCESS firstboot task(s)."
        if [[ $BOOT_TOTAL -gt 0 && $TOTAL_SCRIPTS -gt 0 ]]; then
            MESSAGE+="\n\nBoot: $BOOT_SUCCESS tasks | Login: $SUCCESS_COUNT tasks"
        fi
        send_notification "First Boot Setup Complete" "$MESSAGE" "normal"
    fi
    echo "First login tasks complete for $(whoami)."
else
    MESSAGE="Completed $COMBINED_SUCCESS/$COMBINED_TOTAL tasks."
    if [[ $BOOT_TOTAL -gt 0 ]]; then
        MESSAGE+="\nBoot: $BOOT_SUCCESS/$BOOT_TOTAL tasks"
    fi
    if [[ $TOTAL_SCRIPTS -gt 0 ]]; then
        MESSAGE+="\nLogin: $SUCCESS_COUNT/$TOTAL_SCRIPTS tasks"
    fi
    MESSAGE+="\n\nFailed:\n$(printf '%s\n' "${COMBINED_FAILED[@]}")"
    send_notification "First Boot Setup Issues" "$MESSAGE" "critical"
    echo "First login tasks completed with failures for $(whoami)."
fi

exit 0
