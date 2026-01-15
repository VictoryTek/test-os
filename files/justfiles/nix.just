
# Nix management commands

[group("system")]
nix-uninstall:
    #!/usr/bin/bash
    echo "Uninstalling Nix..."
    sudo systemctl stop nix-daemon.service nix-daemon.socket || true
    sudo systemctl disable nix-daemon.service nix-daemon.socket || true
    sudo rm -rf /nix /etc/profile.d/nix.sh /usr/libexec/nix-daemon /usr/lib/systemd/system/nix-daemon.* /usr/lib/systemd/system/nix-var-nix-daemon\x2dsocket.mount
    echo "Nix uninstalled."

[group("system")]
nix-clean:
    #!/usr/bin/bash
    echo "Cleaning Nix store..."
    sudo nix-collect-garbage -d || echo "Nix not found or already removed."
    echo "Nix store cleaned."

[group("system")]
nix-status:
    #!/usr/bin/bash
    echo "=== Nix Installation Status ==="
    if [ -d /nix ]; then
        echo "Nix store exists."
    else
        echo "Nix store not found."
    fi
    if command -v nix &>/dev/null; then
        nix --version
    else
        echo "Nix binary not found."
    fi
