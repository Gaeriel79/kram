#!/usr/bin/env bash
#DEBUG
#DEBUG
#DEBUG
#set -x
#trap read debug
#DEBUG
#DEBUG
#DEBUG


ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=de-latin1" >> /etc/vconsole.conf
echo "FONT=eurlatgr" >> /etc/vconsole.conf
echo "archvm" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 archvm.localdomain archvm" >> /etc/hosts

echo -ne "
-------------------------------------------------------------------------
                    Installing Base System  
-------------------------------------------------------------------------
"
cat /root/arch/pkglistbase | while read line 

do
    echo "INSTALLING: ${line}"
   sudo pacman -S --noconfirm --needed ${line}
done

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

echo -ne "
-------------------------------------------------------------------------
                    Checking for low memory systems <8G
-------------------------------------------------------------------------
"
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -lt 8000000 ]]; then
    # Put swap into the actual system, not into RAM disk, otherwise there is no point in it, it'll cache RAM into RAM. So, /mnt/ everything.
    #mkdir /mnt/opt/swap # make a dir that we can apply NOCOW to to make it btrfs-friendly.
    chattr +C /swap # apply NOCOW, btrfs needs that.
    dd if=/dev/zero of=/swap/swapfile bs=1M count=2048 status=progress
    chmod 600 /swap/swapfile # set permissions.
    chown root /swap/swapfile
    mkswap /swap/swapfile
    swapon /swap/swapfile
    # The line below is written to /mnt/ but doesn't contain /mnt/, since it's just / for the system itself.
    echo "/swap/swapfile	none	swap	sw	0	0" >> /etc/fstab # Add swap to fstab, so it KEEPS working after installation.
fi

grub-install --target=i386-pc /dev/sda # replace sdx with your disk name, not the partition
grub-mkconfig -o /boot/grub/grub.cfg

#Enable Services
systemctl enable NetworkManager

sed -i 's/^MODULES()/MODULES(btrfs)/' /etc/mkinitcpio.conf
mkinitcpio -p linux-zen
#printf "\e[1;31m------------------------------------\e[0m"
printf "\e[1;31mEnter new password for root account:\e[0m"
passwd