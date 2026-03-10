#!/bin/bash

# Rutas de tus dos proyectos
DIR_ADI="/home/docker_user/servicesADI"
DIR_SPT="/home/docker_user/servicesSPT"

echo "=== INICIANDO GESTOR DE CONTENEDORES ==="

# 1. Levantamos los contenedores de ADI
echo "1. Levantando contenedores en $DIR_ADI..."
cd "$DIR_ADI" || { echo "Error: No se encontró $DIR_ADI"; exit 1; }
/usr/bin/docker compose up -d --build pricing-tool

# 2. Levantamos los contenedores de SPT
echo "2. Levantando contenedores en $DIR_SPT..."
cd "$DIR_SPT" || { echo "Error: No se encontró $DIR_SPT"; exit 1; }
/usr/bin/docker compose up -d --build xpo-report-service prelist-report-service
/usr/bin/docker compose up -d --build ips-mail-service
/usr/bin/docker compose up -d --build error-interface-service
/usr/bin/docker compose up -d --build veronelli-service
/usr/bin/docker compose up -d --build servicio_impresion
/usr/bin/docker compose up -d --build omya-sftp-service
/usr/bin/docker compose up -d --build lumar-sql-service
/usr/bin/docker compose up -d --build lumar-files-service
/usr/bin/docker compose up -d --build lumar-recap-service
/usr/bin/docker compose up -d --build lumar-entregas-service

# Forzamos el apagado inmediato de entregas para que respete su turno estricto del cron
/usr/bin/docker stop lumar-entregas-app > /dev/null 2>&1

# 3. Control de horario (Apagar si es de noche al ejecutar el script manualmente)
HORA_ACTUAL=$(date +%H)
if [ "$HORA_ACTUAL" -lt 7 ] || [ "$HORA_ACTUAL" -ge 19 ]; then
    echo "Fuera de horario (07:00-19:00). Pausando servicios controlados..."
    # Se añade servicio_impresion-app y se elimina expedition-list-app
    /usr/bin/docker stop xpo-report-app prelist-report-app veronelli-app ips-mail-app error-interface-app servicio_impresion-app omya-sftp-app lumar-sql-app lumar-files-app lumar-recap-app > /dev/null 2>&1
else
    echo "Dentro de horario. Los servicios quedan encendidos."
fi

# 4. Configurar tareas programadas (Cron) para docker_user
echo "3. Configurando programador de tareas (Cron) para el usuario docker_user..."

# Creamos un archivo temporal
CRON_TMP=$(mktemp)

# Exportamos el crontab actual limpiando TODA la basura anterior
crontab -u docker_user -l 2>/dev/null | grep -v -E "docker compose up|docker start|docker stop" > "$CRON_TMP"

# Inyectamos las horas exactas en el crontab
cat <<EOF >> "$CRON_TMP"
# Ejecutar tempdb de lunes a viernes a las 07:30
30 7 * * 1-5 cd $DIR_ADI && /usr/bin/docker compose up -d disk-monitor-service >> /home/docker_user/cron_tempdb.log 2>&1

# Ejecutar certs-checker de lunes a domingo (Todos los días) a las 09:00
0 9 * * * cd $DIR_ADI && /usr/bin/docker compose up -d certs-checker-service >> /home/docker_user/cron_certs.log 2>&1

# Ejecutar chemeter de lunes a viernes a las 08:00, 16:00 y 21:00
0 8,16,21 * * 1-5 cd $DIR_ADI && /usr/bin/docker compose up -d chemeter-service >> /home/docker_user/cron_chemeter.log 2>&1

# Ejecutar dashboardforecast de lunes a viernes a las 07:45 y a las 14:00
45 7 * * 1-5 cd $DIR_ADI && /usr/bin/docker compose up -d auto-dashboard-service >> /home/docker_user/cron_dashboard.log 2>&1
0 14 * * 1-5 cd $DIR_ADI && /usr/bin/docker compose up -d auto-dashboard-service >> /home/docker_user/cron_dashboard.log 2>&1

# Ejecutar deepdive de lunes a domingo (Todos los días) a las 07:00
0 7 * * * cd $DIR_ADI && /usr/bin/docker compose up -d deepdive-service >> /home/docker_user/cron_deepdive.log 2>&1

# Ejecutar reportsales de lunes a viernes a las 21:00
0 21 * * 1-5 cd $DIR_ADI && /usr/bin/docker compose up -d sales-report-service >> /home/docker_user/cron_sales.log 2>&1

# Encender TODOS los servicios SPT a las 07:00 AM todos los días
0 7 * * * /usr/bin/docker start xpo-report-app prelist-report-app veronelli-app ips-mail-app error-interface-app servicio_impresion-app omya-sftp-app lumar-sql-app lumar-files-app lumar-recap-app >> /home/docker_user/cron_reports.log 2>&1

# Apagar TODOS los servicios SPT a las 19:00 PM todos los días
0 19 * * * /usr/bin/docker stop xpo-report-app prelist-report-app veronelli-app ips-mail-app error-interface-app servicio_impresion-app omya-sftp-app lumar-sql-app lumar-files-app lumar-recap-app >> /home/docker_user/cron_reports.log 2>&1

# ----- HORARIO EXCLUSIVO LUMAR ENTREGAS (14:00 y 23:00) -----
# Turno de mediodía (Enciende 13:50, apaga 14:10)
50 13 * * 1-5 /usr/bin/docker start lumar-entregas-app >> /home/docker_user/cron_reports.log 2>&1
10 14 * * 1-5 /usr/bin/docker stop lumar-entregas-app >> /home/docker_user/cron_reports.log 2>&1

# Turno de noche (Enciende 22:50, apaga 23:10)
50 22 * * 1-5 /usr/bin/docker start lumar-entregas-app >> /home/docker_user/cron_reports.log 2>&1
10 23 * * 1-5 /usr/bin/docker stop lumar-entregas-app >> /home/docker_user/cron_reports.log 2>&1

EOF

# Aplicamos el nuevo crontab EXCLUSIVAMENTE al usuario docker_user
crontab -u docker_user "$CRON_TMP"
rm "$CRON_TMP"

echo "¡Crontab de docker_user actualizado con éxito!"
echo ""
echo "=== RESUMEN DE ESTADO ==="
echo "🟢 CONTINUOS (Corriendo 24/7): pricing-tool"
echo "⏳ PROGRAMADOS (En espera ADI): tempdb, certs, chemeter, dashboard, deepdive, sales"
echo "⏰ CONTROLADOS DIURNOS (07:00-19:00): xpo-report, prelist, veronelli, ips-mail, error-interface, servicio_impresion, moves_files_omya, lumar-sql, lumar-files, lumar-recap"
echo "🌙 CONTROLADOS ESPECÍFICOS: lumar-entregas (Activo solo de 13:50-14:10 y 22:50-23:10)"
