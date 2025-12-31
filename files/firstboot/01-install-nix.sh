#!/usr/bin/env bash

set -euo pipefail

echo "Running Nix installer on first boot..."

if [ -f /nix/determinate-nix-installer.sh ]; then
    /nix/determinate-nix-installer.sh install --no-confirm
    echo "Nix installation completed successfully"
else
    echo "ERROR: Nix installer not found at /nix/determinate-nix-installer.sh"
    exit 1
fi
