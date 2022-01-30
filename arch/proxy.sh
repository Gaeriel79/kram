#!/usr/bin/env bash
#-------------------------------------------------------------------------
#Set pacman local proxy mirror
echo 'Server = http://192.168.178.131:7878/$repo/os/$arch' > /etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist
