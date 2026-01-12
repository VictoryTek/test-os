#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Downloading Determinate Nix installer"

# Download installer to /usr/libexec (part of the image)
mkdir -p /usr/libexec
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix -o /usr/libexec/nix-installer && \
	chmod a+rx /usr/libexec/nix-installer

log "Nix installer ready at /usr/libexec/nix-installer"
