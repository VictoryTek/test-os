#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Preparing for Nix installation"

# Create /nix directory during build when filesystem is writable
# OSTree/composefs doesn't support chattr -i, so we can't create it at runtime
mkdir -p /nix
chmod 0755 /nix

# Download installer for firstboot installation
mkdir -p /usr/share/nix-installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    -o /usr/share/nix-installer/install.sh
chmod +x /usr/share/nix-installer/install.sh

log "========================================"
log "/nix directory created and installer ready"
log "Run 'ujust install-nix' after first boot"
log "========================================"
