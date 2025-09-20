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

## Installing Tulio Control Panel

- **NOTE:** You must install Tulio Control Panel on top of a fresh operating system installation to ensure proper functionality.

While we have taken every effort to make the installation process and the control panel interface as friendly as possible (even for new users), it is assumed that you will have some prior knowledge and understanding in the basics how to set up a Linux server before continuing.

### Step 1: Log in

To start the installation, you will need to be logged in as **root** or a user with super-user privileges. You can perform the installation either directly from the command line console or remotely via SSH:

```bash
ssh root@your.server
```

### Step 2: Download

Download the installation script for the latest release:

```bash
wget https://raw.githubusercontent.com/Contaura/tuliocp/refs/heads/main/install/hst-install.sh
```

If the download fails due to an SSL validation error, please be sure you've installed the ca-certificate package on your system - you can do this with the following command:

```bash
apt-get update && apt-get install ca-certificates
```

### Step 3: Run

To begin the installation process, simply run the script and follow the on-screen prompts:

```bash
bash hst-install.sh
```

You will receive a welcome email at the address specified during installation (if applicable) and on-screen instructions after the installation is completed to log in and access your server.

### Custom installation

You may specify a number of various flags during installation to only install the features in which you need. To view a list of available options, run:

```bash
bash hst-install.sh -h
```

## How to upgrade an existing installation

Automatic Updates are enabled by default on new installations of Tulio Control Panel and can be managed from **Server Settings > Updates**. To manually check for and install available updates, use the apt package manager:

```bash
apt-get update
apt-get upgrade
```

## Documentation

For detailed installation guides, configuration instructions, and troubleshooting:

- 📚 [Installation Guide](#installing-tulio-control-panel) - See above for quick start
- 🔧 [Configuration Reference](docs/) - Detailed setup and configuration guides  
- 🐛 [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- 🚀 [Quick Start Examples](#custom-installation) - Command line installation options

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
