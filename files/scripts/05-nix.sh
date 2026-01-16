#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Installing Determinate Nix (ostree planner)"

# Use ostree planner which creates proper systemd units for immutable systems
# It will create nix-directory.service, nix.mount, and ensure-symlinked-units-resolve.service
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install ostree \
    --determinate \
    --no-confirm

log "========================================"
log "Nix installation complete!"
log "========================================"
