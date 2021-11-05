#!/bin/sh

#Systemupdates
apt get update && apt full-upgrade

#Netzwerkkonfiguration
#hostnamen setzen
nano /etc/dhcpcd.conf
hostnamectl set-hostname dockerpi
nano /etc/hosts

#Zeitzone
timedatectl set-timezone Europe/Berlin


#SSH Konfiguration
nano /etc/ssh/sshd_config
mkdir ~/.ssh && chmod 700 ~/.ssh


# Programme
apt install htop neofetch vim git
curl -fsSL https://get.docker.com | sh

#Raspi-Config
#locale keyboard expand filesystem
raspi-config

#Benutzer ändern
usermod -l gaeriel pi
usermod -d /home/gaeriel -m gaeriel
groupmod -n gaeriel pi
passwd gaeriel

#portainer Installation
docker volume create portainer_data && sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

