#!/usr/bin/env bash
pacman -S xf86-video-fbdev  #virtualbox graphic driver??
pacman -S xorg git base-devel picom xorg-xinit nitrogen kitty xterm vim google-chrome polybar rofi nerd-fonts-mononoki --noconfirm --needed
#AUR YAY Installation
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cp /etc/X11/xinit/xinitrc /home/gaeriel/.xinitrc
#vim .xinitrc