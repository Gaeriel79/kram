#!/bin/sh

#Install larger font
pacman -S --noconfirm terminus-font
setfont /usr/share/kbd/consolefonts/ter-132n.psf.gz

#Keyboard Layout
loadkeys de-latin1

wifi-menu
#Time
timedatectl set-ntp true

#pacman sync check
pacman -Syyy
pacman -S reflector
reflector -c Germany -a 6 --sort --save /etc/pacman.de/mirrorlist
pacman -Syyy

chmod +x k2.sh