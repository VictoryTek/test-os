#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Downloading Determinate Nix installer to /usr/libexec"

# Download installer to /usr/libexec (part of the immutable image)
# The actual /nix store will be created via tmpfiles.d symlink to /var/nix (writable)
mkdir -p /usr/libexec
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix -o /usr/libexec/nix-installer && \
	chmod a+rx /usr/libexec/nix-installer

log "Nix installer ready at /usr/libexec/nix-installer"
log "Note: /nix will be symlinked to /var/nix via tmpfiles.d on boot"
