#!/bin/bash

# ======================================================== #
#
# TulioCP Development Installer
# For development and testing environments only
# https://github.com/contaura/tuliocp
#
# ======================================================== #

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Environment variables
REPO_DIR="$(pwd)"
DEV_DIR="$HOME/.local/share/tuliocp-dev"
LOG_FILE="$DEV_DIR/dev-install.log"

# Create development directory
mkdir -p "$DEV_DIR"

# Logging function
log() {
	echo -e "$1" | tee -a "$LOG_FILE"
}

log "${BLUE}========================================================================${NC}"
log "${BLUE}                        TulioCP Development Setup${NC}"
log "${BLUE}                           $(date)${NC}"
log "${BLUE}========================================================================${NC}"

log "${YELLOW}Repository Directory: ${REPO_DIR}${NC}"
log "${YELLOW}Development Directory: ${DEV_DIR}${NC}"
log "${YELLOW}Log File: ${LOG_FILE}${NC}"
log ""

# Check if we're in the right directory
if [[ ! -f "package.json" || ! -d "web" || ! -d "bin" ]]; then
	log "${RED}❌ Error: This script must be run from the TulioCP repository root${NC}"
	log "${RED}   Make sure you're in the directory containing package.json, web/, and bin/ folders${NC}"
	exit 1
fi

log "${GREEN}✅ Repository structure verified${NC}"

# Check Node.js
if ! command -v node &> /dev/null; then
	log "${RED}❌ Error: Node.js is required but not installed${NC}"
	exit 1
fi

NODE_VERSION=$(node --version)
log "${GREEN}✅ Node.js found: ${NODE_VERSION}${NC}"

# Install dependencies if needed
if [[ ! -d "node_modules" ]]; then
	log "${YELLOW}📦 Installing Node.js dependencies...${NC}"
	npm ci --ignore-scripts || {
		log "${RED}❌ Error: Failed to install Node.js dependencies${NC}"
		exit 1
	}
	log "${GREEN}✅ Dependencies installed${NC}"
else
	log "${GREEN}✅ Node.js dependencies already installed${NC}"
fi

# Setup git hooks
log "${YELLOW}🔧 Setting up development tools...${NC}"
npm run prepare || {
	log "${YELLOW}⚠️  Warning: Failed to setup git hooks${NC}"
}

# Build frontend assets
log "${YELLOW}🏗️  Building frontend assets...${NC}"
npm run build || {
	log "${RED}❌ Error: Failed to build frontend assets${NC}"
	exit 1
}
log "${GREEN}✅ Frontend assets built successfully${NC}"

# Create development configuration
DEV_CONFIG="$DEV_DIR/tulio-dev.conf"
log "${YELLOW}📝 Creating development configuration...${NC}"

cat > "$DEV_CONFIG" << EOF
# TulioCP Development Configuration
# Generated on $(date)

# Repository paths
TULIO_REPO_DIR="$REPO_DIR"
TULIO_DEV_DIR="$DEV_DIR"

# Development settings
TULIO_MODE="development"
TULIO_DEBUG="true"
TULIO_LOG_LEVEL="debug"

# Web paths (for local development)
TULIO_WEB_ROOT="$REPO_DIR/web"
TULIO_TEMPLATES_DIR="$REPO_DIR/install/common/templates"

# Backend settings (not active in dev mode)
TULIO_BIN_DIR="$REPO_DIR/bin"
TULIO_FUNC_DIR="$REPO_DIR/func"

EOF

# Create development script shortcuts
log "${YELLOW}🔗 Creating development shortcuts...${NC}"

# Build shortcut
cat > "$DEV_DIR/build.sh" << EOF
#!/bin/bash
cd "$REPO_DIR"
echo "🏗️  Building TulioCP assets..."
npm run build
echo "✅ Build complete!"
EOF
chmod +x "$DEV_DIR/build.sh"

