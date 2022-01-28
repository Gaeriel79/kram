#DEBUG
#DEBUG
#DEBUG
set -x
trap read debug
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
echo "root Passwort ändern"
passwd

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
grub-install --target=i386-pc /dev/sda # replace sdx with your disk name, not the partition
grub-mkconfig -o /boot/grub/grub.cfg

#Enable Services
systemctl enable NetworkManager

sed -i 's/^MODULES()/MODULES(btrfs)/' /etc/mkinitcpio.conf
mkinitcpio -p linux-zen

#Snapper Configuration
umount /.snapshots/
rm -rf /.snapshots/

snapper -c root create-config /
sed -i 's/^ALLOW_USERS=""/ALLOW_USERS="gaeriel"/' /etc/snapper/configs/root
sed -i 's/^TIMELINE_LIMIT_YEARLY="10"/TIMELINE_LIMIT_YEARLY="0"/' /etc/snapper/configs/root
sed -i 's/^TIMELINE_LIMIT_MONTHLY="10"/TIMELINE_LIMIT_MONTHLY="7"/' /etc/snapper/configs/root
sed -i 's/^TIMELINE_LIMIT_WEEKLY="0"/TIMELINE_LIMIT_WEEKLY="10"/' /etc/snapper/configs/root
sed -i 's/^TIMELINE_LIMIT_HOURLY="10"/TIMELINE_LIMIT_HOURLY="5"/' /etc/snapper/configs/root

chmod a+rx /.snapshots/
systemctl start snapper-timeline.timer
systemctl enable snapper-timeline.timer
systemctl start snapper-cleanup.timer
systemctl enable snapper-cleanup.timer
systemctl start grub-btrfs.path
systemctl enable grub-btrfs.path

echo "[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = linux*

[Action]
Depends = rsync
Description = Backing up /boot...
When = PreTransaction
Exec = /usr/bin/rsync -a --delete /boot /.bootbackup" >> /usr/share/libalpm/hooks/50_bootbackup
