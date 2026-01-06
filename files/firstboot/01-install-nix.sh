#!/usr/bin/env bash

set -euo pipefail

echo "Running Nix installer on first login..."

if [ -f /nix/determinate-nix-installer.sh ]; then
    # Run as user with sudo - installer handles the rest
    sudo bash /nix/determinate-nix-installer.sh install --no-confirm
    echo "Nix installation completed successfully"
else
    echo "ERROR: Nix installer not found at /nix/determinate-nix-installer.sh"
    exit 1
fi
