# Install Nix Package Manager
[group("system")]
install-nix:
    #!/usr/bin/bash
    echo "Installing Nix Package Manager using Determinate Nix installer..."
    /nix/nix-installer install linux \
        --init none \
        --no-confirm

# Uninstall Nix Package Manager
[group("system")]
uninstall-nix:
    #!/usr/bin/bash
    echo "Uninstalling Nix Package Manager..."
    /nix/nix-installer uninstall --no-confirm
