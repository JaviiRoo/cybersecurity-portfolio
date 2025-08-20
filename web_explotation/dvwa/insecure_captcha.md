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
