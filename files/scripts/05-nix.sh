#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Installing Nix during image build"

# ============================================
# Run the Determinate Nix installer for OSTree systems
# ============================================
# The 'ostree' planner handles all OSTree-specific requirements:
# - Proper systemd service setup
# - SELinux contexts
# - Writable mount points
# - Profile scripts

log "Downloading and running Determinate Nix installer (ostree planner)..."

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install ostree \
    --no-confirm \
    --nix-build-group-id 30000 \
    --nix-build-group-name nixbld \
    --nix-build-user-count 32 \
    --nix-build-user-id-base 30000 \
    --nix-build-user-prefix nixbld

log "========================================"
log "Nix installation complete!"
log "The ostree planner handled all setup automatically."
log "========================================"
