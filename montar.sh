#!/bin/bash

# Asegúrate de tener las 4 variables definidas
PUNTO_MONTAJE_1="/mnt/windows/mailomya"
PUNTO_MONTAJE_2="/mnt/windows/tanatex"
PUNTO_MONTAJE_3="/mnt/windows/PricingToolProccessed"
PUNTO_MONTAJE_4="/mnt/windows/PricingTool"
CREDENCIALES="/root/.smbcredentials"

sudo apt install cifs-utils -y

echo "Por favor, introduce las credenciales para configurar el montaje persistente:"
read -p "Usuario: " USUARIO
read -s -p "Contraseña: " PASSWORD
echo ""

# 1. Crear el archivo de credenciales
echo "Guardando credenciales de forma segura..."
echo "username=$USUARIO" | sudo tee "$CREDENCIALES" > /dev/null
echo "password=$PASSWORD" | sudo tee -a "$CREDENCIALES" > /dev/null
sudo chmod 600 "$CREDENCIALES"

# 2. Crear los directorios de montaje
sudo mkdir -p "$PUNTO_MONTAJE_1"
sudo mkdir -p "$PUNTO_MONTAJE_2"
sudo mkdir -p "$PUNTO_MONTAJE_3"
sudo mkdir -p "$PUNTO_MONTAJE_4"

# 3. Añadir a fstab si no existen ya (buscando las nuevas rutas)
echo "Configurando el montaje automático en el arranque..."

if ! grep -q "servicesSPT/printer/omya" /etc/fstab; then
    echo "//10.0.0.101/servicesSPT/printer/omya  $PUNTO_MONTAJE_1  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "servicesSPT/printer/tanatex" /etc/fstab; then
    echo "//10.0.0.101/servicesSPT/printer/tanatex   $PUNTO_MONTAJE_2  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "servicesADI/pricingtool/processed" /etc/fstab; then
    echo "//10.0.0.101/servicesADI/pricingtool/processed  $PUNTO_MONTAJE_3  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "servicesADI/pricingtool " /etc/fstab; then
    echo "//10.0.0.101/servicesADI/pricingtool  $PUNTO_MONTAJE_4  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

# 4. Recargar y montar
sudo systemctl daemon-reload
sudo mount -a

# 5. Comprobación profesional
if mountpoint -q "$PUNTO_MONTAJE_1" && mountpoint -q "$PUNTO_MONTAJE_2" && mountpoint -q "$PUNTO_MONTAJE_3" && mountpoint -q "$PUNTO_MONTAJE_4"; then
    echo "¡Script ejecutado correctamente! Las cuatro unidades están montadas."
else
    echo "Hubo un error al intentar montar las unidades. Revisa la IP, los nombres de las carpetas compartidas o las credenciales."
fi
