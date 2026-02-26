#!/bin/bash

# Ruta exacta donde tienes tu archivo docker-compose.yml
DIRECTORIO_PROYECTO="/home/docker_user/servicesADI"

echo "=== INICIANDO GESTOR DE CONTENEDORES ==="
cd "$DIRECTORIO_PROYECTO" || { echo "Error: No se encontró el directorio $DIRECTORIO_PROYECTO"; exit 1; }

# 1. Levantamos EXCLUSIVAMENTE los contenedores continuos (Daemons) SIN SUDO
echo "1. Levantando contenedores de ejecución continua..."
/usr/bin/docker compose up -d tempdb-service pricing-tool certs-checker-service

# 2. Configurar tareas programadas (Cron) para docker_user
echo "2. Configurando programador de tareas (Cron) para el usuario docker_user..."

# Creamos un archivo temporal
CRON_TMP=$(mktemp)

# Exportamos el crontab actual de docker_user (omitiendo configuraciones viejas de este proyecto)
crontab -u docker_user -l 2>/dev/null | grep -v "docker compose up -d" > "$CRON_TMP"

# Inyectamos las horas exactas en el crontab
cat <<EOF >> "$CRON_TMP"
# Ejecutar chemeter a las 08:00, 16:00 y 21:00
0 8,16,21 * * * cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d chemeter-service >> /home/docker_user/cron_chemeter.log 2>&1

# Ejecutar dashboardforecast a las 07:45 y a las 14:00
45 7 * * * cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d auto-dashboard-service >> /home/docker_user/cron_dashboard.log 2>&1
0 14 * * * cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d auto-dashboard-service >> /home/docker_user/cron_dashboard.log 2>&1

# Ejecutar deepdive a las 07:00
0 7 * * * cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d deepdive-service >> /home/docker_user/cron_deepdive.log 2>&1

# Ejecutar reportsales a las 21:00
0 21 * * * cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d sales-report-service >> /home/docker_user/cron_sales.log 2>&1
EOF

# Aplicamos el nuevo crontab EXCLUSIVAMENTE al usuario docker_user
crontab -u docker_user "$CRON_TMP"
rm "$CRON_TMP"

echo "¡Crontab de docker_user actualizado con éxito!"
echo ""
echo "=== RESUMEN DE ESTADO ==="
echo "🟢 CONTINUOS (Corriendo): tempdb, pricing-tool, certs-checker"
echo "⏳ PROGRAMADOS (En espera): chemeter, auto-dashboard, deepdive, sales-report"
