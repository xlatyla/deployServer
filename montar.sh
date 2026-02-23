#!/bin/bash
 
PUNTO_MONTAJE_1="/mnt/windows/mailomya/"
PUNTO_MONTAJE_2="/mnt/windows/tanatex/"
 
sudo apt install cifs-utils -y
 
echo "Por favor, introduce las credenciales para el montaje:"

read -p "Usuario: " USUARIO

read -s -p "Contraseña: " PASSWORD

echo "" # Salto de línea después de la contraseña
 
sudo mkdir -p "$PUNTO_MONTAJE_1"

sudo mkdir -p "$PUNTO_MONTAJE_2"
 
sudo mount -t cifs -o username="$USUARIO",password="$PASSWORD",vers=3.0 //10.0.0.101/ADJUNTOSMAILOMYA "$PUNTO_MONTAJE_1"
 
sudo mount -t cifs -o username="$USUARIO",password="$PASSWORD",vers=3.0 //10.0.0.101/ADJUNTOSTANATEX "$PUNTO_MONTAJE_2"

if [ $? -eq 0 ]; then
    echo "Script de montaje ejecutado correctamente."
else
    echo "Hubo un error al intentar montar las unidades."
fi

# Escribir el contenido directamente en la ruta protegida usando sudo y tee
sudo tee /etc/systemd/system/mount.service > /dev/null <<EOF
[Unit]
Description=Ejecutar script al encender el sistema
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/montar.sh

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable mount.service
