#!/bin/sh

#define urls
DOCKER_GPG_URL="https://download.docker.com/linux/debian/gpg"
DOCKER_REPO_URL="https://download.docker.com/linux/debian"

# Welcome message
printf "==== Initializing Bootstrap ====\n\n"

# Hardcode Debian codename to bookworm
debian_codename="bookworm"

# Initial system update
apt_get_update() {
    apt-get update || echo >&2 "Failed to update package lists."
}

install_failures=""


attempt_install() {
    for pkg in "$@"; do
        if ! apt-get install -y "$pkg"; then
            # Log package failure
            install_failures="${install_failures}${pkg}\n"
        fi
    done
}

# Update package lists
apt_get_update


# Install missing dependencies
echo "Installing missing dependencies..."
attempt_install curl wget gnupg sudo software-properties-common


# Adding Docker's official GPG key and repository
printf "Adding Docker's official GPG key and repository...\n"
mkdir -p /etc/apt/keyrings
curl -fsSL $DOCKER_GPG_URL -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] $DOCKER_REPO_URL $debian_codename stable" | tee /etc/apt/sources.list.d/docker.list
apt_get_update

# Updating system package database and installing required packages
printf "Updating system package database and installing required packages...\n"
# Installing openssh-server and firmware packages for better hardware compatibility
attempt_install openssh-server
printf "Completed: System update and required packages installation.\n\n"

# Configuring SSH service
printf "Configuring SSH service...\n"
if ! systemctl is-enabled ssh >/dev/null || ! systemctl is-active ssh >/dev/null; then
    systemctl enable ssh
    systemctl start ssh
fi

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
attempt_install git lm-sensors ncdu nfs-common btop neovim
printf "Completed: Common packages installation.\n\n"

# Docker installation
printf "Installing Docker and related packages...\n"
attempt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Final cleanup
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

apt update && apt upgrade -y

printf "==== Bootstrap Complete!====\n"

# Print failed installations
if [ -n "$install_failures" ]; then
    printf "The following packages failed to install:\n%s\n" "$install_failures"
else
    printf "All packages installed successfully."
fi
