# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

TulioCP is an open-source Linux web server control panel. It's a comprehensive hosting control panel that provides web, mail, DNS, and database management capabilities with a modern web interface and extensive CLI toolkit.

### Key Features

- Apache2 and NGINX with PHP-FPM support (PHP 5.6-8.4)
- DNS Server (Bind) with clustering capabilities
- POP/IMAP/SMTP mail services with Anti-Virus, Anti-Spam, and Webmail
- MariaDB/MySQL and PostgreSQL databases
- Let's Encrypt SSL support with wildcard certificates
- Firewall with brute-force detection (iptables, fail2ban, ipset)

## Development Commands

### Building and Assets

```bash
# Install dependencies and setup development environment
npm ci --ignore-scripts
npm run prepare # Sets up Husky git hooks

# Build JavaScript and CSS assets
npm run build # Builds all JS/CSS using esbuild and Lightning CSS
node build.js # Direct build script execution

# Development server for documentation
npm run docs:dev   # Start VitePress dev server
npm run docs:build # Build documentation
npm run docs:serve # Serve built documentation
npm run docs:test  # Run documentation tests
```

### Linting and Code Quality

```bash
# Run all lints (includes Prettier, Biome, Stylelint, and Markdownlint)
npm run lint

# Individual linting tools
npx prettier --check .                  # Check code formatting
npx prettier --write .                  # Format code
npx biome lint .                        # JavaScript/TypeScript linting
npx stylelint web/css/src/**/*.css      # CSS linting
npx markdownlint-cli2 *.md docs/**/*.md # Markdown linting

# Format code automatically
npm run format

# Pre-commit hooks (automatically run on commit)
npm run lint-staged
```

### Testing

```bash
# Run BATS test suite (requires TulioCP installation)
./test/test.bats         # Main comprehensive test suite
./test/api.bats          # API functionality tests
./test/checks.bats       # System checks and validation
./test/config-tests.bats # Configuration tests
./test/letsencrypt.bats  # SSL certificate tests
./test/restore.bats      # Backup/restore tests
./test/wildcard.bats     # Wildcard SSL tests

# Shell script validation
./test/shellcheck.sh  # Run ShellCheck on shell scripts
./test/lint_script.sh # Custom script linting
```

### Building Packages

```bash
# Build DEB packages (requires Debian/Ubuntu environment)
./src/hst_autocompile.sh --tuliocp --debug --cross --noinstall --keepbuild

# Generate CLI documentation
./src/hst_generate_clidocs.sh

# LXD/Container builds
./src/lxd_build_all.sh # Build for all supported distributions
./src/lxd_compile.sh   # Single container build
```

## Architecture Overview

### Directory Structure

- **`/bin/`** - CLI commands (500+ v-\* scripts for all system operations)
  - `v-add-*` - Add/create operations (users, domains, databases, etc.)
  - `v-delete-*` - Delete operations
  - `v-list-*` - List/query operations
  - `v-update-*` - Update/modify operations
  - `v-suspend-*` / `v-unsuspend-*` - Suspension management

- **`/func/`** - Core shell function libraries
  - `main.sh` - Core functions, error handling, logging, OS detection
  - `domain.sh` - Web domain management functions
  - `db.sh` - Database operations
  - `backup.sh` - Backup and restore functionality
  - `syshealth.sh` - System monitoring and health checks

- **`/web/`** - Web interface (PHP-based control panel)
  - `/add/`, `/edit/`, `/delete/` - CRUD operation pages
  - `/list/` - Listing pages for all resources
  - `/inc/` - PHP includes and core web logic
  - `/js/src/` - Frontend JavaScript (Alpine.js, Chart.js, xterm)
  - `/css/src/` - Stylesheets (Lightning CSS processed)
  - `/locale/` - Multi-language translations

- **`/install/`** - Installation and upgrade scripts
  - `/deb/` - Debian/Ubuntu specific installers
  - `/common/` - Cross-platform installation logic

- **`/test/`** - BATS test suite for comprehensive system testing

- **`/src/`** - Build scripts and development utilities

### Core Architecture Patterns

**CLI-First Design**: Every web interface operation corresponds to a CLI command in `/bin/`. The web interface primarily calls these CLI scripts, ensuring consistency between web and command-line usage.

**Shell Script Foundation**: Core system operations are implemented in Bash with extensive error handling, logging, and validation. The `func/main.sh` provides shared utilities for all scripts.

**Modular Function Libraries**: Common functionality is centralized in `/func/` libraries that are sourced by CLI commands, promoting code reuse and maintainability.

**Configuration-Based**: System configuration stored in `/etc/tuliocp/tulio.conf` with user-specific data in `/usr/local/tulio/data/users/`.

**Template System**: Web server configurations use templates in `/usr/local/tulio/data/templates/` for Apache, Nginx, DNS, and mail server configurations.

## Frontend Build System

### JavaScript Build Process

- **Tool**: esbuild for fast bundling and minification
- **Entry Point**: `web/js/src/index.js`
- **Output**: `web/js/dist/main.min.js` (bundled) + individual external packages
- **External Packages**: Chart.js, Alpine.js, xterm, etc. built separately for optimal loading

### CSS Build Process

- **Tool**: Lightning CSS for processing and optimization
- **Source**: `web/css/src/themes/*.css` (multiple themes)
- **Output**: `web/css/themes/*.min.css` with source maps
- **Features**: CSS nesting, custom media queries, automatic browser targeting

### Key Dependencies

- **Frontend**: Alpine.js (reactive), Chart.js (statistics), xterm.js (terminal), Floating Vue (tooltips)
- **Build**: esbuild (JS), Lightning CSS (CSS), Browserslist (targets)
- **Quality**: Biome (JS linting), Stylelint (CSS), Prettier (formatting), Markdownlint (docs)

## Branch Strategy

- **`main`** - Development branch with latest features (not production-ready)
- **`beta`** - Testing branch for next version (stable but not production)
- **`release`** - Production-ready code matching official packages

Always create feature branches from `main` using the naming convention:

- `feature/issue-description` or `feature/123-new-feature`
- `fix/issue-description` or `fix/123-bug-fix`
- `refactor/component-name`

## Code Quality Standards

### Shell Scripts

- Follow existing patterns in `/func/main.sh` for error handling
- Use `check_result()` function for consistent error reporting
- Source required function libraries at script start
- Include proper logging with `log_event()` and `log_history()`

### Frontend Code

- Use Alpine.js patterns for interactive components
- Maintain ES modules structure for JavaScript
- Follow existing CSS naming conventions and nesting patterns
- Ensure responsive design compatibility

### Testing Requirements

- Add BATS tests for new CLI commands in `/test/`
- Test both success and failure scenarios
- Include validation functions for domain, mail, and database operations
- Ensure tests can run in CI/CD environments

## Development Environment Setup

TulioCP development requires understanding both the control panel codebase and the underlying system it manages. For full functionality testing:

1. **Local Development**: Use the Node.js build system for frontend asset development
2. **System Testing**: Requires a Linux environment (Debian/Ubuntu) with TulioCP installed
3. **Container Testing**: Use LXD build scripts for isolated testing environments

The codebase follows a traditional server administration tool architecture with extensive shell scripting, making it essential to understand both modern web development practices and system administration concepts.
