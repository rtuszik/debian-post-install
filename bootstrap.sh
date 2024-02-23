#!/bin/sh

#define urls
DOCKER_GPG_URL="https://download.docker.com/linux/debian/gpg"
DOCKER_REPO_URL="https://download.docker.com/linux/debian"
EZA_GPG_URL="https://raw.githubusercontent.com/eza-community/eza/main/deb.asc"
EZA_REPO_URL="http://deb.gierens.de"


# Welcome message
printf "==== Initializing Bootstrap ====\n\n"

# Function to check and install lsb_release if missing
ensure_lsb_release() {
    if ! command -v lsb_release >/dev/null 2>&1; then
        echo "lsb_release is required but not installed. Attempting to install it."
        apt-get update && apt-get install -y lsb-release || { echo >&2 "Failed to install lsb-release. Exiting."; exit 1; }
    fi
}

# Install lsb_release if necessary
ensure_lsb_release

# Get Debian codename (e.g., buster, bullseye, bookworm)
debian_codename=$(lsb_release -sc)

# Adding non-free repositories
add_nonfree_repositories() {
    echo "Adding non-free repositories..."
    add-apt-repository -y "deb http://deb.debian.org/debian/ $debian_codename main contrib non-free"
    add-apt-repository -y "deb-src http://deb.debian.org/debian/ $debian_codename main contrib non-free"
}

# Initial system update
apt_get_update() {
    if ! apt-get update; then
        echo >&2 "Failed to update package lists. Exiting."
        exit 1
    fi
}

# Install missing dependencies
check_and_install_dependencies() {
    echo "Installing missing dependencies..."
    apt-get install -y curl wget gnupg sudo software-properties-common
}

# Add non-free repositories and update package lists
add_nonfree_repositories
apt_get_update

# Check and install any missing dependencies
check_and_install_dependencies

# # Adding the non-free and non-free-firmware repositories for Debian Bookworm
echo "deb http://deb.debian.org/debian/ $debian_codename main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list.d/non-free-firmware.list


# Adding Docker's official GPG key and repository
printf "Adding Docker's official GPG key and repository...\n"
mkdir -p /etc/apt/keyrings
curl -fsSL $DOCKER_GPG_URL -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] $DOCKER_REPO_URL $debian_codename stable" | tee /etc/apt/sources.list.d/docker.list
apt_get_update

# Adding eza's repository correctly
printf "Adding eza's repository...\n"
mkdir -p /etc/apt/keyrings
curl -fsSL $EZA_GPG_URL | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] $EZA_REPO_URL stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
apt_get_update


# Updating system package database and installing required packages
printf "Updating system package database and installing required packages...\n"
# Installing openssh-server and firmware packages for better hardware compatibility
if ! apt-get install -y openssh-server firmware-linux firmware-misc-nonfree; then
    echo >&2 "Failed to install required packages. Exiting."
    exit 1
fi
printf "Completed: System update and required packages installation.\n\n"

# Configuring SSH service
printf "Configuring SSH service...\n"
if ! systemctl is-enabled ssh >/dev/null || ! systemctl is-active ssh >/dev/null; then
    systemctl enable ssh
    systemctl start ssh
fi
printf "Enabling SSH access for the root user...\n"
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh
printf "Completed: SSH service configured and root access enabled.\n\n"

# Configuring user permissions
printf "Configuring user permissions...\n"
current_user=$(whoami)
# Adding the current user to the sudo group for administrative privileges if not already added
if ! groups "$current_user" | grep -q '\bsudo\b'; then
    usermod -aG sudo "$current_user"
    printf "Completed: Current user (%s) added to the sudo group.\n\n" "$current_user"
else
    printf "User (%s) is already part of the sudo group.\n\n" "$current_user"
fi

# Installing commonly used packages
printf "Installing commonly used packages...\n"
if ! apt-get install -y fzf git htop lm-sensors unrar mc detox ncdu nfs-common; then
    echo >&2 "Failed to install commonly used packages. Exiting."
    exit 1
fi
printf "Completed: Common packages installation.\n\n"

# Docker installation
printf "Installing Docker and related packages...\n"
if ! apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    echo >&2 "Failed to install Docker and related packages. Exiting."
    exit 1
fi
printf "Completed: Docker and related packages installation.\n\n"

# Final cleanup
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

apt update && apt upgrade -y

printf "==== Bootstrap Complete!===="
