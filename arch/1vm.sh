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
#sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf


lsblk
#Disk Setup
sgdisk -Z /dev/sda # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' /dev/sda # partition 1 (BIOS Boot Partition)
sgdisk -n 2::-0 --typecode=2:8300 --change-name=2:'ROOT' /dev/sda # partition 2 (Root), default start, remaining

mkfs.btrfs -f /dev/sda2
mount /dev/sda2 /mnt
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
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/sda2 /mnt   
mkdir /mnt/{boot,home,var,tmp,swap,opt,srv,.snapshots}
mkdir /mnt/boot
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var /dev/sda2 /mnt/var
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@tmp /dev/sda2 /mnt/tmp
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@opt /dev/sda2 /mnt/opt
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@srv /dev/sda2 /mnt/srv
#mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@swap /dev/sda1 /mnt/swap
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@.snapshots /dev/sda2 /mnt/.snapshots
mount /dev/sda2 /mnt/boot

#Install base packages
pacstrap /mnt git vim base base-devel linux-zen linux-zen-headers linux-firmware sudo archlinux-keyring wget btrfs-progs os-prober dosfstools mtools grub efibootmgr --noconfirm --needed

cd /
genfstab -U /mnt >> /mnt/etc/fstab

mkdir /mnt/root/arch
cp -R ${SCRIPT_DIR} /mnt/root/
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
arch-chroot /mnt

