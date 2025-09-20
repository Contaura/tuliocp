#!/bin/bash

# Debug script to check TulioCP installation environment
echo "========================================================================="
echo "                        TulioCP Debug Information"
echo "========================================================================="

echo "Current working directory: $(pwd)"
echo "Script location: $0"
echo "Operating System: $(uname -a)"
echo

# Check if we're in the correct source directory
echo "Checking source directory structure..."
if [ -d "$(pwd)/bin" ]; then
	echo "✓ bin directory found"
	echo "  - Contains $(ls $(pwd)/bin | wc -l) files"
else
	echo "✗ bin directory missing"
fi

if [ -d "$(pwd)/install" ]; then
	echo "✓ install directory found"
	echo "  - Contains: $(ls $(pwd)/install)"
else
	echo "✗ install directory missing"
fi

if [ -d "$(pwd)/install/common" ]; then
	echo "✓ install/common directory found"
	echo "  - Contains: $(ls $(pwd)/install/common)"
else
	echo "✗ install/common directory missing"
fi

if [ -d "$(pwd)/install/deb" ]; then
	echo "✓ install/deb directory found"
	echo "  - Contains: $(ls $(pwd)/install/deb)"
else
	echo "✗ install/deb directory missing"
fi

echo
echo "Checking system requirements..."
echo "- User: $(whoami)"
echo "- Root access: $([ $(id -u) -eq 0 ] && echo "YES" || echo "NO")"
echo "- Package manager: $(which apt-get > /dev/null 2>&1 && echo "APT found" || echo "APT not found")"

if [ -e "/etc/os-release" ]; then
	echo "- OS Release info:"
	cat /etc/os-release | head -5
else
	echo "- OS Release: Not available"
fi

echo
echo "Environment variables:"
echo "- TULIO would be set to: /usr/local/tulio"
echo "- TULIO_INSTALL_DIR would be: $(pwd)/install/deb"
echo "- TULIO_COMMON_DIR would be: $(pwd)/install/common"

echo
echo "========================================================================="
echo "Debug complete. Run this script to verify your installation environment."
echo "========================================================================="
