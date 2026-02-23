#!/bin/bash

# ==========================================
# Configuración de Puntos de Montaje
# ==========================================
PUNTO_MONTAJE_1="/mnt/windows/mailomya/"
PUNTO_MONTAJE_2="/mnt/windows/tanatex/"
sudo apt install cifs-utils -y
# 1. Crear los directorios locales si no existen
mkdir -p "$PUNTO_MONTAJE_1"
mkdir -p "$PUNTO_MONTAJE_2"

mount -t cifs -o username=workflow_it,password=5c9BD394566!,vers=3.0 //10.0.0.101/ADJUNTOSMAILOMYA "$PUNTO_MONTAJE_1"
mount -t cifs -o username=workflow_it,password=5c9BD394566!,vers=3.0 //10.0.0.101/ADJUNTOSTANATEX "$PUNTO_MONTAJE_2"

# Mensaje para el log de systemd
echo "Script de montaje ejecutado correctamente."
