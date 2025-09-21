#!/bin/bash
# Enhanced deployment script for TulioCP APT repository

set -e

echo "📤 Deploying packages to repository..."

# Check if packages exist
if [ ! -d "/tmp" ] || [ -z "$(find /tmp -name "*.deb" 2> /dev/null)" ]; then
	echo "❌ No packages found in /tmp/"
	echo "Run build script first to create packages"
	exit 1
fi

echo "📦 Packages ready for deployment:"
ls -la /tmp/*.deb 2> /dev/null || echo "No .deb files found"

# Create repository structure
REPO_DIR="/tmp/tuliocp-repo"
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"/{dists/stable/main/binary-amd64,pool/main}

# Copy packages
echo "📋 Copying packages to repository..."
cp /tmp/*.deb "$REPO_DIR/pool/main/" 2> /dev/null || {
	echo "❌ Failed to copy packages"
	exit 1
}

cd "$REPO_DIR"

# Generate Packages file
echo "📊 Generating package metadata..."
dpkg-scanpackages pool/ /dev/null > dists/stable/main/binary-amd64/Packages
gzip -9 -c dists/stable/main/binary-amd64/Packages > dists/stable/main/binary-amd64/Packages.gz

# Calculate checksums for Release file
cd dists/stable

# Generate Release file with proper checksums
cat > Release << EOF
Origin: TulioCP
Label: TulioCP APT Repository
Suite: stable
Codename: stable
Components: main
Architectures: amd64
Date: $(date -u +"%a, %d %b %Y %H:%M:%S %Z")
Description: TulioCP Control Panel packages - Unsigned Repository
EOF

# Add MD5Sum section
echo "MD5Sum:" >> Release
find . -name "*.gz" -o -name "Packages" | while read file; do
	if [ -f "$file" ]; then
		md5sum "$file" | awk -v file="$file" '{printf " %s %8d %s\n", $1, length, file}'
	fi
done | sed 's|^\./||' >> Release

# Add SHA1 section
echo "SHA1:" >> Release
find . -name "*.gz" -o -name "Packages" | while read file; do
	if [ -f "$file" ]; then
		sha1sum "$file" | awk -v file="$file" '{printf " %s %8d %s\n", $1, length, file}'
	fi
done | sed 's|^\./||' >> Release

# Add SHA256 section
echo "SHA256:" >> Release
find . -name "*.gz" -o -name "Packages" | while read file; do
	if [ -f "$file" ]; then
		sha256sum "$file" | awk -v file="$file" '{printf " %s %8d %s\n", $1, length, file}'
	fi
done | sed 's|^\./||' >> Release

cd "$REPO_DIR"

# Copy repository index page
if [ -f "/opt/tuliocp-build/tuliocp/apt-repo/index.html" ]; then
	cp "/opt/tuliocp-build/tuliocp/apt-repo/index.html" index.html
	echo "✅ Using updated repository index page"
else
	echo "⚠️ Creating basic index page"
	cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TulioCP APT Repository</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        .header { text-align: center; border-bottom: 3px solid #667eea; padding-bottom: 20px; margin-bottom: 30px; }
        .code-block { background: #2c3e50; color: #ecf0f1; padding: 20px; border-radius: 8px; margin: 15px 0; font-family: monospace; }
        .warning { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 15px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>TulioCP APT Repository</h1>
        <p>Official package repository for TulioCP Control Panel</p>
    </div>
    
    <div class="warning">
        <strong>Note:</strong> This repository is currently unsigned. Use <code>--allow-unauthenticated</code> flag when installing.
    </div>
    
    <h2>Installation</h2>
    <div class="code-block">
# Add repository
echo "deb https://apt.tuliocp.com stable main" | sudo tee /etc/apt/sources.list.d/tuliocp.list

# Update and install (with unsigned package support)
sudo apt update
sudo apt install --allow-unauthenticated tuliocp
    </div>
    
    <h2>Available Packages</h2>
    <ul>
        <li><strong>tuliocp</strong> - Main control panel package</li>
    </ul>
    
    <p><a href="https://github.com/Contaura/tuliocp">GitHub Repository</a> | <a href="https://github.com/Contaura/tuliocp/issues">Report Issues</a></p>
</body>
</html>
EOF
fi

echo "✅ Repository structure created at: $REPO_DIR"
echo "📁 Repository contents:"
find "$REPO_DIR" -type f | sort

echo ""
echo "🚀 Repository ready for deployment!"
echo ""
echo "📋 Repository includes:"
echo "  ✅ Proper Release file with checksums"
echo "  ✅ Packages and Packages.gz files"
echo "  ✅ Repository index page"
echo "  ⚠️  Unsigned (requires --allow-unauthenticated)"
echo ""
echo "Repository location: $REPO_DIR"
