# Cross-Site Request Forgery (CSRF) en DVWA

## 1 ¿Qué es CSRF?

- **CSRF:** Es un ataque que fuerza al navegador de una víctima autenticada a ejecutar una acción en un sitio donde está logueada (cambiar contraseña, email...) sin la intención de dicha víctima.
- No necesita leer la respuesta; solo que el navegador envíe la petición con las ***cookies de sesión*** de la víctima.

## Conceptos clave 

- **Estado (state-changing):** Acción que modifica algo en el servidor (ej: cambiar contraseña).
- **Anti-CSRF token:** Valor secreto, impredecible, por solicitud, que el servidor incluye en el formulario y valida al recibirlo.
- **SameSite cookie:** Atributo de cookie
