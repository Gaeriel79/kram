#!/bin/sh

#Benötigte Variablen
#hostname
#ipadress
#gateway
#dns1
#dns2

#abfragen der Variablen

echo "Hostnamen für den Raspi angeben:"
read hostname

echo "IP Adresse für den Raspi angeben:"
read ipadress

echo "Gateway / Router IP Adresse angeben:"
read gateway

echo "DNS Adresse angeben (nicht den Router angeben):"
read dns1

#Systemupdates
#apt get update && apt full-upgrade

#Netzwerkkonfiguration
#hostnamen setzen
echo "interface eth0
static ip_address=${ipadress}/24
static routers=${gateway}
static domain_name_servers=${dns1}" | tee -a /etc/dhcpd.sshd_config

#Hostnamen setzen
hostnamectl set-hostname ${hostname}

#hosts Datei ändern
echo "127.0.0.1     ${hostname}" | tee -a /etc/hosts
#Zeitzone
timedatectl set-timezone Europe/Berlin


#SSH Konfiguration
#nano /etc/ssh/sshd_config
sed -i 's/#AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

mkdir ~/.ssh && chmod 700 ~/.ssh


# Programme
apt install htop neofetch vim git unattended-upgrades
#curl -fsSL https://get.docker.com | sh

#Raspi-Config
#locale keyboard expand filesystem
#raspi-config
