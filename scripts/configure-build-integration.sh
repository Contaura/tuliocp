#!/bin/bash
# TulioCP Build Server Integration Configuration
# Run this on your build server after initial setup

set -e

echo "🔧 TulioCP Build Server Integration Setup"
echo "========================================"

# Verify build server setup
if [ ! -d "/opt/tuliocp-build" ]; then
    echo "❌ Build server not set up. Run deploy-build-server.sh first."
    exit 1
fi

cd /opt/tuliocp-build

# Test package building
echo "🧪 Testing package build..."
cd tuliocp
git pull origin main

if ./src/build-minimal-package.sh; then
    echo "✅ Package build successful!"
    
    # Show built packages
    echo "📦 Built packages:"
    ls -la /tmp/*.deb 2>/dev/null || echo "No .deb files found"
    
    # Get package info
    for deb in /tmp/*.deb; do
        if [ -f "$deb" ]; then
            echo "Package info for $(basename $deb):"
            dpkg-deb --info "$deb" | head -15
            echo "---"
        fi
    done
else
    echo "❌ Package build failed!"
    exit 1
fi

# Create repository deployment script
echo "🚀 Creating repository deployment script..."
cat > /opt/tuliocp-build/deploy-to-repo.sh << 'EOF'
#!/bin/bash
# Deploy packages to APT repository

set -e

echo "📤 Deploying packages to repository..."

# Build directory
PACKAGES_DIR="/tmp/tuliocp-packages"
mkdir -p "$PACKAGES_DIR"

# Copy packages
cp /tmp/*.deb "$PACKAGES_DIR/" 2>/dev/null || {
    echo "❌ No packages to deploy"
    exit 1
}

echo "📦 Packages ready for deployment:"
ls -la "$PACKAGES_DIR/"

# Create local repository structure
REPO_DIR="/tmp/tuliocp-repo"
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"/{dists/stable/main/binary-amd64,pool/main}

# Copy packages to pool
cp "$PACKAGES_DIR"/*.deb "$REPO_DIR/pool/main/"

# Generate Packages file
cd "$REPO_DIR"
dpkg-scanpackages pool/ /dev/null > dists/stable/main/binary-amd64/Packages
gzip -9 -c dists/stable/main/binary-amd64/Packages > dists/stable/main/binary-amd64/Packages.gz

# Create Release file
cat > dists/stable/Release << EOFRELEASE
Origin: TulioCP
Label: TulioCP APT Repository
Suite: stable
Codename: stable
Components: main
Architectures: amd64
Date: $(date -u +"%a, %d %b %Y %H:%M:%S %Z")
Description: TulioCP Control Panel packages
EOFRELEASE

# Copy repository index
if [ -f "/opt/tuliocp-build/tuliocp/apt-repo/index.html" ]; then
    cp "/opt/tuliocp-build/tuliocp/apt-repo/index.html" "$REPO_DIR/"
else
    echo "⚠️ Repository index not found, creating basic one"
    cat > "$REPO_DIR/index.html" << 'EOFHTML'
<!DOCTYPE html>
<html><head><title>TulioCP APT Repository</title></head>
<body>
<h1>TulioCP APT Repository</h1>
<p>Packages updated: $(date)</p>
<p>Available packages:</p>
<ul>
EOFHTML
    for deb in "$REPO_DIR"/pool/main/*.deb; do
        if [ -f "$deb" ]; then
            echo "<li>$(basename "$deb")</li>" >> "$REPO_DIR/index.html"
        fi
    done
    echo '</ul></body></html>' >> "$REPO_DIR/index.html"
fi

echo "✅ Repository structure created at: $REPO_DIR"
echo "📁 Repository contents:"
find "$REPO_DIR" -type f | head -20

# Instructions for deployment
echo ""
echo "🚀 Repository ready for deployment!"
echo ""
echo "To deploy to GitHub Pages:"
echo "1. Copy contents to your repository's gh-pages branch"
echo "2. Or use GitHub Actions to sync the repository"
echo ""
echo "Repository location: $REPO_DIR"

EOF

chmod +x /opt/tuliocp-build/deploy-to-repo.sh

# Create GitHub Actions integration script
echo "🤖 Creating GitHub Actions integration..."
cat > /opt/tuliocp-build/setup-github-runner.sh << 'EOF'
#!/bin/bash
# Setup GitHub Actions Self-Hosted Runner

echo "Setting up GitHub Actions runner..."
echo "1. Go to https://github.com/Contaura/tuliocp/settings/actions/runners"
echo "2. Click 'New self-hosted runner'"
echo "3. Select 'Linux x64'"
echo "4. Copy the token and run:"
echo ""
echo "# Download and configure runner"
echo "mkdir -p ~/actions-runner && cd ~/actions-runner"
echo "curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz"
echo "tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz"
echo "./config.sh --url https://github.com/Contaura/tuliocp --token YOUR_TOKEN_HERE"
echo ""
echo "# Run as service"
echo "sudo ./svc.sh install"
echo "sudo ./svc.sh start"
echo ""
echo "Then update .github/workflows/build-packages.yml to use: runs-on: self-hosted"
EOF

chmod +x /opt/tuliocp-build/setup-github-runner.sh

# Create webhook handler (optional)
echo "🔗 Creating webhook handler..."
cat > /opt/tuliocp-build/webhook-handler.py << 'EOF'
#!/usr/bin/env python3
"""
Simple webhook handler for TulioCP builds
Usage: python3 webhook-handler.py
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import subprocess
import json
import os

class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/build':
            try:
                # Run build
                result = subprocess.run(['/opt/tuliocp-build/auto-build.sh'], 
                                      capture_output=True, text=True)
                
                if result.returncode == 0:
                    # Deploy to repository
                    subprocess.run(['/opt/tuliocp-build/deploy-to-repo.sh'])
                    
                    self.send_response(200)
                    self.send_header('Content-type', 'application/json')
                    self.end_headers()
                    self.wfile.write(json.dumps({
                        'status': 'success',
                        'message': 'Build completed successfully'
                    }).encode())
                else:
                    self.send_response(500)
                    self.send_header('Content-type', 'application/json')
                    self.end_headers()
                    self.wfile.write(json.dumps({
                        'status': 'error',
                        'message': result.stderr
                    }).encode())
                    
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({
                    'status': 'error',
                    'message': str(e)
                }).encode())
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8080), WebhookHandler)
    print("Webhook server running on port 8080")
    print("Trigger builds with: curl -X POST http://your-server:8080/build")
    server.serve_forever()
EOF

chmod +x /opt/tuliocp-build/webhook-handler.py

echo ""
echo "🎉 Build server integration setup complete!"
echo ""
echo "Available scripts:"
echo "- /opt/tuliocp-build/auto-build.sh          # Manual build"
echo "- /opt/tuliocp-build/deploy-to-repo.sh      # Deploy packages"
echo "- /opt/tuliocp-build/setup-github-runner.sh # GitHub Actions setup"
echo "- /opt/tuliocp-build/webhook-handler.py     # Webhook server"
echo ""
echo "Next steps:"
echo "1. Test: ./deploy-to-repo.sh"
echo "2. Setup GitHub Actions runner (optional)"
echo "3. Configure automated deployment"