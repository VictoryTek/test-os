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
# Create systemd mount unit for writable daemon-socket
# ============================================
# The mount unit name must match the mount path with slashes as dashes
# /nix/var/nix/daemon-socket -> nix-var-nix-daemon\x2dsocket.mount
# (systemd escapes the dash after "daemon" as \x2d)

log "Creating systemd mount unit for daemon-socket tmpfs"

cat > '/usr/lib/systemd/system/nix-var-nix-daemon\x2dsocket.mount' << 'EOF'
[Unit]
Description=Tmpfs for Nix daemon socket
DefaultDependencies=no
After=local-fs.target
Before=nix-daemon.socket nix-daemon.service

[Mount]
What=tmpfs
Where=/nix/var/nix/daemon-socket
Type=tmpfs
Options=mode=0755

[Install]
WantedBy=local-fs.target
EOF

log "Created mount unit"

# ============================================
# Create wrapper script for nix-daemon
# ============================================
# Scripts in /usr/libexec get proper SELinux context (bin_t)
# This allows systemd to execute them without SELinux issues

log "Creating nix-daemon wrapper script"

mkdir -p /usr/libexec
cat > /usr/libexec/nix-daemon << 'EOF'
#!/bin/bash
exec /nix/var/nix/profiles/default/bin/nix daemon "$@"
EOF
chmod +x /usr/libexec/nix-daemon

log "Created wrapper script"

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
After=nix-var-nix-daemon\x2dsocket.mount
Requires=nix-var-nix-daemon\x2dsocket.mount
ConditionPathIsDirectory=/nix/store

[Service]
ExecStart=/usr/libexec/nix-daemon
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
After=nix-var-nix-daemon\x2dsocket.mount
Requires=nix-var-nix-daemon\x2dsocket.mount
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
log "Enabling mount and daemon services"
systemctl enable 'nix-var-nix-daemon\x2dsocket.mount'

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
