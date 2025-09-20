#!/bin/bash
# Comprehensive Build Server Test Script
# Tests all aspects of TulioCP package building and deployment

set -e

echo "🔬 TulioCP Build Server Comprehensive Test"
echo "=========================================="
echo "Started at: $(date)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to run command and capture output
run_test() {
    local test_name="$1"
    local command="$2"
    local required="${3:-false}"
    
    print_status "Running: $test_name"
    echo "Command: $command"
    echo "----------------------------------------"
    
    if eval "$command"; then
        print_success "$test_name - PASSED"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            print_error "$test_name - FAILED (CRITICAL)"
            return 1
        else
            print_warning "$test_name - FAILED (NON-CRITICAL)"
            return 0
        fi
    fi
    echo ""
}

# Test 1: Environment Check
print_status "=== STEP 1: ENVIRONMENT CHECK ==="

run_test "Check OS" "lsb_release -a 2>/dev/null || cat /etc/os-release" true

run_test "Check dpkg-deb availability" "which dpkg-deb && dpkg-deb --version" true

run_test "Check build tools" "which gcc && which make && which git" true

run_test "Check Node.js" "node --version 2>/dev/null || echo 'Node.js not available'"

run_test "Check Python3" "python3 --version"

echo ""

# Test 2: Build Environment Check
print_status "=== STEP 2: BUILD ENVIRONMENT CHECK ==="

run_test "Check TulioCP build directory" "ls -la /opt/tuliocp-build/" true

run_test "Check repository clone" "ls -la /opt/tuliocp-build/tuliocp/" true

run_test "Check build script" "ls -la /opt/tuliocp-build/tuliocp/src/build-minimal-package.sh" true

run_test "Check auto-build script" "ls -la /opt/tuliocp-build/auto-build.sh"

run_test "Check deploy script" "ls -la /opt/tuliocp-build/deploy-to-repo.sh"

echo ""

# Test 3: Repository Update
print_status "=== STEP 3: REPOSITORY UPDATE ==="

run_test "Update repository" "cd /opt/tuliocp-build/tuliocp && git pull origin main"

run_test "Check latest commit" "cd /opt/tuliocp-build/tuliocp && git log --oneline -3"

echo ""

# Test 4: Package Building Test
print_status "=== STEP 4: PACKAGE BUILDING TEST ==="

# Clean previous builds
run_test "Clean previous builds" "rm -f /tmp/*.deb /tmp/tuliocp-build/* 2>/dev/null || true"

# Test build script execution
print_status "Running package build test..."
cd /opt/tuliocp-build/tuliocp

