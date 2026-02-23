#!/bin/bash

sudo apt update && sudo apt upgrade -y

sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

sudo useradd -m -s /bin/bash "docker_user" || true

echo 'docker_user:docker_user' | sudo chpasswd

sudo usermod -aG docker "docker_user"

sudo git clone "https://github.com/xlatyla/servicesADI.git" "/home/docker_user/ADIGrupo"

sudo git clone "https://github.com/xlatyla/servicesSPT.git" "/home/docker_user/SPTLogistic"

sudo chown -R docker_user:docker_user /home/docker_user/

sudo apt install cups printer-driver-all -y

sudo systemctl start cups

sudo systemctl enable cups

sudo lpadmin -p PT_B600_SPT -E -v socket://192.168.2.244

sudo lpadmin -p ES_IM3000_SPT -E -v socket://192.168.13.5

sudo cupsctl --remote-any --share-printers

sudo systemctl restart cups

echo "Instalación completada con éxito!"




