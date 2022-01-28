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
cp -R ${SCRIPT_DIR} /mnt/root/arch
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=de_DE-latin1" >> /etc/vconsole.conf
echo "archvm" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 archvm.localdomain archvm" >> /etc/hosts
echo root:password | chpasswd

# You can add xorg to the installation packages, I usually add it at the DE or WM install script
# You can remove the tlp package if you are installing on a desktop or vm

pacman -S --noconfirm sudo snapper picom dhclient reflector wget cronie grub networkmanager network-manager-applet tlp dialog wpa_supplicant mtools dosfstools reflector base-devel linux-zen-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pulseaudio bash-completion openssh rsync reflector acpi acpi_call tlp edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld flatpak sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font

#pipewire
sudo pacman -S --noconfirm --needed pipewire
sudo pacman -S --noconfirm --needed pipewire-media-session
sudo pacman -S --noconfirm --needed pipewire-alsa
sudo pacman -S --noconfirm --needed pipewire-jack
sudo pacman -S --noconfirm --needed pipewire-zeroconf

sudo pacman -R --noconfirm pulseaudio-equalizer-ladspa
sudo pacman -R --noconfirm pulseaudio-alsa
sudo pacman -R --noconfirm gnome-bluetooth blueberry
sudo pacman -R --noconfirm pulseaudio-bluetooth
sudo pacman -R --noconfirm pulseaudio

sudo pacman -S --noconfirm --needed pipewire-pulse
sudo pacman -S --noconfirm --needed blueberry
sudo pacman -S --noconfirm --needed pavucontrol
sudo systemctl enable bluetooth.service


echo -ne "
-------------------------------------------------------------------------
                    Installing Microcode
-------------------------------------------------------------------------
"
# determine processor type and install microcode
proc_type=$(lscpu)
if grep -E "GenuineIntel" <<< ${proc_type}; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm intel-ucode
    proc_ucode=intel-ucode.img
elif grep -E "AuthenticAMD" <<< ${proc_type}; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm amd-ucode
    proc_ucode=amd-ucode.img
fi
echo -ne "
-------------------------------------------------------------------------
                    Installing Graphics Drivers
-------------------------------------------------------------------------
"
# Graphics Drivers find and install
gpu_type=$(lspci)
if grep -E "NVIDIA|GeForce" <<< ${gpu_type}; then
    pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif grep -E "Integrated Graphics Controller" <<< ${gpu_type}; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa --needed --noconfirm
elif grep -E "Intel Corporation UHD" <<< ${gpu_type}; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa --needed --noconfirm
fi
grub-install --target=i386-pc /dev/sda # replace sdx with your disk name, not the partition
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp # You can comment this command out if you didn't install tlp, see above
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

useradd -m gaeriel
echo gaeriel:password | chpasswd
usermod -aG libvirt,wheel gaeriel

echo "gaeriel ALL=(ALL) ALL" >> /etc/sudoers.d/gaeriel


printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"

