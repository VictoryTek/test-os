#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Installing Determinate Nix during image build"

# Official approach from Determinate Systems docs for container builds
# Uses --init none (no systemd during build) with --determinate flag
# This installs determinate-nixd instead of standard nix-daemon
# Reference: https://docs.determinate.systems/guides/buildkite

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux \
    --determinate \
    --no-confirm \
    --init none

log "========================================"
log "Nix installation complete!"
log "Daemon will start automatically on boot via systemd"
log "========================================"
