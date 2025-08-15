# 🔐 DVWA Session Snapshot Script

Este script en Bash automatiza la autenticación de múltiples usuarios en [DVWA (Damn Vulnerable Web Application)](http://www.dvwa.co.uk/) y guarda una copia del HTML de la página principal (`index.php`) para cada sesión. Además, compara el contenido de cada sesión con la del usuario `admin` para detectar diferencias en permisos o vistas.

---

## 📋 ¿Qué hace este script?

1. **Autenticación automática** de varios usuarios en DVWA usando `curl`.
2. **Obtención de la cookie de sesión (`PHPSESSID`)** tras el login.
3. **Descarga del HTML de la página principal** para cada usuario autenticado.
4. **Comparación de contenido** entre el HTML del usuario `admin` y el resto.
5. **Almacenamiento organizado** de los archivos HTML en una carpeta específica.

---

## 📁 Estructura de salida

Los archivos HTML se guardan en:

$HOME/Pentesting/DVWA/sessions/

Cada archivo se nombra como:

index_<usuario>.html


---

## ⚙️ Requisitos

- Tener DVWA corriendo localmente en `http://127.0.0.1:8080`
- Acceso a Bash y herramientas como `curl`, `grep`, `diff`
- Usuarios válidos en DVWA con las credenciales especificadas en el script

---

## 👥 Usuarios definidos

El script intenta autenticarse con los siguientes usuarios:

| Usuario  | Contraseña |
|----------|------------|
| admin    | password   |
| gordonb  | abc123     |
| 1337     | charley    |
| pablo    | letmein    |
| smithy   | password   |

---

## 📌 Uso

Simplemente ejecuta el script:

```bash
./nombre_del_script.sh
```

## 🧪 Propósito

Este script es útil para:

- Analizar diferencias de permisos entre usuarios en DVWA.
- Capturar el contenido visible para cada sesión.
- Automatizar pruebas de seguridad y comportamiento de la aplicación.

## 🛑 Advertencia

Este script está diseñado para entornos de prueba controlados. No lo uses contra sistemas que no tengas permiso para auditar.
