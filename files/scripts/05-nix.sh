#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Setting up Nix directory structure for immutable OS"

# Create /var/nix directory that will persist across reboots
mkdir -p /var/nix

# Download Determinate Nix installer to /var/nix so it persists
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix -o /var/nix/nix-installer && \
	chmod a+rx /var/nix/nix-installer

log "Nix installer ready at /var/nix/nix-installer"
