#!/bin/bash

sudo apt update && sudo apt upgrade -y

sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \

  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \

  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \

sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo apt install docker-compose
 
 
sudo useradd -m -s /bin/bash "docker_user"

echo 'docker_user:docker_user' | sudo chpasswd

sudo usermod -aG docker "docker_user"
 
sudo git clone "https://github.com/xlatyla/ragOllamaSimple.git" "/home/docker_user/ADIGrupo"

sudo git clone "https://github.com/xlatyla/ragOllamaSimple.git" "/home/docker_user/SPTLogistic

sudo apt install cups printer-driver-all -y

sudo systemctl start cups

sudo systemctl enable cups

 
