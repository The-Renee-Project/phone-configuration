#!/bin/bash
set -x
set -e
sudo -s << SCRIPT
set -x
set -e
mount -o remount,rw /
ssh-keygen -A
hostnamectl set-hostname $1 # set [hostname] to new name
sed -i'' "s/ubuntu-phablet/$1/g" /etc/hosts
gpasswd -a phablet docker
sed -i'' 's{^exit 0{mount -o remount,rw /\n\0{' /etc/rc.local
sed -i"" 's{#DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"{\0\nDOCKER_OPTS="-g /userdata/var/lib/docker"{' /etc/default/docker
service docker start || true # to launch docker
update-rc.d docker enable # to enable to launch on boot
sed -i"" 's/TERM=linux/TERM=xterm-256color/' /etc/environment
touch /home/phablet/.viminfo
chown phablet:phablet .viminfo
apt clean
apt update
apt install -y tmux vim #install vim so I don't lose my sanity
vi -es /etc/init/ssh.override
  %s/manual\n//g
  wq!
EOF
android-gadget-service enable ssh
chown -R phablet:phablet /home/phablet/.bash* /home/phablet/.vim*

mkdir -p /home/phablet/.docker
chown -R phablet:phablet /home/phablet/.docker

mkdir -p /var/run/sshd
SCRIPT

echo 'set -g default-terminal "screen-256color"' >> ~/.tmux.conf
sed -i'' 's/\(PS1=...debian_chroot.*\)\\w/\1\\w$(__git_ps1 " \\[\\033[01;31m\\](%s)\\[\\033[01;34m\\]") /' /home/phablet/.bashrc
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat << EOF >> /home/phablet/.ssh/authorized_keys # add your public key so you can ssh
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJY+miwJOg7NIjokfO38aVtooCeMNBEhKaHPtVGaHfPj gabriel@diamante
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+MfRsratIMQE7TUpRPFnAB/YwFwPzbG+mNQvGwTvTk jfi.switzer@gmail.com
EOF
chmod 600 ~/.ssh/authorized_keys

sudo reboot
