#!/usr/bin/env bash
echo -ne "
-----------------------------------------------------------------
 ██████╗  █████╗ ███████╗██████╗ ██╗███████╗██╗  ███████╗ █████╗ 
██╔════╝ ██╔══██╗██╔════╝██╔══██╗██║██╔════╝██║  ╚════██║██╔══██╗
██║  ███╗███████║█████╗  ██████╔╝██║█████╗  ██║      ██╔╝╚██████║
██║   ██║██╔══██║██╔══╝  ██╔══██╗██║██╔══╝  ██║     ██╔╝  ╚═══██║
╚██████╔╝██║  ██║███████╗██║  ██║██║███████╗███████╗██║   █████╔╝
 ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝   ╚════╝                                                                 
-----------------------------------------------------------------
                Automated Arch Linux Installer
-----------------------------------------------------------------
"

#DEBUG
#DEBUG
#DEBUG
#echo "------------"
#echo "Enter new password for temporary root account"
#passwd
#systemctl start sshd.service
#set -x
#trap read debug
#ip a
#DEBUG
#DEBUG
#DEBUG
#make additionals scripts executeable
chmod +x 1vm.sh
chmod +x 2vm.sh
chmod +x 3post.sh
chmod +x proxy.sh

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

#local pacman proxy
bash ./proxy.sh
arch-chroot /mnt 1vm.sh
arch.chroot /mnt 2vm.sh
bash /root/arch3post.sh