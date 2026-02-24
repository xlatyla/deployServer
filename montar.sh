  GNU nano 7.2                                           montar2.sh
#!/bin/bash

# Quitamos las barras finales para mantener la limpieza de las rutas
PUNTO_MONTAJE_1="/mnt/windows/mailomya"
PUNTO_MONTAJE_2="/mnt/windows/tanatex"
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

# 3. Añadir a fstab si no existen ya
echo "Configurando el montaje automático en el arranque..."

if ! grep -q "ADJUNTOSMAILOMYA" /etc/fstab; then
    echo "//10.0.0.101/ADJUNTOSMAILOMYA  $PUNTO_MONTAJE_1  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-sy>
fi

if ! grep -q "ADJUNTOSTANATEX" /etc/fstab; then
    echo "//10.0.0.101/ADJUNTOSTANATEX   $PUNTO_MONTAJE_2  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-sy>
fi

# 4. Recargar y montar
sudo systemctl daemon-reload
sudo mount -a

# 5. Comprobación profesional usando 'mountpoint'
if mountpoint -q "$PUNTO_MONTAJE_1" && mountpoint -q "$PUNTO_MONTAJE_2"; then
    echo "¡Script ejecutado correctamente! Las unidades están montadas y listas para los contenedores."
else
    echo "Hubo un error al intentar montar las unidades. Revisa la IP o las credenciales."
fi
