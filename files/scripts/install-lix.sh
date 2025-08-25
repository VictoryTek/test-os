#!/usr/bin/env bash
# Lix (community Nix) multi-user installation script for an ostree/atomic Fedora-based image.
# This is invoked by the BlueBuild script module (see recipes/module-recipes/lix.yml).
# It expects write access to /var (mutable) and will symlink /nix -> /var/lib/nix.

set -euo pipefail

echo "[lix-install] Starting Lix (Nix) multi-user install"
if command -v nix >/dev/null 2>&1; then
  echo "[lix-install] nix already present (from $(command -v nix)), skipping"
  exit 0
fi

# Ensure curl is available (added via dnf module earlier)
command -v curl >/dev/null 2>&1 || { echo "curl missing"; exit 1; }

# Prepare persistent store under /var/lib/nix; symlink /nix -> /var/lib/nix before install
mkdir -p /var/lib/nix
if [ ! -e /nix ]; then
  ln -s /var/lib/nix /nix
elif [ -d /nix ] && [ ! -L /nix ]; then
  echo "[lix-install] Existing real /nix directory detected; moving to /var/lib/nix and replacing with symlink"
  rsync -a /nix/ /var/lib/nix/
  rm -rf /nix
  ln -s /var/lib/nix /nix
fi

# Btrfs optimization (ignore failures on non-btrfs)
if [ "$(stat -f -c %T /var/lib/nix 2>/dev/null || echo unknown)" = "btrfs" ]; then
  chattr +C /var/lib/nix 2>/dev/null || true
fi

echo "[lix-install] Fetching installer"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix \
  | sh -s -- install linux-multi --no-confirm --extra-conf 'experimental-features = nix-command flakes'

# Ensure profile sourcing
mkdir -p /etc/profile.d
cat >/etc/profile.d/nix.sh <<'EOF'
# Added by image build (Lix): source daemon profile if present
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
EOF
chmod 0644 /etc/profile.d/nix.sh

# Enable socket via preset + direct attempt (harmless if not available at build time)
if command -v systemctl >/dev/null 2>&1; then
  systemctl enable nix-daemon.socket 2>/dev/null || true
fi

echo "[lix-install] Completed"
if [ -x /nix/var/nix/profiles/default/bin/nix ]; then
  /nix/var/nix/profiles/default/bin/nix --version || true
fi
