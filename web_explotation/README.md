# 🌐 Web Exploitation

Este directorio contiene laboratorios, evidencias y documentación sobre técnicas de explotación de aplicaciones web. Cada subdirectorio representa un entorno vulnerable o una categoría específica de ataque.

## 📦 Contenido

| Directorio       | Descripción                                                                 |
|------------------|------------------------------------------------------------------------------|
| `dvwa/`          | Laboratorio completo usando DVWA para practicar vulnerabilidades web.       |
| `juice_shop/`    | OWASP Juice Shop: entorno moderno para pentesting web.                      |
| `file_upload/`   | Técnicas de evasión y explotación de formularios de subida de archivos.     |
| `xss/`           | Cross-Site Scripting: Reflected, Stored, DOM y mitigaciones.                |
| `csrf/`          | Cross-Site Request Forgery: construcción de PoCs y defensa.                 |
| `rce/`           | Remote Command Execution: inyecciones de comandos y shells reversas.        |
| `brute_force/`   | Ataques de fuerza bruta a formularios de login y autenticación.             |
| `hardening/`     | Checklist de medidas defensivas para servidores web y aplicaciones.         |

## 🧠 Objetivo

Practicar, documentar y dominar las técnicas más comunes de explotación web, siguiendo buenas prácticas de pentesting y manteniendo una estructura profesional de evidencias.

## 📁 Estructura recomendada

Cada módulo incluye:

- `setup/` → instrucciones de instalación y configuración
- `notes/` → comandos, observaciones y logs
- `loot/` → credenciales obtenidas, hashes, etc.
- `requests/` → respuestas HTTP, cabeceras, payloads
- `screens/` → capturas de pantalla
- `scans/` → resultados de herramientas como sqlmap, nikto, etc.

## 📸 Herramientas recomendadas

- `sqlmap`, `burpsuite`, `hydra`, `curl`, `flameshot`, `john`, `hashcat`
- Navegador con DevTools (F12)
