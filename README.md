<h1 align="center">Tulio Control Panel</h1>

<p align="center">
  <img src="web/images/logo-tulio.svg" alt="TulioCP Logo" width="120" height="120">
</p>

<h2 align="center">Lightweight and powerful control panel for the modern web</h2>

<p align="center">
  <a href="https://github.com/contaura/tuliocp/releases/latest">
    <img src="https://img.shields.io/github/release/contaura/tuliocp.svg" alt="Latest Release"/>
  </a>
  <a href="https://github.com/contaura/tuliocp/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-GPL%20v3-blue.svg" alt="License"/>
  </a>
  <a href="https://github.com/contaura/tuliocp/stargazers">
    <img src="https://img.shields.io/github/stars/contaura/tuliocp.svg" alt="Stars"/>
  </a>
</p>

## **Welcome!**

Tulio Control Panel is designed to provide administrators an easy to use web and command line interface, enabling them to quickly deploy and manage web domains, mail accounts, DNS zones, and databases from one central dashboard without the hassle of manually deploying and configuring individual components or services.

## Support the Project

If you find TulioCP useful and would like to support its development, please consider:

- ⭐ Starring this repository on GitHub
- 🐛 Reporting bugs and issues
- 📝 Contributing to documentation
- 💻 Submitting pull requests

## Features and Services

- Apache2 and NGINX with PHP-FPM
- Multiple PHP versions (5.6 - 8.4, 8.3 as default)
- DNS Server (Bind) with clustering capabilities
- POP/IMAP/SMTP mail services with Anti-Virus, Anti-Spam, and Webmail (ClamAV, SpamAssassin, Sieve, Roundcube)
- MariaDB/MySQL and/or PostgreSQL databases
- Let's Encrypt SSL support with wildcard certificates
- Firewall with brute-force attack detection and IP lists (iptables, fail2ban, and ipset).

## Supported platforms and operating systems

- **Debian:** 12, 11
- **Ubuntu:** 24.04 LTS, 22.04 LTS, 20.04 LTS

**NOTES:**

- Tulio Control Panel does not support 32 bit operating systems!
- Tulio Control Panel in combination with OpenVZ 7 or lower might have issues with DNS and/or firewall. If you use a Virtual Private Server we strongly advice you to use something based on KVM or LXC!

## 📦 TulioCP APT Repository

**Live Repository**: https://apt.tuliocp.com/

TulioCP provides an official APT repository for easy installation and updates. Our packages are automatically built from the latest source code and deployed to GitHub Pages.

### 🎯 Quick Installation

**Method 1: One-Line Installation (Recommended)**
```bash
curl -sSL https://apt.tuliocp.com/setup.sh | sudo bash
```

**Method 2: Direct Installer**
```bash
wget https://raw.githubusercontent.com/contaura/tuliocp/main/install/hst-install.sh
sudo bash hst-install.sh
```

### 📋 Available Packages

- **tuliocp** - Main control panel package (1.8MB) - **Available Now**
- **tulio-nginx** - Custom Nginx build optimized for TulioCP - *Coming Soon*
- **tulio-php** - Custom PHP-FPM build with enhanced performance - *Coming Soon*
- **tulio-web-terminal** - Browser-based terminal interface - *Coming Soon*

### 🔧 Manual Repository Setup

To manually add the TulioCP APT repository (not needed for standard installation):

```bash
# Add TulioCP repository
echo "deb https://apt.tuliocp.com stable main" | sudo tee /etc/apt/sources.list.d/tuliocp.list

# Update package lists (ignore signature warnings for now)
sudo apt update

# Install TulioCP (temporary: allow unauthenticated until GPG signing is implemented)
sudo apt install --allow-unauthenticated tuliocp
```

**Note**: The repository is currently unsigned. GPG signing will be implemented in a future update.

### 🏗️ System Requirements

- **Operating Systems**: Debian 10/11/12, Ubuntu 20.04/22.04/24.04 LTS
- **Architecture**: amd64 (x86_64) - *arm64 coming soon*
- **Memory**: Minimum 1GB RAM (2GB+ recommended)
- **Storage**: 10GB+ available disk space
- **Network**: Internet connection for package installation
- **Access**: Root or sudo privileges required

### 🚀 Automated Build & Deployment System

**Repository URL**: https://apt.tuliocp.com/  
**Build Status**: ✅ Fully Operational

Our automated build system provides:

#### 📦 **Package Building**
- **Trigger**: Every push to `main` branch
- **Build Server**: Self-hosted runner with TulioCP dependencies
- **Process**: Automated DEB package compilation
- **Output**: Production-ready `tuliocp_1.10.0~alpha_amd64.deb` packages

