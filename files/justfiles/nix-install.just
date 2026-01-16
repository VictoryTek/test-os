# Install Nix Package Manager (Agate approach)
[group("system")]
install-nix:
    #!/usr/bin/bash
    echo "Installing Nix Package Manager..."
    sudo /nix/determinate-nix-installer.sh install linux \
        --no-confirm \
        --nix-build-group-id 30000 \
        --nix-build-group-name nixbld \
        --nix-build-user-count 32 \
        --nix-build-user-id-base 30000 \
        --nix-build-user-prefix nixbld
    echo "Nix installed. You may need to log out and back in for changes to take effect."

# Check Nix status
[group("system")]
nix-status:
    systemctl status nix-daemon.service

# Restart Nix daemon
[group("system")]
nix-restart:
    sudo systemctl restart nix-daemon.service
