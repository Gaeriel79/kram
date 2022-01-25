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
gdisk

mkfs.vfat /dev/sda1
mkfs.btrfs /dev/sda2
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

umount /mnt

#mount subvolumes

mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/sda2    
mkdir /mnt{boot,home,var,tmp,swap,opt,srv}
mkdir /mnt/boot/efi
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var /dev/sda2 /mnt/var
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@tmp /dev/sda2 /mnt/tmp
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@opt /dev/sda2 /mnt/opt
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@opt /dev/sda2 /mnt/opt
#mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@swap /dev/sda2 /mnt/swap
#mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@.snapshots /dev/sda2 /mnt/.snapshots
#mount /dev/sda1 /mnt/boot
mount -t vfat -L EFIBOOT /mnt/boot/

pacstrap /mnt base base-devel linux-zen linux-zen-firmware vim sudo archlinux-keyring wget btrfs-progs os-prober --noconfirm --needed
cp -R ${SCRIPT_DIR} /mnt/root/arch
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
echo -ne "
-------------------------------------------------------------------------
                    Checking for low memory systems <8G
-------------------------------------------------------------------------
"
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -lt 8000000 ]]; then
    # Put swap into the actual system, not into RAM disk, otherwise there is no point in it, it'll cache RAM into RAM. So, /mnt/ everything.
    mkdir /mnt/opt/swap # make a dir that we can apply NOCOW to to make it btrfs-friendly.
    chattr +C /mnt/opt/swap # apply NOCOW, btrfs needs that.
    dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
    chmod 600 /mnt/opt/swap/swapfile # set permissions.
    chown root /mnt/opt/swap/swapfile
    mkswap /mnt/opt/swap/swapfile
    swapon /mnt/opt/swap/swapfile
    # The line below is written to /mnt/ but doesn't contain /mnt/, since it's just / for the system itself.
    echo "/opt/swap/swapfile	none	swap	sw	0	0" >> /mnt/etc/fstab # Add swap to fstab, so it KEEPS working after installation.
fi
echo -ne "
