#!/usr/bin/env bash

set -euo pipefail

echo "Running Nix installer on first login..."

if [ -f /nix/nix-installer ]; then
    # Use pkexec for graphical sudo prompt (works in user session)
    pkexec /nix/nix-installer install linux --init none --no-confirm
    echo "Nix installation completed successfully"
else
    echo "ERROR: Nix installer not found at /nix/nix-installer"
    exit 1
fi
