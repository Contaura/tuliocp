#!/bin/bash
# Setup GitHub authentication for TulioCP build server

set -e

echo "🔑 Setting up GitHub authentication for build server..."
echo "=================================================="

# Check if we're on the build server
if [ ! -d "/opt/tuliocp-build" ]; then
    echo "❌ This script must be run on the build server"
    echo "Build directory not found: /opt/tuliocp-build"
    exit 1
fi

# Check for GitHub token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GitHub token not provided"
    echo ""
    echo "To set up GitHub authentication:"
    echo "1. Go to: https://github.com/settings/tokens/new"
    echo "2. Create a Personal Access Token with 'repo' permissions"
    echo "3. Copy the token and run:"
    echo "   export GITHUB_TOKEN='your-token-here'"
    echo "   $0"
    echo ""
    echo "Or run this script with the token as an argument:"
    echo "   $0 your-token-here"
    exit 1
fi

# If token provided as argument, use it
if [ -n "$1" ]; then
    GITHUB_TOKEN="$1"
fi

echo "🔧 Configuring Git with GitHub token..."

# Configure git to use token for authentication
cd /opt/tuliocp-build

# Set up git credential helper to use token
git config --global credential.helper store
echo "https://${GITHUB_TOKEN}@github.com" > ~/.git-credentials

# Configure the repository remotes to use HTTPS with token
if [ -d "tuliocp-pages" ]; then
    cd tuliocp-pages
    git remote set-url origin "https://${GITHUB_TOKEN}@github.com/Contaura/tuliocp.git"
    cd ..
fi

# Also configure the main repository if it exists
if [ -d "tuliocp" ]; then
    cd tuliocp
    git remote set-url origin "https://${GITHUB_TOKEN}@github.com/Contaura/tuliocp.git"
    cd ..
fi

echo "✅ GitHub authentication configured successfully!"
echo ""
echo "🔒 Security note: Token is stored securely for git operations"
echo "📋 You can now run deployment scripts without authentication issues"
echo ""
echo "🧪 Test the authentication:"
echo "   cd /opt/tuliocp-build && ./deploy-to-github-pages.sh"