# Lint shortcut
cat > "$DEV_DIR/lint.sh" << EOF
#!/bin/bash
cd "$REPO_DIR"
echo "🔍 Running linters..."
npm run lint
EOF
chmod +x "$DEV_DIR/lint.sh"

# Format shortcut
cat > "$DEV_DIR/format.sh" << EOF
#!/bin/bash
cd "$REPO_DIR"
echo "✨ Formatting code..."
npm run format
echo "✅ Formatting complete!"
EOF
chmod +x "$DEV_DIR/format.sh"

# Docs development server
cat > "$DEV_DIR/docs-dev.sh" << EOF
#!/bin/bash
cd "$REPO_DIR"
echo "📚 Starting documentation development server..."
npm run docs:dev
EOF
chmod +x "$DEV_DIR/docs-dev.sh"

# Create development status script
cat > "$DEV_DIR/status.sh" << EOF
#!/bin/bash
source "$DEV_DIR/tulio-dev.conf"

echo "========================================================================="
echo "                        TulioCP Development Status"
echo "========================================================================="
echo "Repository: $TULIO_REPO_DIR"
echo "Development Dir: $TULIO_DEV_DIR"
echo "Mode: $TULIO_MODE"
echo ""
echo "Frontend Assets:"
if [[ -f "$TULIO_REPO_DIR/web/js/dist/main.min.js" ]]; then
    echo "  ✅ JavaScript build found"
else
    echo "  ❌ JavaScript build missing"
fi

if [[ -d "$TULIO_REPO_DIR/web/css/themes" ]] && [[ $(ls -1 "$TULIO_REPO_DIR/web/css/themes"/*.min.css 2> /dev/null | wc -l) -gt 0 ]]; then
    echo "  ✅ CSS themes built ($(ls -1 "$TULIO_REPO_DIR/web/css/themes"/*.min.css | wc -l) themes)"
else
    echo "  ❌ CSS themes missing"
fi

echo ""
echo "Development Commands:"
echo "  Build:     $TULIO_DEV_DIR/build.sh"
echo "  Lint:      $TULIO_DEV_DIR/lint.sh"
echo "  Format:    $TULIO_DEV_DIR/format.sh"
echo "  Docs Dev:  $TULIO_DEV_DIR/docs-dev.sh"
echo "  Status:    $TULIO_DEV_DIR/status.sh"
echo ""
EOF
chmod +x "$DEV_DIR/status.sh"

log "${GREEN}✅ Development shortcuts created in: ${DEV_DIR}${NC}"

# Add to PATH suggestion
if ! echo "$PATH" | grep -q "$DEV_DIR"; then
	log "${YELLOW}💡 Tip: Add development tools to your PATH:${NC}"
	log "${YELLOW}   echo 'export PATH=\"\$PATH:${DEV_DIR}\"' >> ~/.bashrc${NC}"
	log "${YELLOW}   source ~/.bashrc${NC}"
fi

log ""
log "${GREEN}========================================================================${NC}"
log "${GREEN}                    TulioCP Development Setup Complete!${NC}"
log "${GREEN}========================================================================${NC}"
log ""
log "${BLUE}🎉 Development environment ready!${NC}"
log ""
log "${YELLOW}Quick start:${NC}"
log "  • Run ${GREEN}$DEV_DIR/status.sh${NC} to check status"
log "  • Run ${GREEN}$DEV_DIR/build.sh${NC} to rebuild assets"
log "  • Run ${GREEN}$DEV_DIR/docs-dev.sh${NC} to start docs server"
log "  • Run ${GREEN}npm run lint${NC} to check code quality"
log ""
log "${YELLOW}Development features enabled:${NC}"
log "  ✅ Frontend asset building (JS + CSS)"
log "  ✅ Code formatting and linting"
log "  ✅ Documentation development server"
log "  ✅ Git hooks for quality checks"
log ""
log "${BLUE}Repository: ${REPO_DIR}${NC}"
log "${BLUE}Config: ${DEV_CONFIG}${NC}"
log "${BLUE}Logs: ${LOG_FILE}${NC}"
log ""
