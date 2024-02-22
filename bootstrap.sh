#!/bin/sh

# Setting PATH to ensure all commands are found
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Fail on any error
set -e

# Welcome message
printf "==== Initializing Bootstrap ====\n\n"

# -------------------------------
# SYSTEM UPDATE AND PACKAGE INSTALLATION
# -------------------------------
printf "Step 1: Ensuring non-free and contrib repositories are enabled...\n"
# Add contrib and non-free to the main Debian repositories in sources.list if not already present
sed -i '/^deb .*main/ s/$/ contrib non-free/' /etc/apt/sources.list

printf "Updating system package database and installing required packages...\n"
apt update
# Installing basic utilities, openssh-server, and firmware packages for better hardware compatibility
apt install -y wget gpg sudo openssh-server ca-certificates curl lsb-release firmware-linux firmware-misc-nonfree
printf "Completed: System update and basic packages installation.\n\n"

# -------------------------------
# SSH SERVICE CONFIGURATION
# -------------------------------
printf "Step 2: Configuring SSH service...\n"
systemctl enable ssh
systemctl start ssh
printf "Enabling SSH access for the root user...\n"
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh
printf "Completed: SSH service configured and root access enabled.\n\n"

# -------------------------------
# USER CONFIGURATION
# -------------------------------
printf "Step 3: Configuring user permissions...\n"
current_user=$(whoami)
# Adding the current user to the sudo group for administrative privileges
usermod -aG sudo "$current_user"
printf "Completed: Current user (%s) added to the sudo group.\n\n" "$current_user"

# -------------------------------
# DEBIAN POST-INSTALLATION SETUP
# -------------------------------
printf "Step 4: Executing Debian post-installation setup...\n"
# Adding backports and configuring additional repositories
DEBIAN_RELEASE_NAME=$(lsb_release -cs)
echo "deb http://deb.debian.org/debian ${DEBIAN_RELEASE_NAME}-backports main contrib non-free" > /etc/apt/sources.list.d/debian-backports.list
echo "deb-src http://deb.debian.org/debian ${DEBIAN_RELEASE_NAME}-backports main contrib non-free" >> /etc/apt/sources.list.d/debian-backports.list
mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
apt update
# Installing eza package
apt install -y eza
printf "Completed: Debian post-installation setup.\n\n"

# -------------------------------
# COMMON PACKAGES INSTALLATION
# -------------------------------
printf "Step 5: Installing commonly used packages...\n"
apt install -y fzf git htop lm-sensors unrar curl mc detox ncdu nfs-common
printf "Completed: Common packages installation.\n\n"

# -------------------------------
# DOCKER INSTALLATION
# -------------------------------
printf "Step 6: Installing Docker and related packages...\n"
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
printf "Completed: Docker and related packages installation.\n\n"

# Final cleanup
apt autoremove -y
printf "==== Bootstrap Complete! ====\n"
