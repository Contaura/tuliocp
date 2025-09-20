#!/bin/bash
# TulioCP APT Repository Setup Script
# https://apt.tuliocp.com/setup.sh
# Updated with intelligent package detection and auto-fallback to direct installer
# Last updated: 2025-09-20 18:20 - Fixed --force flag handling

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 TulioCP APT Repository Setup${NC}"
echo "=================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Check if running on supported OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo -e "${RED}❌ Cannot detect operating system${NC}"
    exit 1
fi

# Check OS compatibility
case $OS in
    ubuntu)
        case $VERSION in
            "20.04"|"22.04"|"24.04")
                echo -e "${GREEN}✅ Ubuntu $VERSION detected - supported${NC}"
                ;;
            *)
                echo -e "${YELLOW}⚠️  Ubuntu $VERSION may not be fully supported${NC}"
                echo -e "${YELLOW}   Officially supported: 20.04, 22.04, 24.04 LTS${NC}"
                ;;
        esac
        ;;
    debian)
        case $VERSION in
            "10"|"11"|"12")
                echo -e "${GREEN}✅ Debian $VERSION detected - supported${NC}"
                ;;
            *)
                echo -e "${YELLOW}⚠️  Debian $VERSION may not be fully supported${NC}"
                echo -e "${YELLOW}   Officially supported: 10, 11, 12${NC}"
                ;;
        esac
        ;;
    *)
        echo -e "${RED}❌ Unsupported operating system: $OS${NC}"
        echo -e "${RED}   Supported: Ubuntu 20.04/22.04/24.04 LTS, Debian 10/11/12${NC}"
        exit 1
        ;;
esac

# Check architecture
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" != "amd64" ]; then
    echo -e "${RED}❌ Unsupported architecture: $ARCH${NC}"
    echo -e "${RED}   Only amd64 (x86_64) is currently supported${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Architecture: $ARCH - supported${NC}"

# Update package lists
echo -e "${BLUE}📦 Updating package lists...${NC}"
apt-get update > /dev/null 2>&1

# Install required packages
echo -e "${BLUE}🔧 Installing required packages...${NC}"
apt-get install -y curl ca-certificates gnupg lsb-release > /dev/null 2>&1

# Add TulioCP APT repository
echo -e "${BLUE}📋 Adding TulioCP APT repository...${NC}"

# Create sources.list.d entry
echo "deb https://apt.tuliocp.com stable main" > /etc/apt/sources.list.d/tuliocp.list

# Update package lists again
echo -e "${BLUE}🔄 Updating package lists with TulioCP repository...${NC}"
apt-get update > /dev/null 2>&1 || {
    echo -e "${YELLOW}⚠️  APT update completed with warnings (unsigned repository)${NC}"
}

echo ""
echo -e "${GREEN}✅ TulioCP APT repository setup complete!${NC}"
echo ""
# Check if tuliocp package is available
echo -e "${BLUE}🔍 Checking package availability...${NC}"
if apt-cache show tuliocp > /dev/null 2>&1; then
    echo -e "${GREEN}✅ TulioCP package is available in repository${NC}"
    echo ""
    echo -e "${BLUE}📋 Install TulioCP:${NC}"
    echo -e "   ${YELLOW}sudo apt install --allow-unauthenticated tuliocp${NC}"
else
    echo -e "${YELLOW}⚠️  TulioCP package not yet available in repository${NC}"
    echo -e "${BLUE}🔄 Automatically using direct installer instead...${NC}"
    echo ""
    
    # Download and run the installer directly
    echo -e "${BLUE}📥 Downloading TulioCP installer...${NC}"
    if curl -sSL https://raw.githubusercontent.com/contaura/tuliocp/main/install/hst-install.sh -o /tmp/hst-install.sh; then
        echo -e "${GREEN}✅ Installer downloaded successfully${NC}"
        echo -e "${BLUE}🚀 Running TulioCP installer with --force flag...${NC}"
        echo -e "${YELLOW}   (This will handle any existing admin users/groups automatically)${NC}"
        echo ""
        bash /tmp/hst-install.sh --force
        exit 0
    else
        echo -e "${RED}❌ Failed to download installer${NC}"
        echo -e "${YELLOW}📋 Manual installation steps:${NC}"
        echo -e "   ${YELLOW}wget https://raw.githubusercontent.com/contaura/tuliocp/main/install/hst-install.sh${NC}"
        echo -e "   ${YELLOW}sudo bash hst-install.sh${NC}"
    fi
fi
echo ""
echo -e "${BLUE}ℹ️  Repository Information:${NC}"
echo -e "   • Repository: https://apt.tuliocp.com/"
echo -e "   • Package: tuliocp (1.8MB)"
echo -e "   • Status: Unsigned (requires --allow-unauthenticated)"
echo -e "   • Support: https://github.com/contaura/tuliocp"
echo ""
echo -e "${YELLOW}📝 Note: The repository is currently unsigned. GPG signing will be${NC}"
echo -e "${YELLOW}   implemented in a future update for enhanced security.${NC}"