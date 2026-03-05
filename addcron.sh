#!/bin/bash

# Ruta exacta donde tienes tu archivo docker-compose.yml
DIRECTORIO_PROYECTO="/home/docker_user/servicesADI"

echo "=== INICIANDO GESTOR DE CONTENEDORES ==="
cd "$DIRECTORIO_PROYECTO" || { echo "Error: No se encontró el directorio $DIRECTORIO_PROYECTO"; exit 1; }

# 1. Levantamos EXCLUSIVAMENTE los contenedores continuos (Daemons) SIN SUDO
echo "1. Levantando contenedores de ejecución continua..."
# Solo queda pricing-tool como continuo
/usr/bin/docker compose up -d --build pricing-tool

/usr/bin/docker compose up -d --build xpo-report-service prelist-report-service

/usr/bin/docker compose up -d --build ips-mail-service

/usr/bin/docker compose up -d --build error-interface-service

/usr/bin/docker compose up -d --build veronelli-service
HORA_ACTUAL=$(date +%H)
if [ "$HORA_ACTUAL" -lt 7 ] || [ "$HORA_ACTUAL" -ge 19 ]; then
    echo "Fuera de horario(07:00-19:00). Pausando servicios de reportes hasta el próximo turno..."
    /usr/bin/docker stop xpo-report-app prelist-report-app veronelli-service > /dev/null 2>&1
else
    echo "Dentro de horario. Los servicios de reportes quedan encendidos."
fi

# 2. Configurar tareas programadas (Cron) para docker_user
echo "2. Configurando programador de tareas (Cron) para el usuario docker_user..."

# Creamos un archivo temporal
CRON_TMP=$(mktemp)

# Exportamos el crontab actual de docker_user (omitiendo configuraciones viejas de este proyecto)
crontab -u docker_user -l 2>/dev/null | grep -v "docker compose up -d" > "$CRON_TMP"

# Inyectamos las horas exactas en el crontab
cat <<EOF >> "$CRON_TMP"
# Ejecutar tempdb de lunes a viernes a las 07:30
30 7 * * 1-5 cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d tempdb-service >> /home/docker_user/cron_tempdb.log 2>&1

# Ejecutar certs-checker de lunes a domingo (Todos los días) a las 09:00
0 9 * * * cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d certs-checker-service >> /home/docker_user/cron_certs.log 2>&1

# Ejecutar chemeter de lunes a viernes a las 08:00, 16:00 y 21:00
0 8,16,21 * * 1-5 cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d chemeter-service >> /home/docker_user/cron_chemeter.log 2>&1

# Ejecutar dashboardforecast de lunes a viernes a las 07:45 y a las 14:00
45 7 * * 1-5 cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d auto-dashboard-service >> /home/docker_user/cron_dashboard.log 2>&1
0 14 * * 1-5 cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d auto-dashboard-service >> /home/docker_user/cron_dashboard.log 2>&1

# Ejecutar deepdive de lunes a domingo (Todos los días) a las 07:00
0 7 * * * cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d deepdive-service >> /home/docker_user/cron_deepdive.log 2>&1

# Ejecutar reportsales de lunes a viernes a las 21:00
0 21 * * 1-5 cd $DIRECTORIO_PROYECTO && /usr/bin/docker compose up -d sales-report-service >> /home/docker_user/cron_sales.log 2>&1
EOF

0 7 * * * /usr/bin/docker start xpo-report-app prelist-report-app veronelli-service >> /home/docker_user/cron_reports.log 2>&1

0 19 * * * /usr/bin/docker stop xpo-report-app prelist-report-app veronelli-service >> /home/docker_user/cron_reports.log 2>&1
# Aplicamos el nuevo crontab EXCLUSIVAMENTE al usuario docker_user
crontab -u docker_user "$CRON_TMP"
rm "$CRON_TMP"

echo "¡Crontab de docker_user actualizado con éxito!"
echo ""
echo "=== RESUMEN DE ESTADO ==="
echo "🟢 CONTINUOS (Corriendo): pricing-tool"
echo "⏳ PROGRAMADOS (En espera): tempdb, certs-checker, chemeter, auto-dashboard, deepdive, sales-report"
echo "⏰ CONTROLADOS (Start/Stop): xpo-report, prelist-report (De 07:00 a 19:00)"
