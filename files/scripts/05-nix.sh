#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Creating /nix and downloading Determinate Nix installer"

# Create /nix directory and download installer (following agate pattern)
mkdir -p /nix && \
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix -o /nix/nix-installer && \
	chmod a+rx /nix/nix-installer

log "Nix installer ready at /nix/nix-installer"
