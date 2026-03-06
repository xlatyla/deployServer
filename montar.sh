#!/bin/bash

PUNTO_MONTAJE_1="/mnt/windows/mailomya"
PUNTO_MONTAJE_2="/mnt/windows/tanatex"
PUNTO_MONTAJE_3="/mnt/windows/PricingToolProccessed"
PUNTO_MONTAJE_4="/mnt/windows/PricingTool"
PUNTO_MONTAJE_5="/mnt/windows/certs"
PUNTO_MONTAJE_6="/mnt/windows/disco_e"
PUNTO_MONTAJE_7="/mnt/windows/FTP"
PUNTO_MONTAJE_8="/mnt/windows/interface"
PUNTO_MONTAJE_9="/mnt/windows/incidents"
PUNTO_MONTAJE_10="/mnt/windows/veronelli"
PUNTO_MONTAJE_11="/mnt/windows/omya_parse"
PUNTO_MONTAJE_12="/mnt/windows/sage_interface"
PUNTO_MONTAJE_13="/mnt/windows/omya_tosap"
PUNTO_MONTAJE_14="/mnt/windows/omya_procesado"
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
sudo mkdir -p "$PUNTO_MONTAJE_5"
sudo mkdir -p "$PUNTO_MONTAJE_6"
sudo mkdir -p "$PUNTO_MONTAJE_7"
sudo mkdir -p "$PUNTO_MONTAJE_8"
sudo mkdir -p "$PUNTO_MONTAJE_9"
sudo mkdir -p "$PUNTO_MONTAJE_10"
sudo mkdir -p "$PUNTO_MONTAJE_11"
sudo mkdir -p "$PUNTO_MONTAJE_12"
sudo mkdir -p "$PUNTO_MONTAJE_13"
sudo mkdir -p "$PUNTO_MONTAJE_14"
# 3. Añadir a fstab si no existen ya
echo "Configurando el montaje automático en el arranque..."

if ! grep -q "$PUNTO_MONTAJE_1" /etc/fstab; then
    echo "//10.0.0.101/servicesSPT/printer/omya  $PUNTO_MONTAJE_1  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_2" /etc/fstab; then
    echo "//10.0.0.101/servicesSPT/printer/tanatex  $PUNTO_MONTAJE_2  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_3" /etc/fstab; then
    echo "//10.0.0.101/servicesADI/pricingtool/processed  $PUNTO_MONTAJE_3  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_4" /etc/fstab; then
    echo "//10.0.0.101/servicesADI/pricingtool  $PUNTO_MONTAJE_4  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_5" /etc/fstab; then
    echo "//10.0.0.102/Users/o.poncelas/Documents/bin  $PUNTO_MONTAJE_5  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_6" /etc/fstab; then
    echo "//10.0.0.100/E\$  $PUNTO_MONTAJE_6  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_7" /etc/fstab; then
    echo "//10.0.0.101/servicesSPT/ntl  $PUNTO_MONTAJE_7  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_8" /etc/fstab; then
    echo "//10.0.0.100/interface  $PUNTO_MONTAJE_8  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_9" /etc/fstab; then
    echo "//10.0.0.103/incidents  $PUNTO_MONTAJE_9  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_10" /etc/fstab; then
    echo "//10.0.0.101/FTP/VERONELLI  $PUNTO_MONTAJE_10  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_11" /etc/fstab; then
    echo "//10.0.0.101/FTP/OMYA/parsePlant  $PUNTO_MONTAJE_11  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_12" /etc/fstab; then
    echo "//10.0.0.100/interface/REAL/SPPT0_2  $PUNTO_MONTAJE_12  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_13" /etc/fstab; then
    echo "//10.0.0.101/FTP/OMYA/tosap  $PUNTO_MONTAJE_13  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

if ! grep -q "$PUNTO_MONTAJE_14" /etc/fstab; then
    echo "//10.0.0.101/FTP/OMYA/Procesado  $PUNTO_MONTAJE_14  cifs  credentials=$CREDENCIALES,vers=3.0,_netdev,nofail,x-systemd.requires=network-online.target 0 0" | sudo tee -a /etc/fstab > /dev/null
fi
# 4. Recargar y montar
sudo systemctl daemon-reload

echo "Comprobando estado de las conexiones con Windows..."

PUNTOS_DE_MONTAJE=(
    "$PUNTO_MONTAJE_1"
    "$PUNTO_MONTAJE_2"
    "$PUNTO_MONTAJE_3"
    "$PUNTO_MONTAJE_4"
    "$PUNTO_MONTAJE_5"
    "$PUNTO_MONTAJE_6"
    "$PUNTO_MONTAJE_7"
    "$PUNTO_MONTAJE_8"
    "$PUNTO_MONTAJE_9"
    "$PUNTO_MONTAJE_10"
    "$PUNTO_MONTAJE_11"
    "$PUNTO_MONTAJE_12"
    "$PUNTO_MONTAJE_13"
    "$PUNTO_MONTAJE_14"
)

TODOS_MONTADOS=true

# Recorremos la lista uno por uno
for RUTA in "${PUNTOS_DE_MONTAJE[@]}"; do
    if [ -n "$RUTA" ]; then
        # Comprobamos localmente si ya es un punto de montaje activo
        if mountpoint -q "$RUTA"; then
            echo "✅ $RUTA -> Ya estaba montado. Omitiendo petición a Windows."
        else
            echo "⏳ $RUTA -> Desconectado. Solicitando acceso a Windows..."
            sudo mount "$RUTA"

            # Verificamos si se montó correctamente tras pedirlo
            if ! mountpoint -q "$RUTA"; then
                echo "❌ ERROR: No se pudo conectar $RUTA. Revisa la ruta o permisos compartidos."
                TODOS_MONTADOS=false
            fi
        fi
    fi
done

echo "----------------------------------------------------"
if [ "$TODOS_MONTADOS" = true ]; then
    echo "¡Script ejecutado con éxito! Las 13 unidades están operativas."
    # Llamamos a tu script auxiliar si procede
    ./addcron.sh
else
    echo "¡Atención! Hubo un error al intentar montar alguna unidad. Revisa los errores (❌) mostrados arriba."
fi
