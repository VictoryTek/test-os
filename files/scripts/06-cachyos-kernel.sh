#!/usr/bin/env bash

set -euo pipefail

echo "Installing CachyOS kernel..."

# Disable kernel install scripts to prevent initramfs generation during install
echo "Disabling kernel install scripts..."
mv /usr/lib/kernel/install.d/05-rpmostree.install /usr/lib/kernel/install.d/05-rpmostree.install.bak
mv /usr/lib/kernel/install.d/50-dracut.install /usr/lib/kernel/install.d/50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > /usr/lib/kernel/install.d/05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > /usr/lib/kernel/install.d/50-dracut.install
chmod +x /usr/lib/kernel/install.d/05-rpmostree.install /usr/lib/kernel/install.d/50-dracut.install

# Remove stock kernel packages
echo "Removing stock kernel..."
dnf -y remove \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra \
    kernel-devel \
    kernel-devel-matched

# Clean up kernel modules directory
rm -rf /usr/lib/modules/*

# Enable CachyOS kernel repository with explicit chroot
echo "Enabling CachyOS kernel repository..."
dnf -y copr enable bieszczaders/kernel-cachyos fedora-43-x86_64

# Install CachyOS kernel with weak dependencies disabled
echo "Installing CachyOS kernel..."
dnf -y install --setopt=install_weak_deps=False \
    kernel-cachyos \
    kernel-cachyos-devel-matched

# Restore kernel install scripts
echo "Restoring kernel install scripts..."
mv -f /usr/lib/kernel/install.d/05-rpmostree.install.bak /usr/lib/kernel/install.d/05-rpmostree.install
mv -f /usr/lib/kernel/install.d/50-dracut.install.bak /usr/lib/kernel/install.d/50-dracut.install

# Enable SELinux policy for kernel module loading (required for CachyOS)
echo "Setting SELinux policy..."
setsebool -P domain_kernel_load_modules on

# Clean up COPR repos (optional - comment out if you want to keep the repo)
echo "Cleaning up repositories..."
rm -f /etc/yum.repos.d/*bieszczaders-kernel-cachyos*.repo

echo "CachyOS kernel installation complete!"
