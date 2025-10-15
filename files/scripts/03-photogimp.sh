#!/usr/bin/env bash
set -oue pipefail

echo "Installing PhotoGIMP..."

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download PhotoGIMP from the official repository
echo "Downloading PhotoGIMP..."
curl -L -o photogimp.zip "https://github.com/Diolinux/PhotoGIMP/archive/refs/heads/master.zip"

# Extract the archive
echo "Extracting PhotoGIMP..."
unzip -q photogimp.zip

# Create a script to set up PhotoGIMP for users on first login
mkdir -p /etc/profile.d
cat > /etc/profile.d/photogimp-setup.sh <<'EOF'
#!/bin/bash
# Set up PhotoGIMP for user on first login
if [ ! -f "$HOME/.photogimp-installed" ]; then
    # Extract PhotoGIMP to temporary location
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download and extract PhotoGIMP
    curl -L -o photogimp.zip "https://github.com/Diolinux/PhotoGIMP/archive/refs/heads/master.zip" 2>/dev/null
    unzip -q photogimp.zip 2>/dev/null
    
    # Copy .config and .local folders to user home directory
    if [ -d "PhotoGIMP-master/.config" ]; then
        cp -r PhotoGIMP-master/.config/* "$HOME/.config/" 2>/dev/null || true
    fi
    if [ -d "PhotoGIMP-master/.local" ]; then
        cp -r PhotoGIMP-master/.local/* "$HOME/.local/" 2>/dev/null || true
    fi
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
    # Mark as installed
    touch "$HOME/.photogimp-installed"
fi
EOF

chmod +x /etc/profile.d/photogimp-setup.sh

# Clean up
cd /
rm -rf "$TEMP_DIR"

echo "PhotoGIMP installation script created!"
