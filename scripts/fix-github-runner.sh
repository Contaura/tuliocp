#!/bin/bash
# GitHub Actions Self-Hosted Runner Fix Script
# Troubleshoot and setup GitHub Actions runner correctly

echo "🔧 GitHub Actions Runner Troubleshooting"
echo "========================================"

# Check if we're on the build server
if [ ! -d "/opt/tuliocp-build" ]; then
    echo "⚠️  This should be run on your build server, not locally"
    echo "But we can still generate the correct commands for you..."
fi

echo ""
echo "📋 Step-by-Step Runner Setup"
echo ""

# Step 1: Verify repository access
echo "1. 🔍 First, verify repository access:"
echo "   Go to: https://github.com/Contaura/tuliocp"
echo "   Make sure you have admin access to the repository"
echo ""

# Step 2: Get runner registration token
echo "2. 🔑 Get a fresh registration token:"
echo "   a) Go to: https://github.com/Contaura/tuliocp/settings/actions/runners"
echo "   b) Click 'New self-hosted runner'"
echo "   c) Select 'Linux' and 'x64'"
echo "   d) Copy the token from the configuration command"
echo ""

# Step 3: Alternative approach - use the GitHub CLI
echo "3. 🎯 Alternative: Use GitHub CLI (if available):"
echo "   # Install GitHub CLI on your build server"
echo "   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
echo "   echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
echo "   sudo apt update && sudo apt install gh"
echo ""
echo "   # Authenticate and get runner token"
echo "   gh auth login"
echo "   gh api repos/Contaura/tuliocp/actions/runners/registration-token"
echo ""

# Step 4: Manual setup commands
echo "4. 🛠️  Manual Setup Commands (run on your build server):"
echo ""

cat << 'EOF'
# Create runner directory
mkdir -p ~/actions-runner && cd ~/actions-runner

# Download latest runner (check GitHub for current version)
RUNNER_VERSION="2.311.0"
curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
  "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

# Extract runner
tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Configure runner (replace YOUR_TOKEN with the token from GitHub)
./config.sh \
  --url https://github.com/Contaura/tuliocp \
  --token YOUR_TOKEN_HERE \
  --name "tuliocp-build-server" \
  --labels "tuliocp,build-server,linux,x64" \
  --work _work \
  --replace

# Install as service
sudo ./svc.sh install
sudo ./svc.sh start

# Check status
sudo ./svc.sh status
EOF

echo ""
echo "5. 🔄 Alternative: Use webhook approach instead"
echo "   If GitHub Actions runner continues to have issues, we can use webhooks:"
echo ""
echo "   # On your build server, start the webhook handler:"
echo "   cd /opt/tuliocp-build"
echo "   python3 webhook-handler.py"
echo ""
echo "   # Then set up a GitHub webhook:"
echo "   # Repository Settings > Webhooks > Add webhook"
echo "   # Payload URL: http://your-build-server:8080/build"
echo "   # Content type: application/json"
echo "   # Events: Push events"
echo ""

# Step 6: Test runner
echo "6. ✅ Test the runner:"
echo "   After setup, update .github/workflows/build-packages.yml:"
echo ""

cat << 'EOF'
jobs:
  build-packages:
    runs-on: self-hosted  # Change from ubuntu-latest
    labels: [linux, tuliocp, build-server]  # Optional: specific labels
EOF

echo ""
echo "7. 🐛 Debugging Tips:"
echo "   - Ensure the repository is public or you have proper access"
echo "   - Check that Actions are enabled in repository settings"
echo "   - Verify the token hasn't expired (tokens expire after 1 hour)"
echo "   - Make sure you're using the correct repository URL format"
echo ""

echo "8. 📞 Quick Test:"
echo "   curl -H \"Authorization: token YOUR_GITHUB_TOKEN\" \\"
echo "        https://api.github.com/repos/Contaura/tuliocp"
echo "   (This should return repository info, not 404)"
echo ""

echo "🎯 Recommended Next Steps:"
echo "1. Get a fresh token from the GitHub UI"
echo "2. Try the manual setup commands above"
echo "3. If still failing, let's use the webhook approach instead"