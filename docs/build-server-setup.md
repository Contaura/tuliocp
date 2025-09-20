# TulioCP Build Server Setup Guide

## Self-Hosted GitHub Actions Runner

### Server Requirements
- **OS**: Ubuntu 22.04/24.04 or Debian 11/12
- **CPU**: 4+ cores (for parallel building)
- **RAM**: 8GB+ (16GB recommended)
- **Storage**: 100GB+ SSD
- **Network**: Stable connection for artifact uploads

### Setup Steps

1. **Provision Server**:
```bash
# On Ubuntu/Debian server
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git curl wget dpkg-dev
```

2. **Install GitHub Actions Runner**:
```bash
# Create runner user
sudo useradd -m -s /bin/bash github-runner
sudo su - github-runner

# Download runner (get latest URL from GitHub)
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Configure runner (requires repo admin token)
./config.sh --url https://github.com/Contaura/tuliocp --token YOUR_RUNNER_TOKEN
```

3. **Install as Service**:
```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

4. **Update Workflow**:
```yaml
# In .github/workflows/build-packages.yml
jobs:
  build-packages:
    runs-on: self-hosted  # Instead of ubuntu-latest
    labels: [linux, build-server]
```

## Alternative Build Servers

### Option 1: DigitalOcean Droplet
- **Cost**: ~$48/month (4 CPU, 8GB RAM)
- **Setup Time**: 15 minutes
- **Benefits**: Reliable, fast deployment

### Option 2: AWS EC2
- **Instance**: t3.large (2 vCPU, 8GB RAM)
- **Cost**: ~$67/month (on-demand)
- **Benefits**: Auto-scaling options

### Option 3: Hetzner Cloud
- **Server**: CPX31 (4 vCPU, 8GB RAM)
- **Cost**: ~$16/month
- **Benefits**: Very cost-effective

### Option 4: Contabo VPS
- **Server**: VPS M (6 vCPU, 16GB RAM)
- **Cost**: ~$7/month
- **Benefits**: Most cost-effective

## Quick Deployment Script

```bash
#!/bin/bash
# build-server-setup.sh

# Install dependencies
sudo apt update
sudo apt install -y \
  build-essential \
  dpkg-dev \
  git \
  curl \
  wget \
  nodejs \
  npm \
  libssl-dev \
  zlib1g-dev \
  libpcre3-dev

# Setup build environment
sudo mkdir -p /opt/tuliocp-build
sudo chown $USER:$USER /opt/tuliocp-build
cd /opt/tuliocp-build

# Clone repository
git clone https://github.com/Contaura/tuliocp.git
cd tuliocp

# Test build locally
chmod +x src/build-minimal-package.sh
./src/build-minimal-package.sh

echo "Build server ready!"
```

## Automated Package Building

### Webhook-Based Builder
Set up a webhook that triggers builds on push:

```bash
# webhook-builder.sh
#!/bin/bash
cd /opt/tuliocp-build/tuliocp
git pull origin main
./src/build-minimal-package.sh

# Upload to repository
rsync -av /tmp/*.deb user@apt.tuliocp.com:/var/www/apt/pool/main/
ssh user@apt.tuliocp.com "cd /var/www/apt && dpkg-scanpackages pool/ /dev/null > dists/stable/main/binary-amd64/Packages"
```

### Scheduled Building
```bash
# Crontab entry
0 */6 * * * /opt/tuliocp-build/webhook-builder.sh
```