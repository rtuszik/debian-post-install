#!/bin/sh

set -e

printf "Initializing bootstrap...\n\n"
printf "Updating system...\n\n"

# Update package lists and ensure wget, gpg, sudo, and openssh-server are installed before they're needed
apt update
apt install -y wget gpg sudo openssh-server

# Ensure the SSH service is enabled and running
systemctl enable ssh
systemctl start ssh

# Ensure the current user is in the sudo group (replace 'current_user' with the actual username if this script is not run as the target user)
current_user=$(whoami)
if ! grep -q "^sudo:.*$current_user" /etc/group; then
    usermod -aG sudo $current_user
fi

debian_post_install_sh() {
    su - -c '
    gpasswd -a '"'$USER'"' sudo;
    grep -q "contrib non-free" /etc/apt/sources.list || sed -i "s/main/main contrib non-free/g" /etc/apt/sources.list;
    apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y && apt install -y lsb-release firmware-linux firmware-misc-nonfree;
    DEBIAN_RELEASE_NAME=$(lsb_release -cs);
    mkdir -p /etc/apt/sources.list.d;
    echo "deb http://deb.debian.org/debian ${DEBIAN_RELEASE_NAME}-backports main contrib non-free" > /etc/apt/sources.list.d/debian-backports.list;
    echo "deb-src http://deb.debian.org/debian ${DEBIAN_RELEASE_NAME}-backports main contrib non-free" >> /etc/apt/sources.list.d/debian-backports.list;
    apt update;
    mkdir -p /etc/apt/keyrings;
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg;
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list;
    chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list;
    apt update;
    apt install -y eza;
    apt autoremove -y;  # Final cleanup
    '
}

packages_install() {
    printf "Installing commonly used packages...\n"
    apt install -y \
        firmware-linux-nonfree \
        firmware-misc-nonfree \
        fzf \
        git \
        htop \
        lm-sensors \
        unrar \
        curl \
        mc \
        detox \
        ncdu
}

docker_install() {
    apt update
    apt install -y ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update

    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    apt autoremove -y;  # Final cleanup after Docker installation
}

# Invoke the functions in the desired order
debian_post_install_sh
packages_install
docker_install
