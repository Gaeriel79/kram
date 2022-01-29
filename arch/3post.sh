#!/usr/bin/env bash
#Snapper Configuration
pacman -S snapper snap-pac --noconfirm --needed
umount /.snapshots
rm -rf /.snapshots

snapper -c root create-config /
sed -i 's/^ALLOW_USERS=""/ALLOW_USERS="gaeriel"/' /etc/snapper/configs/root
sed -i 's/^TIMELINE_LIMIT_YEARLY="10"/TIMELINE_LIMIT_YEARLY="0"/' /etc/snapper/configs/root
sed -i 's/^TIMELINE_LIMIT_MONTHLY="10"/TIMELINE_LIMIT_MONTHLY="7"/' /etc/snapper/configs/root
sed -i 's/^TIMELINE_LIMIT_WEEKLY="0"/TIMELINE_LIMIT_WEEKLY="10"/' /etc/snapper/configs/root
sed -i 's/^TIMELINE_LIMIT_HOURLY="10"/TIMELINE_LIMIT_HOURLY="5"/' /etc/snapper/configs/root

chmod a+rx /.snapshots
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