if ./src/build-minimal-package.sh; then
    print_success "Package build completed successfully!"
    
    # Check for created packages
    if ls /tmp/*.deb 1> /dev/null 2>&1; then
        print_success "Package files found:"
        ls -la /tmp/*.deb
        
        # Show package details
        for deb in /tmp/*.deb; do
            echo ""
            print_status "Package info for $(basename $deb):"
            dpkg-deb --info "$deb" | head -15
            echo "Package contents:"
            dpkg-deb --contents "$deb" | head -10
            echo "..."
        done
    else
        print_error "No package files found in /tmp/"
    fi
else
    print_error "Package build FAILED!"
fi

echo ""

# Test 5: Repository Deployment Test
print_status "=== STEP 5: REPOSITORY DEPLOYMENT TEST ==="

if [[ -f "/opt/tuliocp-build/deploy-to-repo.sh" ]]; then
    print_status "Testing repository deployment script..."
    if /opt/tuliocp-build/deploy-to-repo.sh; then
        print_success "Repository deployment test completed!"
        
        # Check repository structure
        if [[ -d "/tmp/tuliocp-repo" ]]; then
            print_status "Repository structure created:"
            find /tmp/tuliocp-repo -type f | head -20
            
            print_status "Packages file content:"
            if [[ -f "/tmp/tuliocp-repo/dists/stable/main/binary-amd64/Packages" ]]; then
                cat /tmp/tuliocp-repo/dists/stable/main/binary-amd64/Packages
            else
                print_warning "Packages file not found"
            fi
        else
            print_error "Repository directory not created"
        fi
    else
        print_error "Repository deployment script failed!"
    fi
else
    print_warning "Repository deployment script not found"
fi

echo ""

# Test 6: GitHub Actions Runner Status
print_status "=== STEP 6: GITHUB ACTIONS RUNNER STATUS ==="

if [[ -d "$HOME/actions-runner" ]]; then
    run_test "Check runner installation" "ls -la $HOME/actions-runner/"
    
    run_test "Check runner service status" "cd $HOME/actions-runner && sudo ./svc.sh status || ./svc.sh status || echo 'Service not running'"
    
    if [[ -d "$HOME/actions-runner/_diag" ]]; then
        run_test "Check recent runner logs" "cd $HOME/actions-runner && ls -la _diag/ && tail -20 _diag/Runner_*.log 2>/dev/null || echo 'No recent logs'"
    fi
else
    print_warning "GitHub Actions runner not installed in $HOME/actions-runner"
fi

echo ""

# Test 7: Network and GitHub Connectivity
print_status "=== STEP 7: NETWORK AND GITHUB CONNECTIVITY ==="

run_test "Test GitHub connectivity" "curl -I https://github.com"

run_test "Test GitHub API access" "curl -I https://api.github.com"

run_test "Test repository access" "curl -I https://github.com/Contaura/tuliocp"

run_test "Test APT repository access" "curl -I https://apt.tuliocp.com"

echo ""

# Test 8: Webhook Handler Test
print_status "=== STEP 8: WEBHOOK HANDLER TEST ==="

if [[ -f "/opt/tuliocp-build/webhook-handler.py" ]]; then
    print_status "Webhook handler found, testing Python requirements..."
    run_test "Test Python HTTP server" "python3 -c 'from http.server import HTTPServer, BaseHTTPRequestHandler; print(\"HTTP server module available\")'"
    
    print_status "Starting webhook handler test (5 second timeout)..."
    # Start webhook handler in background and test it
    cd /opt/tuliocp-build
    timeout 5s python3 webhook-handler.py &
    WEBHOOK_PID=$!
    sleep 2
    
    # Test webhook endpoint
    if curl -X POST http://localhost:8080/build 2>/dev/null; then
        print_success "Webhook handler responds to requests"
    else
        print_warning "Webhook handler test failed or timed out"
    fi
    
    # Kill webhook handler
    kill $WEBHOOK_PID 2>/dev/null || true
else
    print_warning "Webhook handler not found"
fi

echo ""

# Test 9: Permissions and Ownership
print_status "=== STEP 9: PERMISSIONS AND OWNERSHIP ==="

run_test "Check /opt/tuliocp-build ownership" "ls -la /opt/tuliocp-build"

run_test "Check script permissions" "ls -la /opt/tuliocp-build/*.sh"

run_test "Check /tmp permissions" "ls -la /tmp/ | head -5"

echo ""

# Test 10: System Resources
print_status "=== STEP 10: SYSTEM RESOURCES ==="

run_test "Check disk space" "df -h /"

run_test "Check memory usage" "free -h"

run_test "Check CPU info" "nproc && cat /proc/cpuinfo | grep 'model name' | head -1"

echo ""

# Summary
print_status "=== TEST SUMMARY ==="
echo "Test completed at: $(date)"
echo ""

print_status "Key findings:"
echo "- Build environment: $(ls -d /opt/tuliocp-build 2>/dev/null && echo 'EXISTS' || echo 'MISSING')"
echo "- Package files: $(ls /tmp/*.deb 2>/dev/null | wc -l) .deb files found"
echo "- Repository structure: $(ls -d /tmp/tuliocp-repo 2>/dev/null && echo 'CREATED' || echo 'NOT CREATED')"
echo "- GitHub runner: $(ls -d $HOME/actions-runner 2>/dev/null && echo 'INSTALLED' || echo 'NOT INSTALLED')"
echo ""

print_status "Next steps based on results:"
echo "1. If packages were built: Check GitHub Actions integration"
echo "2. If packages failed: Fix build environment issues"
echo "3. If repository created: Test deployment to GitHub Pages"
echo "4. If everything works: Set up automated deployment"
echo ""

print_success "Test script completed! Review the output above for issues."