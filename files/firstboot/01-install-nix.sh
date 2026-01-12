#!/usr/bin/env bash

set -euo pipefail

echo "Running Nix installer on first login..."

# Ensure the tmpfiles.d symlink is created
if [ ! -L /nix ] && [ ! -d /nix ]; then
    echo "Creating /nix symlink to /var/nix..."
    sudo systemd-tmpfiles --create /usr/lib/tmpfiles.d/nix.conf
fi

if [ -f /usr/libexec/nix-installer ]; then
    # Use pkexec for graphical sudo prompt (works in user session)
    pkexec /usr/libexec/nix-installer install linux --init none --no-confirm
    echo "Nix installation completed successfully"
else
    echo "ERROR: Nix installer not found at /usr/libexec/nix-installer"
    exit 1
fi
