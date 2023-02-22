#!/bin/bash

# Make the file system mountable
mount -o remount,rw /

# Install all the updates
apt-get update
apt-get -y autoremove

# Clear the cache
apt-get clean

# Install Utilities
apt-get install -y vim git

# Set [hostname] to new name
hostnamectl set-hostname $1
sed -i'' "s/ubuntu-phablet/$1/g" /etc/hosts

# ============Setup Docker===============
# Dependencies
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Docker Signing Key
mkdir -m 0755 -p /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

# Docker ppa
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update
fi

# Copy the configuration
mkdir -p /etc/docker/
cp /home/phablet/setup/docker-daemon.json /etc/docker/daemon.json

# Install Docker
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Allow the phablet user to use Docker without sudo
groupadd docker
usermod -aG docker phablet

# Setup SSH
systemctl start ssh
mkdir -p /home/phablet/.ssh
touch /home/phablet/.ssh/authorized_keys
cat << EOF >> /home/phablet/.ssh/authorized_keys # add your public key so you can ssh
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJY+miwJOg7NIjokfO38aVtooCeMNBEhKaHPtVGaHfPj gabriel@diamante
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+MfRsratIMQE7TUpRPFnAB/YwFwPzbG+mNQvGwTvTk jfi.switzer@gmail.com
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDsOecr55lHiPsIDcOznloi49WubcQh4E7ERge2kuoqmb8JOV03d/L994GkK2RFYMpidYnc01lOKCDSJg2iLsF/eCqlrDLI/1LoWWlexxH7lybnKbHZosG30xAK0M+X2/m+kV1t9ES471E6yDeZTRO+F4iu/GgM1F+7xuU3h1GYY3sBdWxDxIsk9l7dtIJHyOmzLCa8xY0Kq/+RH2gh49ZPtxeRLcNBUx6Mw2dG2THWK/rsRo/dwk8RL/r5zcmIvRuUKhpvXig9/EBQsEtzAZrmuIZj2buEcdAs00mJgxt3jAOAn2jz5VT0+pen+6y78xtC617SxW6HpNXIG2PNMiQEIJ+KEYAhPD+JcStgQ4zh3692pmrGzAXZh2kLdxhw6WRUbmU/31rH8c0DHasEM3i9ihv+LY16KM36hX7tglgTlq8Zq5k3pvdZSSfXh496jWDK8jGKL4nDFqafQKb68XZ48COSlbQuRU2N9KrKS09uFioQ57OLy1wIBYVQ7uyp0ik= chris@chris-desktop
EOF
chmod 700 /home/phablet/.ssh
chmod 600 /home/phablet/.ssh/authorized_keys

# Install Cockpit
apt-get install cockpit -y

# Clear the cache
apt-get clean

# set -x
# set -e
# sudo -s << SCRIPT
# set -x
# set -e
# mount -o remount,rw /
# ssh-keygen -A
# gpasswd -a phablet docker
# sed -i'' 's{^exit 0{mount -o remount,rw /\n\0{' /etc/rc.local
# service docker start || true # to launch docker
# update-rc.d docker enable # to enable to launch on boot
# sed -i"" 's/TERM=linux/TERM=xterm-256color/' /etc/environment
# touch /home/phablet/.viminfo
# chown phablet:phablet .viminfo
# apt clean
# apt update
# apt install -y tmux vim #install vim so I don't lose my sanity
# vi -es /etc/init/ssh.override
#   %s/manual\n//g
#   wq!
# EOF
# android-gadget-service enable ssh
# chown -R phablet:phablet /home/phablet/.bash* /home/phablet/.vim*

# mkdir -p /home/phablet/.docker
# chown -R phablet:phablet /home/phablet/.docker

# mkdir -p /var/run/sshd
# SCRIPT

# echo 'set -g default-terminal "screen-256color"' >> ~/.tmux.conf
# sed -i'' 's/\(PS1=...debian_chroot.*\)\\w/\1\\w$(__git_ps1 " \\[\\033[01;31m\\](%s)\\[\\033[01;34m\\]") /' /home/phablet/.bashrc
# mkdir -p ~/.ssh
# chmod 700 ~/.ssh
# chmod 600 ~/.ssh/authorized_keys

# sudo reboot