#### 🔒 **Secure Deployment**
- **Webhook**: HTTPS webhook handler (port 8443)
- **Authentication**: GitHub token-based secure deployment
- **Target**: GitHub Pages with custom domain
- **Structure**: Full Debian APT repository format

#### 🌐 **Live Repository Features**
- **Custom Domain**: https://apt.tuliocp.com (via CNAME to contaura.github.io)
- **Modern Interface**: Professional repository page with copy-to-clipboard commands
- **Package Metadata**: Complete `Packages.gz` and `Release` files
- **Automatic Updates**: New commits automatically trigger rebuilds

## 🚀 Installing TulioCP

**⚠️ Important**: Install TulioCP on a fresh operating system for optimal functionality.

### 🔑 Prerequisites

- **Server Access**: Root or sudo privileges
- **Fresh OS**: Clean Debian/Ubuntu installation recommended
- **Network**: Stable internet connection
- **Basic Knowledge**: Understanding of Linux server administration

### 🚀 Quick Installation

**Method 1: One-Line Installation (Recommended)**
```bash
curl -sSL https://apt.tuliocp.com/setup.sh | sudo bash
```

**Method 2: Direct Installation**
```bash
# Download and run installer
wget https://raw.githubusercontent.com/contaura/tuliocp/main/install/hst-install.sh
sudo bash hst-install.sh
```

**Method 3: Manual APT Repository Setup**
```bash
# Manual repository configuration
echo "deb https://apt.tuliocp.com stable main" | sudo tee /etc/apt/sources.list.d/tuliocp.list
sudo apt update
sudo apt install --allow-unauthenticated tuliocp
```

### 🔧 Connection Methods

**Local Console:**
```bash
sudo bash hst-install.sh
```

**Remote SSH:**
```bash
ssh root@your.server
wget https://raw.githubusercontent.com/contaura/tuliocp/main/install/hst-install.sh
bash hst-install.sh
```

**SSL Certificate Issues:**
```bash
# If download fails due to SSL validation
sudo apt update && sudo apt install ca-certificates
```

### ✨ Post-Installation

- Welcome email sent to specified address (if configured)
- On-screen login instructions provided
- Web interface accessible via server IP/domain
- Default admin credentials displayed in terminal

### 🔧 Custom Installation Options

View available installation flags and options:

```bash
bash hst-install.sh -h
```

Common options:
- `--interactive` - Interactive installation with prompts
- `--force` - Skip compatibility checks
- `--hostname` - Set custom hostname
- `--email` - Set admin email address

## 🔄 Upgrading TulioCP

### 🤖 Automatic Updates

- **Default**: Enabled on new installations
- **Management**: Server Settings → Updates
- **Schedule**: Configurable update intervals

### 🔧 Manual Updates

**Via APT (Recommended):**
```bash
# Update package lists and upgrade TulioCP
sudo apt update && sudo apt upgrade tuliocp
```

**Traditional Method:**
```bash
# System-wide updates (includes TulioCP)
sudo apt update && sudo apt upgrade
```

## 💻 Development Environment

### 🚀 Quick Development Setup

**Prerequisites:**
- Node.js 18+ (tested with v22.19.0)
- Git
- macOS/Linux development environment

**One-Command Setup:**
```bash
# Clone repository and setup development environment
git clone https://github.com/contaura/tuliocp.git
cd tuliocp
./dev-installer.sh
```

### 🛠️ Development Features

The development environment provides:

- **Frontend Build System**: esbuild + Lightning CSS for fast asset compilation
- **Code Quality**: Prettier, Biome, Stylelint, Markdownlint with git hooks
- **Development Server**: VitePress documentation server
- **Build Monitoring**: Real-time status and asset tracking
- **Quality Checks**: Pre-commit hooks for code formatting and linting

### 📦 Frontend Asset Building

**Build all assets:**
```bash
npm run build
```

**Build outputs:**
- `web/js/dist/main.min.js` - Main application bundle
- `web/js/dist/*.min.js` - External packages (Alpine.js, Chart.js, xterm, etc.)
- `web/css/themes/*.min.css` - CSS themes with source maps

**Supported themes:** `dark`, `default`, `flat`, `vestia`

### 🔧 Development Commands

```bash
# Install dependencies
npm ci --ignore-scripts

# Build frontend assets
npm run build

# Run all linters
npm run lint

# Format code
npm run format

# Start documentation server
npm run docs:dev

# Run tests
npm run docs:test
```

### 📋 Development Shortcuts

After running `./dev-installer.sh`, you get convenient shortcuts:

