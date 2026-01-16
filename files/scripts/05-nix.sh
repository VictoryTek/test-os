#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Downloading Nix installer for firstboot installation"

# Download installer for manual installation after first boot
# Container builds don't have systemd, so ostree planner cannot run
mkdir -p /usr/share/nix-installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    -o /usr/share/nix-installer/install.sh
chmod +x /usr/share/nix-installer/install.sh

log "========================================"
log "Nix installer ready at /usr/share/nix-installer/install.sh"
log "Run 'ujust install-nix' after first boot"
log "========================================"
