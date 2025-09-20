#!/bin/bash

# Simple script to build minimal TulioCP package
set -e

echo "Building minimal TulioCP package..."

BUILD_DIR="/tmp/tuliocp-build"
PACKAGE_DIR="$BUILD_DIR/tuliocp"
DEB_DIR="$PACKAGE_DIR/DEBIAN"
INSTALL_DIR="$PACKAGE_DIR/usr/local/tulio"

# Clean and create directories
rm -rf "$BUILD_DIR"
mkdir -p "$DEB_DIR"
mkdir -p "$INSTALL_DIR"/{bin,data,conf,web,func,install}

# Get current directory (should be src/)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Repository root: $REPO_ROOT"

# Copy control file
echo "Creating control file..."
cat > "$DEB_DIR/control" << 'EOF'
Source: tuliocp
Package: tuliocp
Priority: optional
Version: 1.10.0~alpha
Section: admin
Maintainer: TulioCP <info@tuliocp.com>
Homepage: https://www.tuliocp.com
Architecture: amd64
Depends: bash, awk, sed, acl, sysstat, setpriv | util-linux (>= 2.33), zstd, lsb-release, idn2, jq, bubblewrap, at
Description: TulioCP Control Panel
 TulioCP is an open source hosting control panel forked from VestaCP.
 TulioCP has a clean and focused interface without the clutter.
 TulioCP has the latest of very innovative technologies.
 TulioCP provides comprehensive web server management with modern features.
EOF

# Create postinst script
echo "Creating postinst script..."
cat > "$DEB_DIR/postinst" << 'EOF'
#!/bin/bash
# TulioCP package post-installation script

# Set proper permissions
if [ -d "/usr/local/tulio" ]; then
    chown -R root:root /usr/local/tulio
    chmod -R 755 /usr/local/tulio/bin 2>/dev/null || true
fi

# Create basic directories if they don't exist
mkdir -p /usr/local/tulio/{bin,data,conf,log} 2>/dev/null || true

# Create version check command
cat > /usr/local/tulio/bin/tulio-version << 'EOFV'
#!/bin/bash
echo "TulioCP 1.10.0~alpha"
echo "Web Server Control Panel"  
echo "https://www.tuliocp.com"
EOFV
chmod +x /usr/local/tulio/bin/tulio-version

echo "TulioCP package installed successfully!"
echo "Note: This is a minimal package. Use the installer script for full setup."

exit 0
EOF

chmod +x "$DEB_DIR/postinst"

# Copy essential files from repository
echo "Copying essential files..."

# Copy bin directory if exists
if [ -d "$REPO_ROOT/bin" ]; then
    cp -r "$REPO_ROOT/bin"/* "$INSTALL_DIR/bin/" 2>/dev/null || true
fi

# Copy web directory if exists  
if [ -d "$REPO_ROOT/web" ]; then
    cp -r "$REPO_ROOT/web"/* "$INSTALL_DIR/web/" 2>/dev/null || true
fi

# Copy func directory if exists
if [ -d "$REPO_ROOT/func" ]; then
    cp -r "$REPO_ROOT/func"/* "$INSTALL_DIR/func/" 2>/dev/null || true
fi

# Copy install directory if exists
if [ -d "$REPO_ROOT/install" ]; then
    cp -r "$REPO_ROOT/install"/* "$INSTALL_DIR/install/" 2>/dev/null || true
fi

# Create basic tulio.conf
mkdir -p "$INSTALL_DIR/conf"
cat > "$INSTALL_DIR/conf/tulio.conf" << 'EOF'
# TulioCP Configuration File
TULIO='/usr/local/tulio'
VERSION='1.10.0~alpha'
EOF

# Build the package
echo "Building .deb package..."
dpkg-deb --build "$PACKAGE_DIR" "/tmp/tuliocp_1.10.0~alpha_amd64.deb"

if [ -f "/tmp/tuliocp_1.10.0~alpha_amd64.deb" ]; then
    echo "✅ Package built successfully: /tmp/tuliocp_1.10.0~alpha_amd64.deb"
    ls -la "/tmp/tuliocp_1.10.0~alpha_amd64.deb"
else
    echo "❌ Package build failed"
    exit 1
fi