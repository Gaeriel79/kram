#!/usr/bin/env bash
#-------------------------------------------------------------------------
echo -ne "
 ██████╗  █████╗ ███████╗██████╗ ██╗███████╗██╗  ███████╗ █████╗ 
██╔════╝ ██╔══██╗██╔════╝██╔══██╗██║██╔════╝██║  ╚════██║██╔══██╗
██║  ███╗███████║█████╗  ██████╔╝██║█████╗  ██║      ██╔╝╚██████║
██║   ██║██╔══██║██╔══╝  ██╔══██╗██║██╔══╝  ██║     ██╔╝  ╚═══██║
╚██████╔╝██║  ██║███████╗██║  ██║██║███████╗███████╗██║   █████╔╝
 ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝   ╚════╝                                                                 
"
#DEBUG
#DEBUG
#DEBUG
passwd
systemctl start sshd.service
set -x
trap read debug
ip a
#DEBUG
#DEBUG
#DEBUG

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#loadkeys de-latin1

#local pacman proxy
chmod +x proxy.sh
./proxy.sh

#make additional scripts executeable
chmod +x 1post.sh

#source setup.conf
timedatectl set-ntp true
pacman -S --noconfirm pacman-contrib terminus-font
setfont ter-v22b
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf


lsblk
gdisk /dev/sda


mkfs.btrfs -f /dev/sda1
mount /dev/sda1 /mnt
cd /mnt

# create subvolumes
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @var
btrfs subvolume create @tmp
btrfs subvolume create @swap
btrfs subvolume create @opt
btrfs subvolume create @srv
btrfs subvolume create @.snapshots

#mount subvolumes
umount -l /mnt
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/sda1 /mnt   
mkdir /mnt/{boot,home,var,tmp,swap,opt,srv}
mkdir /mnt/boot/efi
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/sda1 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var /dev/sda1 /mnt/var
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@tmp /dev/sda1 /mnt/tmp
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@opt /dev/sda1 /mnt/opt
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@srv /dev/sda1 /mnt/srv
#mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@swap /dev/sda1 /mnt/swap
#mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@.snapshots /dev/sda1 /mnt/.snapshots
#mount /dev/sda1 /mnt/boot


pacstrap /mnt git vim kitty tldr kate xmonad xmonad-contrib base-devel linux-zen linux-zen-headers linux-firmware vim git sudo archlinux-keyring wget btrfs-progs os-prober dosfstools mtools grub efibootmgr --noconfirm --needed

cd /
genfstab -U /mnt >> /mnt/etc/fstab

mkdir /mnt/root/arch
cp -R ${SCRIPT_DIR} /mnt/root/
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
arch-chroot /mnt
