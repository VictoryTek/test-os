# Install Nix Package Manager
[group("system")]
install-nix:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Installing Nix Package Manager..."

    # Verify /nix directory exists (should be baked into image)
    if [ ! -d /nix ]; then
        echo "ERROR: /nix directory not found. Image may not be built correctly."
        exit 1
    fi

    # Ensure bind mount is active
    if ! mountpoint -q /nix; then
        echo "Activating /nix bind mount..."
        sudo systemctl start nix.mount
        sleep 1
        if ! mountpoint -q /nix; then
            echo "ERROR: Failed to mount /nix. Check 'systemctl status nix.mount'"
            exit 1
        fi
    fi
    echo "/nix is mounted correctly"

    # Verify /nix is writable
    if ! sudo touch /nix/.write-test 2>/dev/null; then
        echo "ERROR: /nix is not writable"
        exit 1
    fi
    sudo rm -f /nix/.write-test

    # Run the installer
    echo "Running Determinate Nix installer..."
    /usr/libexec/nix-installer install linux \
        --no-confirm \
        --init none \
        --nix-build-group-id 30000 \
        --nix-build-group-name nixbld \
        --nix-build-user-count 32 \
        --nix-build-user-id-base 30000 \
        --nix-build-user-prefix nixbld

    # Enable and start the daemon
    echo "Enabling nix-daemon..."
    sudo systemctl enable --now nix-daemon.socket
    sudo systemctl enable --now nix-daemon.service

    echo ""
    echo "Nix installation complete!"
    echo "Please log out and back in, or run: source /etc/profile.d/nix.sh"

# Uninstall Nix Package Manager
[group("system")]
uninstall-nix:
    #!/usr/bin/bash
    echo "Uninstalling Nix Package Manager..."
    sudo systemctl disable --now nix-daemon.socket || true
    sudo systemctl disable --now nix-daemon.service || true
    /usr/libexec/nix-installer uninstall --no-confirm

# Check Nix installation status
[group("system")]
nix-status:
    #!/usr/bin/bash
    echo "=== Nix Installation Status ==="
    echo ""
    echo "/nix mount:"
    mountpoint /nix 2>/dev/null && echo "  MOUNTED" || echo "  NOT MOUNTED"
    mount | grep "/nix" || echo "  (no mount info)"
    echo ""
    echo "Directory /var/nix:"
    ls -la /var/nix 2>/dev/null | head -5 || echo "  NOT FOUND"
    echo ""
    echo "Nix binary:"
    which nix 2>/dev/null && nix --version || echo "  NOT INSTALLED"
    echo ""
    echo "Nix daemon service:"
    systemctl is-active nix-daemon.service 2>/dev/null || echo "  NOT RUNNING"
    echo ""
    echo "nix.mount unit:"
    systemctl is-active nix.mount 2>/dev/null || echo "  NOT ACTIVE"
    echo ""
    echo "nixbld group:"
    getent group nixbld || echo "  NOT FOUND"
