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
echo "KEYMAP=de_DE-latin1" >> /etc/vconsole.conf
echo "archvm" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 archvm.localdomain archvm" >> /etc/hosts
echo "root Passwort ändern"
passwd

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

#pipewire
sudo pacman -S --noconfirm --needed pipewire pipewire-media-session pipewire-alsa pipewire-jack pipewire-zeroconf
sudo pacman -R --noconfirm pulseaudio-equalizer-ladspa pulseaudio-alsa gnome-bluetooth blueberry pulseaudio-bluetooth pulseaudio
sudo pacman -S --noconfirm --needed pipewire-pulse blueberry pavucontrol
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