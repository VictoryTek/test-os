# Install Nix Package Manager
[group("system")]
install-nix:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Installing Nix Package Manager..."
    
    # Verify symlink exists (should be baked into image)
    if [ ! -L /nix ]; then
        echo "ERROR: /nix symlink not found. Image may not be built correctly."
        exit 1
    fi
    
    # Create /var/nix directory structure if it doesn't exist
    if [ ! -d /var/nix ]; then
        echo "Creating /var/nix directory structure..."
        sudo mkdir -p /var/nix/{store,var/nix/db,var/nix/gcroots,var/nix/profiles,var/nix/temproots,var/nix/userpool,var/nix/daemon-socket}
        sudo chmod 1775 /var/nix/store
        sudo chown root:nixbld /var/nix/store
        sudo chmod 755 /var/nix
    fi
    
    # Run the installer with flags to skip what we've already done
    echo "Running Determinate Nix installer..."
    /usr/libexec/nix-installer install linux \
        --no-confirm \
        --init none \
        --nix-build-group-id 30000 \
        --nix-build-group-name nixbld \
        --nix-build-user-count 32 \
        --nix-build-user-id-base 30000 \
        --nix-build-user-prefix nixbld
    
    echo ""
    echo "Nix installation complete!"
    echo "Please log out and back in, or run: source /etc/profile.d/nix.sh"

# Uninstall Nix Package Manager  
[group("system")]
uninstall-nix:
    #!/usr/bin/bash
    echo "Uninstalling Nix Package Manager..."
    /usr/libexec/nix-installer uninstall --no-confirm

# Check Nix installation status
[group("system")]
nix-status:
    #!/usr/bin/bash
    echo "=== Nix Installation Status ==="
    echo ""
    echo "Symlink /nix:"
    ls -la /nix 2>/dev/null || echo "  NOT FOUND"
    echo ""
    echo "Directory /var/nix:"
    ls -la /var/nix 2>/dev/null || echo "  NOT FOUND"
    echo ""
    echo "Nix binary:"
    which nix 2>/dev/null && nix --version || echo "  NOT INSTALLED"
    echo ""
    echo "Nix daemon service:"
    systemctl is-active nix-daemon.service 2>/dev/null || echo "  NOT RUNNING"
    echo ""
    echo "nixbld group:"
    getent group nixbld || echo "  NOT FOUND"
