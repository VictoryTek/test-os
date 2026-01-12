#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Installing Nix during image build"

# ============================================
# Run the Determinate Nix installer NOW (during build)
# ============================================
# During container build, the filesystem is fully writable
# Nix gets installed to /nix and baked into the image

log "Downloading and running Determinate Nix installer..."

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux \
    --no-confirm \
    --init none \
    --nix-build-group-id 30000 \
    --nix-build-group-name nixbld \
    --nix-build-user-count 32 \
    --nix-build-user-id-base 30000 \
    --nix-build-user-prefix nixbld

log "Nix installed successfully"

# ============================================
# Verify Determinate Nix installation
# ============================================
log "Verifying Determinate Nix installation..."

# The Determinate Nix installer creates:
# - /usr/local/bin/determinate-nixd (the daemon binary)
# - /etc/systemd/system/nix-daemon.service (service file)
# - /etc/systemd/system/nix-daemon.socket (socket file)
# - /etc/systemd/system/determinate-nixd.socket (additional socket)

if [ -f /usr/local/bin/determinate-nixd ]; then
    log "Found determinate-nixd binary at /usr/local/bin/determinate-nixd"
else
    log "WARNING: determinate-nixd binary not found!"
fi

# List what the installer created
log "Systemd units created by installer:"
ls -la /etc/systemd/system/*nix* 2>/dev/null || echo "No nix systemd units found in /etc/systemd/system/"
ls -la /usr/lib/systemd/system/*nix* 2>/dev/null || echo "No nix systemd units found in /usr/lib/systemd/system/"

# Enable the services created by the installer
# (installer creates them in /etc/systemd/system/)
log "Enabling nix-daemon services"
systemctl enable nix-daemon.socket || log "nix-daemon.socket enable failed or not found"
systemctl enable nix-daemon.service || log "nix-daemon.service enable failed or not found"

log "Enabled nix-daemon services"

# ============================================
# Create shell profile scripts
# ============================================
log "Creating shell profile scripts"

mkdir -p /etc/profile.d
cat > /etc/profile.d/nix.sh << 'EOF'
# Nix profile script
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
EOF

mkdir -p /etc/bash.bashrc.d
cat > /etc/bash.bashrc.d/nix.sh << 'EOF'
# Nix bash configuration
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
EOF

mkdir -p /etc/fish/conf.d
cat > /etc/fish/conf.d/nix.fish << 'EOF'
# Nix fish configuration
if test -e '/nix/var/nix/profiles/default/etc/fish/conf.d/nix-daemon.fish'
    source '/nix/var/nix/profiles/default/etc/fish/conf.d/nix-daemon.fish'
end
EOF

log "Created shell profile scripts"

log "========================================"
log "Nix installation complete!"
log "Nix is baked into the image and ready to use."
log "========================================"
