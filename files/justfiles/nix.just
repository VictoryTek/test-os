# Check Nix installation status
[group("system")]
nix-status:
    #!/usr/bin/bash
    echo "=== Nix Installation Status ==="
    echo ""
    echo "Nix store:"
    ls -la /nix/store 2>/dev/null | head -3 || echo "  NOT FOUND"
    echo ""
    echo "Nix binary:"
    if command -v nix &>/dev/null; then
        nix --version
    else
        echo "  NOT IN PATH - try: source /etc/profile.d/nix.sh"
    fi
    echo ""
    echo "Nix daemon socket:"
    systemctl is-active nix-daemon.socket 2>/dev/null || echo "  NOT ACTIVE"
    echo ""
    echo "Nix daemon service:"
    systemctl is-active nix-daemon.service 2>/dev/null || echo "  NOT RUNNING"

# Restart Nix daemon
[group("system")]
nix-restart:
    #!/usr/bin/bash
    echo "Restarting Nix daemon..."
    sudo systemctl restart nix-daemon.socket
    sudo systemctl restart nix-daemon.service
    echo "Done. Check status with: just nix-status"

# Enable Nix daemon (if not already enabled)
[group("system")]
nix-enable:
    #!/usr/bin/bash
    echo "Enabling Nix daemon..."
    sudo systemctl enable --now nix-daemon.socket
    sudo systemctl enable --now nix-daemon.service
    echo "Done. Check status with: just nix-status"
