
# Nix management commands

[group("system")]
install-nix:
    #!/usr/bin/bash
    echo "Installing Nix with Determinate installer..."
    if [ -f /usr/share/nix-installer/install.sh ]; then
        sudo /usr/share/nix-installer/install.sh install ostree --determinate --no-confirm
        echo "Nix installed successfully!"
    else
        echo "ERROR: Installer not found. Downloading..."
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sudo sh -s -- install ostree --determinate --no-confirm
    fi

[group("system")]
nix-uninstall:
    #!/usr/bin/bash
    echo "Uninstalling Nix..."
    if [ -x /nix/nix-installer ]; then
        sudo /nix/nix-installer uninstall
    else
        echo "Nix installer not found, removing manually..."
        sudo systemctl stop nix-daemon.service nix-daemon.socket || true
        sudo systemctl disable nix-daemon.service nix-daemon.socket || true
        sudo rm -rf /nix /etc/profile.d/nix.sh
    fi
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
