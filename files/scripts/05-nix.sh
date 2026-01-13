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
# Create systemd service files
# ============================================
# With --init none, the installer doesn't create systemd units,
# so we need to create them ourselves

log "Creating systemd service files for nix-daemon"

cat > /usr/lib/systemd/system/nix-daemon.service << 'EOF'
[Unit]
Description=Nix Daemon
Documentation=man:nix-daemon https://docs.determinate.systems
After=nix-var-nix.mount
Requires=nix-var-nix.mount
ConditionPathIsDirectory=/nix/store

[Service]
ExecStart=/nix/var/nix/profiles/default/bin/nix daemon
KillMode=process
LimitNOFILE=1048576
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

cat > /usr/lib/systemd/system/nix-daemon.socket << 'EOF'
[Unit]
Description=Nix Daemon Socket
Documentation=man:nix-daemon https://docs.determinate.systems
After=nix-var-nix.mount
Requires=nix-var-nix.mount
ConditionPathIsDirectory=/nix/store

[Socket]
ListenStream=/nix/var/nix/daemon-socket/socket

[Install]
WantedBy=sockets.target
EOF

log "Created systemd service files"

# ============================================
# Enable services
# ============================================
log "Enabling nix-var-nix.mount for writable state directory"
systemctl enable nix-var-nix.mount

log "Enabling nix-daemon services"
systemctl enable nix-daemon.socket
systemctl enable nix-daemon.service

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
