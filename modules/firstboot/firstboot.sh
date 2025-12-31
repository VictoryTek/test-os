#!/usr/bin/env bash
set -euo pipefail

# Parse module configuration from JSON
CONFIG="$1"

echo "Installing firstboot module..."

# Copy infrastructure files from local module
if [[ -d /tmp/modules/firstboot/files/usr ]]; then
    cp -r /tmp/modules/firstboot/files/usr/* /usr/
else
    echo "ERROR: Module files not found at /tmp/modules/firstboot/files/usr"
    exit 1
fi

# Parse and copy scripts based on configuration
SCRIPTS=$(echo "$CONFIG" | jq -r '.scripts[]? | @base64')

for script in $SCRIPTS; do
    _jq() {
        echo "$script" | base64 --decode | jq -r "$1"
    }
    
    NAME=$(_jq '.name')
    MODE=$(_jq '.mode // "system"')
    WHEN=$(_jq '.when // "boot"')
    
    # Determine destination based on mode and when
    DEST_DIR="/usr/lib/firstboot-scripts/${WHEN}/${MODE}"
    mkdir -p "$DEST_DIR"
    
    SOURCE="/tmp/files/firstboot/$NAME"
    if [[ -f "$SOURCE" ]]; then
        echo "Copying $NAME to $DEST_DIR (mode=$MODE, when=$WHEN)"
        cp "$SOURCE" "$DEST_DIR/$NAME"
        chmod +x "$DEST_DIR/$NAME"
    else
        echo "Warning: $SOURCE not found"
    fi
done

echo "Firstboot module installation complete."
