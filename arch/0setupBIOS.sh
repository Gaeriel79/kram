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
set -x
trap read debug

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#loadkeys de-latin1

#source setup.conf
timedatectl set-ntp true
pacman -S --noconfirm pacman-contrib terminus-font
setfont ter-v22b
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

#Set pacman local proxy mirror
sed -i 's+^[community]
Include = /etc/pacman.d/mirrorlist+[community]
Include = /etc/pacman.d/mirrorlist

[quarry]
Server = http://192.168.178.131:9129/repo/quarry

[sublime-text]
Server = http://192.168.178.131:9129/repo/sublime+' /etc/pacman.conf

echo 'Server = http://192.168.178.131:9129/repo/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist


lsblk
gdisk /dev/sda


mkfs.btrfs /dev/sda1
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

mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/sda1    
mkdir /mnt/{boot,home,var,tmp,swap,opt,srv}
mkdir /mnt/boot/efi
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/sda1 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var /dev/sda1 /mnt/var
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@tmp /dev/sda1 /mnt/tmp
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@opt /dev/sda1 /mnt/opt
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@opt /dev/sda1 /mnt/opt
#mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@swap /dev/sda1 /mnt/swap
#mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@.snapshots /dev/sda1 /mnt/.snapshots
#mount /dev/sda1 /mnt/boot


pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware vim git sudo archlinux-keyring wget btrfs-progs os-prober dosfstools mtools grub efibootmgr --noconfirm --needed

genfstab -U /mnt >> /mnt/etc/fstab
grub-install --target=i386-pc --recheck /dev/sda

mkdir /mnt/root/arch
cp -R ${SCRIPT_DIR} /mnt/root/arch
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
arch-chroot /mnt