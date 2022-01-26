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
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#loadkeys de-latin1

source setup.conf
timedatectl set-ntp true
pacman -S --noconfirm pacman-contrib terminus-font
setfont ter-v22b
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf


lsblk
fdisk /dev/sda1
# o >Enter New Partiotion Table
# n >Enter p >Enter >Enter >Enter Create 1 Partition, Full Disk size
# t >Enter 83 >Enter Set Partitiontype to Linux
# a >Enter  Activate Partition
# w >Enter  Write chages to Disk

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

umount /mnt

#mount subvolumes

mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/sda1    
mkdir /mnt{boot,home,var,tmp,swap,opt,srv}
mkdir /mnt/boot/efi
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/sda1 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var /dev/sda1 /mnt/var
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@tmp /dev/sda1 /mnt/tmp
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@opt /dev/sda1 /mnt/opt
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@opt /dev/sda1 /mnt/opt
#mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@swap /dev/sda1 /mnt/swap
#mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@.snapshots /dev/sda1 /mnt/.snapshots
#mount /dev/sda1 /mnt/boot


pacstrap /mnt base base-devel linux-zen linux-zen-firmware vim git sudo archlinux-keyring wget btrfs-progs os-prober dosfstools mtools grub efibootmgr --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
grub-install --target=i386-pc --recheck /dev/sda
cp -R ${SCRIPT_DIR} /mnt/root/arch
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
arch-chroot /mnt