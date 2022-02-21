#!/bin/bash

echo -ne "
-----------------------------------------------------------------
 ██████╗  █████╗ ███████╗██████╗ ██╗███████╗██╗  ███████╗ █████╗ 
██╔════╝ ██╔══██╗██╔════╝██╔══██╗██║██╔════╝██║  ╚════██║██╔══██╗
██║  ███╗███████║█████╗  ██████╔╝██║█████╗  ██║      ██╔╝╚██████║
██║   ██║██╔══██║██╔══╝  ██╔══██╗██║██╔══╝  ██║     ██╔╝  ╚═══██║
╚██████╔╝██║  ██║███████╗██║  ██║██║███████╗███████╗██║   █████╔╝
 ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝   ╚════╝                                                                 
-----------------------------------------------------------------
                   Oracle Cloud Basic Setup
-----------------------------------------------------------------
"
#Systemupdates
#---------------------------------------

#apt update && apt full-upgrade

#Software
#---------------------------------------

apt update
apt install neofetch unattended-upgrades fail2ban
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
usermod -aG sudo,adm,admin gaeriel
passwd gaeriel
cd /home/gaeriel
mkdir .ssh
chown gaeriel:gaeriel .ssh

#SSH configuration
echo -ne "
-----------------------------------------------------------------
Copy, modify and execute the following line into Windows-Terminal / Powershell
!!BEFORE!! continuing.
scp $env:USERPROFILE/.ssh/oracle1.pub gaeriel@144.24.180.9:~/.ssh/authorized_keys
-----------------------------------------------------------------
"
for i in {30..01}
do
tput cup 10 $l
echo -n "$i"
sleep 1
done

read -r -s -p $'Press enter to continue...'
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh

#RPC Service disable
systemctl stop rpcbind
systemctl disable rpcbind
systemctl mask rpcbind
systemctl stop rpcbind.socket
systemctl disable rpcbind.socket

#Fail2ban
systemctl enable fail2ban --now
