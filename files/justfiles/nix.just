# Install Nix Package Manager
[group("system")]
install-nix:
    #!/usr/bin/bash
    /nix/nix-installer install linux \
        --init none \
        --no-confirm