```bash
# Check development status
~/.local/share/tuliocp-dev/status.sh

# Quick rebuild
~/.local/share/tuliocp-dev/build.sh

# Code quality check
~/.local/share/tuliocp-dev/lint.sh

# Format all code
~/.local/share/tuliocp-dev/format.sh

# Start docs server
~/.local/share/tuliocp-dev/docs-dev.sh
```

### 🔍 Environment Debugging

**Verify setup:**
```bash
./debug-installer.sh
```

**Check build status:**
```bash
~/.local/share/tuliocp-dev/status.sh
```

### 🏗️ Frontend Architecture

**JavaScript Build:**
- **Tool**: esbuild for fast bundling and minification
- **Entry**: `web/js/src/index.js`
- **Output**: Bundled main.min.js + separate external packages
- **Features**: Source maps, tree shaking, ES modules

**CSS Build:**
- **Tool**: Lightning CSS for processing and optimization
- **Source**: `web/css/src/themes/*.css`
- **Output**: Minified themes with browser targeting
- **Features**: CSS nesting, custom media queries, autoprefixer

**Key Dependencies:**
- **Frontend**: Alpine.js (reactive), Chart.js (statistics), xterm.js (terminal)
- **Build**: esbuild (JS), Lightning CSS (CSS), Browserslist (targets)
- **Quality**: Biome (JS linting), Stylelint (CSS), Prettier (formatting)

### 🔄 Development vs Production

**Development Mode** (macOS/Linux):
- Use `dev-installer.sh` for local development
- Frontend asset building and live reloading
- Code quality tools and git hooks
- Documentation development server

**Production Mode** (Ubuntu/Debian):
- Use `hst-install.sh` for server deployment  
- Full system installation with services
- Web server configuration (Apache + Nginx)
- Database, mail, and DNS server setup

### 🧪 Testing & Quality

**Linting Tools:**
- **JavaScript**: Biome for fast linting and formatting
- **CSS**: Stylelint with standard configuration
- **PHP**: Prettier with PHP plugin
- **Shell**: Prettier with shell script support
- **Markdown**: Markdownlint for documentation

**Git Hooks:**
- **Pre-commit**: Runs linting and formatting on staged files
- **Pre-push**: Additional validation (configurable)

**Quality Standards:**
- All code must pass linting before commit
- Automatic formatting applied on staged files
- Documentation linting for README and docs
- Shell script validation

## Documentation

For detailed installation guides, configuration instructions, and troubleshooting:

- 📚 [Installation Guide](#installing-tulio-control-panel) - See above for quick start
- 🔧 [Configuration Reference](docs/) - Detailed setup and configuration guides  
- 🐛 [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- 🚀 [Quick Start Examples](#custom-installation) - Command line installation options
- 💻 [Development Setup](#development-environment) - Local development environment

## Community & Support

- 💬 [GitHub Discussions](https://github.com/contaura/tuliocp/discussions) - General questions and community help
- 🐛 [Issue Tracker](https://github.com/contaura/tuliocp/issues) - Bug reports and feature requests
- 📖 [Wiki](https://github.com/contaura/tuliocp/wiki) - Community documentation

## Issues & Support Requests

- If you encounter a general problem while using Tulio Control Panel and need help, please search existing issues or start a discussion on GitHub.
- Bugs and other reproducible issues should be filed via GitHub by [creating a new issue report](https://github.com/contaura/tuliocp/issues) so that our developers can investigate further. Please note that requests for support will be redirected to our forum.

**IMPORTANT: We _cannot_ provide support for requests that do not describe the troubleshooting steps that have already been performed, or for third-party applications not related to Tulio Control Panel (such as WordPress). Please make sure that you include as much information as possible in your issue reports!**

## Contributions

If you would like to contribute to the project, please [read our Contribution Guidelines](https://github.com/contaura/tuliocp/blob/main/CONTRIBUTING.md) for a brief overview of our development process and standards.

## Copyright

"Tulio Control Panel", "TulioCP", and the Tulio logo are original copyright of tuliocp.com and the following restrictions apply:

**You are allowed to:**

- use the names "Tulio Control Panel", "TulioCP", or the Tulio logo in any context directly related to the application or the project. This includes the application itself, local communities and news or blog posts.

**You are not allowed to:**

- sell or redistribute the application under the name "Tulio Control Panel", "TulioCP", or similar derivatives, including the use of the Tulio logo in any brand or marketing materials related to revenue generating activities,
- use the names "Tulio Control Panel", "TulioCP", or the Tulio logo in any context that is not related to the project,
- alter the name "Tulio Control Panel", "TulioCP", or the Tulio logo in any way.

## License

Tulio Control Panel is licensed under [GPL v3](https://github.com/contaura/tuliocp/blob/main/LICENSE) license.

