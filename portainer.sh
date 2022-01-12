#!/bin/sh

#Anleitung: 
#
#Skript ausführbar machen (nur einmal erforderlich, nach dem herunterladen) sudo chmod +x portainer.sh
#Starten mit sudo ./portainer.sh

#Laufenden Container stoppen und entfernen
docker stop portainer && sudo docker rm portainer

#Neues Image herunterladen
docker pull portainer/portainer-ce:latest

#Neuen Container starten
docker run -d -p 9000:9000 -p 8000:8000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest