#!/bin/bash
# Quick TulioCP Build Server Deployment Script
# Usage: ./deploy-build-server.sh

set -e

echo "🏗️  TulioCP Build Server Setup"
echo "================================"

# Check if running on supported OS
if ! grep -E "Ubuntu|Debian" /etc/os-release; then
	echo "❌ This script requires Ubuntu or Debian"
	exit 1
fi

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install build dependencies
echo "🔧 Installing build dependencies..."
sudo apt install -y \
	build-essential \
	dpkg-dev \
	git \
	curl \
	wget \
	nodejs \
	npm \
	libssl-dev \
	zlib1g-dev \
	libpcre3-dev \
	libxml2-dev \
	libxslt1-dev \
	libgd-dev \
	libgeoip-dev \
	libzip-dev \
	lsb-release

# Create build directory
echo "📁 Setting up build environment..."
sudo mkdir -p /opt/tuliocp-build
sudo chown $USER:$USER /opt/tuliocp-build
cd /opt/tuliocp-build

# Clone TulioCP repository
echo "📥 Cloning TulioCP repository..."
if [ -d "tuliocp" ]; then
	cd tuliocp
	git pull origin main
else
	git clone https://github.com/Contaura/tuliocp.git
	cd tuliocp
fi

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
npm ci --ignore-scripts || echo "⚠️  Node dependencies failed, continuing..."

# Test package build
echo "🧪 Testing package build..."
chmod +x src/build-minimal-package.sh
if ./src/build-minimal-package.sh; then
	echo "✅ Package build successful!"
	ls -la /tmp/*.deb 2> /dev/null || echo "No .deb files found"
else
	echo "❌ Package build failed, but server is ready for debugging"
fi

# Create automated build script
echo "🤖 Creating automated build script..."
cat > /opt/tuliocp-build/auto-build.sh << 'EOF'
#!/bin/bash
# Automated TulioCP Build Script

set -e
cd /opt/tuliocp-build/tuliocp

echo "$(date): Starting automated build..."
git pull origin main

if ./src/build-minimal-package.sh; then
    echo "$(date): Build successful!"
    ls -la /tmp/*.deb
    
    # Optional: Upload to repository (configure as needed)
    # rsync -av /tmp/*.deb user@apt.tuliocp.com:/var/www/apt/pool/main/
else
    echo "$(date): Build failed!"
    exit 1
fi
EOF

chmod +x /opt/tuliocp-build/auto-build.sh

# Setup GitHub Actions runner (optional)
echo ""
echo "🚀 Build server setup complete!"
echo ""
echo "Next steps:"
echo "1. Test manual build: /opt/tuliocp-build/auto-build.sh"
echo "2. Setup GitHub Actions runner (see docs/build-server-setup.md)"
echo "3. Configure automated deployment to apt.tuliocp.com"
echo ""
echo "Build directory: /opt/tuliocp-build/"
echo "Auto-build script: /opt/tuliocp-build/auto-build.sh"
