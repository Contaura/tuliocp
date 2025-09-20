#!/bin/bash
# Deploy TulioCP packages to GitHub Pages APT repository

set -e

REPO_DIR="/tmp/tuliocp-repo"
BUILD_DIR="/opt/tuliocp-build"

echo "🚀 Deploying TulioCP packages to GitHub Pages..."

# Check if repository exists
if [ ! -d "$REPO_DIR" ]; then
    echo "❌ Repository not found at $REPO_DIR"
    echo "Run ./deploy-to-repo.sh first to build the repository"
    exit 1
fi

# Navigate to build directory
cd "$BUILD_DIR"

# Check if we have a git repository for the pages
if [ ! -d "tuliocp-pages" ]; then
    echo "📥 Cloning GitHub Pages repository..."
    git clone -b gh-pages https://github.com/Contaura/tuliocp.git tuliocp-pages || {
        echo "📥 Creating new gh-pages branch..."
        git clone https://github.com/Contaura/tuliocp.git tuliocp-pages
        cd tuliocp-pages
        git checkout --orphan gh-pages
        git rm -rf .
        cd ..
    }
fi

# Navigate to pages repository
cd tuliocp-pages

# Clean existing content (keep .git)
find . -maxdepth 1 ! -name '.git' ! -name '.' -exec rm -rf {} +

# Copy repository content
echo "📋 Copying repository files..."
cp -r "$REPO_DIR"/* .

# Add all files
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "ℹ️  No changes to deploy"
    exit 0
fi

# Commit and push
echo "📤 Committing and pushing to GitHub Pages..."
git commit -m "Deploy TulioCP packages - $(date)"
git push origin gh-pages

echo "✅ Deployment complete!"
echo "📦 Packages available at: https://apt.tuliocp.com"
echo ""
echo "🔧 To install TulioCP:"
echo "  wget -O - https://apt.tuliocp.com/setup.sh | sudo bash"
echo "  sudo apt update"
echo "  sudo apt install tuliocp"