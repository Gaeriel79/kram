#!/bin/sh

#Install larger font
pacman -S terminus-font
setfont /usr/share/kbd/consolefonts/ter-132n.psf.gz

#Keyboard Layout
loadkeys de-latin1

#Time
timedatectl set-ntp true

#pacman sync check
pacman -Sy

