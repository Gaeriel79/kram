#!/bin/bash

#Systemupdates
#---------------------------------------

#apt get update && apt full-upgrade

#Software
#---------------------------------------

apt update
apt install neofetch unattended-upgrades
#btop++
wget -qO btop.tbz https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux-musl.tbz
sudo tar xf btop.tbz -C /usr/local bin/btop
rm -rf btop.tbz


#Security
#---------------------------------------
#unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades

#add new administrativ user
useradd gaeriel -m -s /bin/bash
usermod -aG sudo,adm
passwd gaeriel
cd /home/gaeriel
mkdir .ssh
chown gaeriel:gaeriel .ssh
#
SSH configuration
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
#sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

#RPC Service disable
systemctl stop rpcbind
systemctl disable rpcbind
systemctl mask rpcbind
systemctl stop rpcbind.socket
systemctl disable rpcbind.socket