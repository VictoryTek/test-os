# Install Nix Package Manager
[group("system")]
install-nix:
    #!/usr/bin/bash
    echo "Installing Nix Package Manager using Determinate Nix installer..."
    # Ensure the tmpfiles.d symlink is created if not already
    if [ ! -L /nix ] && [ ! -d /nix ]; then
        echo "Creating /nix symlink to /var/nix..."
        sudo systemd-tmpfiles --create /usr/lib/tmpfiles.d/nix.conf
    fi
    /usr/libexec/nix-installer install linux \
        --init none \
        --no-confirm

# Uninstall Nix Package Manager
[group("system")]
uninstall-nix:
    #!/usr/bin/bash
    echo "Uninstalling Nix Package Manager..."
    /usr/libexec/nix-installer uninstall --no-confirm
