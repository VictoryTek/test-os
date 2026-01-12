# Install Nix Package Manager
[group("system")]
install-nix:
    #!/usr/bin/bash
    echo "Installing Nix Package Manager using Determinate Nix installer..."
    /usr/libexec/nix-installer install linux \
        --init none \
        --no-confirm
