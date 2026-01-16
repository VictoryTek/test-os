#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Installing Determinate Nix during image build"

# Phase 1: Install Nix without systemd (container build limitation)
# Phase 2: A oneshot systemd service will complete setup on first boot
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux \
    --determinate \
    --no-confirm \
    --init none

log "========================================"
log "Nix binaries installed!"
log "Systemd units will be created on first boot"
log "========================================"
