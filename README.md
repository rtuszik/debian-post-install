# Debian Bootstrap Script

This script is designed to automate the post-installation setup for Debian systems. It updates the system, installs essential packages, configures the SSH service, adjusts user permissions, sets up Debian-specific configurations, and installs commonly used packages including Docker.

## Easy Install w/ wget

To download and execute the script in one step, use the following command:

```sh
wget -O bootstrap.sh "https://raw.githubusercontent.com/rtuszik/debian-post-install/main/bootstrap.sh" && sh bootstrap.sh
```

## Installed Packages and Utilities

This script automates the installation of essential packages and utilities, enhancing the functionality and security of your Debian system. Below is a list of what the script installs:

- Basic Utilities:
  - [`wget`](https://www.gnu.org/software/wget/) - A utility for non-interactive download of files from the web.
  - [`gpg`](https://github.com/gpg/gnupg) - A free implementation of the OpenPGP standard.
  - [`sudo`](https://www.sudo.ws/) - Allows a permitted user to execute a command as the superuser or another user.
  - [`openssh-server`](https://www.openssh.com/) - Provides the SSH daemon for secure access to the system remotely.
  - `ca-certificates`: Common CA certificates.
  - [`curl`](https://github.com/curl/curl) - A tool to transfer data from or to a server.
  - `lsb-release`: Provides information about the Linux Standard Base and distribution.
  - `firmware-linux`: Firmware for Linux kernel drivers.
  - `firmware-misc-nonfree`: Non-free firmware for various drivers.

- SSH Configuration:
  - Configures and enables the SSH service for remote access.
  - Enables root access via SSH (with caution advised).

- User Configuration:
  - Adds the current user to the `sudo` group for administrative privileges.

- Debian Post-Installation Setup:
  - Modifies `sources.list` for additional repositories.
  - Adds Debian backports for newer versions of packages.
  - Configures additional repositories and imports GPG keys for software like `eza`.

- Commonly Used Packages:
- Commonly Used Packages:
  - [`fzf`](https://github.com/junegunn/fzf) - A command-line fuzzy finder.
  - [`git`](https://github.com/git/git) - Distributed version control system.
  - [`htop`](https://github.com/htop-dev/htop) - An interactive process viewer.
  - [`lm-sensors`](https://github.com/lm-sensors/lm-sensors) - Utilities to read temperature/voltage/fan sensors.
  - [`unrar`](https://www.rarlab.com/) - Unarchiver for .rar files. (Official site, no GitHub repository.)
  - [`mc` (Midnight Commander)](https://github.com/MidnightCommander/mc) - A powerful file manager.
  - [`detox`](https://github.com/dharple/detox) - Utility to clean up filenames.
  - [`ncdu`](https://dev.yorhel.nl/ncdu) - NCurses Disk Usage. (Official site, no GitHub repository.)
  - `nfs-common` - Support files for NFS clients. (Part of the NFS utilities, official page at [Linux NFS](https://linux-nfs.org/))

- Docker Installation (All Docker-related packages are part of the Docker organization on GitHub):
  - Docker components including `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin` can be explored at the [Docker GitHub](https://github.com/docker).


## Security Considerations

- The script enables SSH root access. Use strong passwords or SSH keys and consider restricting access by IP where possible.
- Review the script and adjust package installations or configurations to suit your security policies and requirements.

## Customization

You can edit the script to add or remove package installations or modify system configurations to fit your needs. The script is organized into sections for easy navigation and customization.

## Support

This script is provided as-is, without warranty. If you encounter issues or have suggestions, please submit an issue or pull request on GitHub.