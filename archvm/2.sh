#!/bin/sh

#Dateisystem erstellen
mkfs.btrfs /dev/sda1

#Mount root Partition
mount /dev/sda1 -mnt

#Subvolumes erstellen
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var

#Unmount root Partition
umount /mnt

#Mounten der Subvolumes
mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2, subvol=@ /dev/sda1 /mnt
mkdir -p /mnt/{home,var}
mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2, subvol=@home /dev/sda1 /mnt/home
mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2, subvol=@var /dev/sda1 /mnt/var

#Installieren der Basis Softwarepakete
pacstrap /mnt base linux-zen linux-firmware git vim nano btrfs-progs tldr open-vm-tools xf86-input-vmmouse xf86-video-vmware timeshift htop neofetch grub networkmanager network-manager-applet mtools dosfstools base-devel linux-zen-headers xdg-utils xdg-user-dirs

#Dateisystem erstellen
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt
cat /etc/fstab

#Zeitzone und locale einstellen
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
sed -i 's/#de_DE.UTF8 UTF-8/de_DE.UTF8 UTF-8/' /etc/locale-gen
locale-gen
echo "LANG=de_DE.UTF8" >> /etc/locale.config

#Tastatur einstellen
echo "KEYMAP=de-latin1" >> /etc/vconsole.config

#Hostnamen festlegen
echo "archvm" >> /etc/hostname

#hosts Datei anpassen
echo "127.0.0.1     localhost" | tee -a /etc/hosts
echo "::1           localhost" | tee -a /etc/hosts
echo "127.0.1.1     archvm.localdomain      archvm" | tee -a /etc/hosts

#Rootpasswort setzen
passwd

#Grub einrichten
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

#Dienste starten
systemctl enable NetworkManager
systemctl enable fstrim-timer

#Benutzer erstellen
useradd -m gaeriel
passwd
usermod -aG wheel
#wheel Gruppe bearbeiten für sudo / Den zweiten Eintrag für Wheel Gruppe auskommentieren
EDITOR=vim visudo

#BTRFS 
sed -i 's/MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf
mkinitcpio -p linux-zen

exit
umount -R /mnt

