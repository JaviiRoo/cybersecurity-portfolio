# 💥 DVWA — Damn Vulnerable Web Application

DVWA es una aplicación web intencionadamente vulnerable diseñada para ayudar a pentesters y estudiantes a practicar técnicas de explotación web en un entorno controlado.

## 🛠️ Instalación con Docker

```bash
docker pull vulnerables/web-dvwa
docker run -d --name dvwa -p 8080:80 vulnerables/web-dvwa
```

Accede a http://127.0.0.1:8080 con:

- **Usuario**: admin.
- **Contraseña**: password.

En el menú Setup, pulsa Create/Reset Database. Luego, en DVWA Security, selecciona Low y desactiva PHPIDS.

## 📁 Estructura del laboratorio

DVWA/
├── setup/         # Instalación y configuración
├── sqli/          # SQL Injection
├── xss/           # Cross-Site Scripting
├── rce/           # Remote Command Execution
├── csrf/          # Cross-Site Request Forgery
├── brute_force/   # Ataques de fuerza bruta
├── file_upload/   # Subida de archivos maliciosos
├── hardening/     # Medidas defensivas
├── notes/         # Logs y comandos
├── loot/          # Credenciales y datos obtenidos
├── requests/      # Peticiones/respuestas HTTP
└── screens/       # Capturas de pantalla


## 📚 Módulos disponibles

| Nº  | Módulo             | Técnicas clave                                               | Nivel   |
|-----|--------------------|--------------------------------------------------------------|---------|
| 1️⃣  | SQL Injection      | UNION, error-based, blind, sqlmap                           | Low     |
| 2️⃣  | Command Injection  | RCE, reverse shell, bash/nc                                 | Low     |
| 3️⃣  | XSS                | Reflected, Stored, DOM, robo de cookies                     | Low     |
| 4️⃣  | File Upload        | Webshell, bypass filtros, reverse shell                     | Low     |
| 5️⃣  | CSRF               | PoC HTML, cambio de contraseña                              | Low     |
| 6️⃣  | Brute Force        | Hydra, CSRF token                                           | Low     |
| 7️⃣  | Security Levels    | Medium, High, Impossible — adaptación de payloads           | Todos   |
| 8️⃣  | Hardening          | Checklist de mitigaciones en Apache, PHP, MySQL            | N/A     |


## 🧠 Objetivo

Dominar las técnicas de explotación web más comunes, entender cómo funcionan las vulnerabilidades y aprender a mitigarlas. Este entorno permite practicar de forma segura y documentar cada paso para construir un portfolio profesional.

## 📸 Ejemplo de documentación

- Guardar respuesta HTTP:

```bash
curl -s -D requests/sqli_login.headers \
     -o requests/sqli_login.html \
     "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1' OR '1'='1&Submit=Submit#"
```

- Captura de pantalla:

```bash
flameshot gui
```

- Log de comandos:

```bash
./log.sh sqlmap -u "..." --dump
```

## 🔐 Recomendación

No olvides cambiar el nivel de seguridad y repetir los ataques para entender cómo las defensas afectan a las técnicas. Documenta cada intento, éxito y fallo.

