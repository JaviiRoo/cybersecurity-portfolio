## 📖 Glosario técnico inicial

| Término                         | Significado                                                                                                      | Categoría        |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ---------------- |
| **SQLi** (SQL Injection)        | Vulnerabilidad que permite manipular consultas SQL para obtener, modificar o eliminar datos de la base de datos. | Vulnerabilidades |
| **RCE** (Remote Code Execution) | Vulnerabilidad que permite ejecutar comandos en el servidor de forma remota.                                     | Vulnerabilidades |
| **Dump**                        | Volcado de datos, normalmente exportar información de una base de datos.                                         | Base de datos    |
| **Hash**                        | Cadena generada a partir de datos mediante un algoritmo (ej. MD5, SHA1) que es difícil revertir.                 | Criptografía     |
| **Cookie**                      | Pequeño archivo/valor que guarda información de sesión en el navegador.                                          | Web / Sesiones   |
| **PHPSESSID**                   | Identificador de sesión PHP que mantiene la autenticación de un usuario.                                         | Web / Sesiones   |
| Término                      | Significado                                                                                                                  | Categoría     |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------------- |
| **boolean-based blind SQLi** | Inyección SQL que devuelve un resultado diferente según si la condición es verdadera o falsa. No muestra datos directamente. | SQLi          |
| **error-based SQLi**         | Inyección SQL que provoca errores en la base de datos para extraer información en el mensaje de error.                       | SQLi          |
| **time-based blind SQLi**    | Inyección SQL que usa retardos (`SLEEP()`) para inferir datos midiendo el tiempo de respuesta.                               | SQLi          |
| **UNION query**              | Técnica de SQLi que une resultados de la consulta original con datos controlados por el atacante.                            | SQLi          |
| **INFORMATION\_SCHEMA**      | Base de datos especial de MySQL que almacena metadatos sobre otras bases de datos, tablas y columnas.                        | Base de datos |
| **MD5** | Algoritmo de hash criptográfico de 128 bits, considerado inseguro, usado aquí para almacenar contraseñas. | Criptografía |
| **Hash cracking** | Proceso de revertir un hash a su valor original usando diccionarios, fuerza bruta o tablas rainbow. | Criptografía |
| **SQL dump** | Extracción completa de datos de una o varias tablas de una base de datos. | Base de datos |
| **Loot** | Jerga de pentesting para referirse a la información sensible obtenida. | Jerga |
| **RCE (Remote Code Execution)** | Vulnerabilidad que permite ejecutar comandos arbitrarios en el servidor | Base de datos |
| **Payload** | Datos ó codigo malicioso enviado para explotar una vulnerabilidad | Vulnerabilidad |
| 

## 🛠 Tabla de comandos y parámetros usados

| Herramienta / Comando | Parámetro    | Explicación                                             | Categoría |
| --------------------- | ------------ | ------------------------------------------------------- | --------- |
| **sqlmap**            | `-u`         | URL objetivo con el parámetro vulnerable.               | SQLi      |
| **sqlmap**            | `--cookie`   | Define la cookie que se enviará con la petición.        | Web       |
| **sqlmap**            | `--dbs`      | Lista las bases de datos encontradas.                   | SQLi      |
| **sqlmap**            | `-D`         | Especifica la base de datos a atacar.                   | SQLi      |
| **sqlmap**            | `--tables`   | Lista las tablas de la base de datos seleccionada.      | SQLi      |
| **sqlmap**            | `-T`         | Especifica la tabla a atacar.                           | SQLi      |
| **sqlmap**            | `--dump`     | Extrae (vuelca) los datos de la tabla.                  | SQLi      |
| **john**              | `--wordlist` | Define el diccionario que usará para crackear hashes.   | Cracking  |
| **curl**              | `-I`         | Realiza una petición HTTP y muestra solo las cabeceras. | Web       |
| Herramienta / Comando | Parámetro  | Explicación                                                          | Categoría      |
| --------------------- | ---------- | -------------------------------------------------------------------- | -------------- |
| **sqlmap**            | `--tables` | Lista las tablas existentes en la base de datos seleccionada (`-D`). | SQLi           |
| **sqlmap**            | `-T`       | Selecciona una tabla específica de la base de datos para atacar.     | SQLi           |
| **sqlmap**            | `--dump`   | Extrae el contenido de la tabla seleccionada.                        | SQLi           |
| **sqlmap**            | `--batch`  | Acepta las opciones por defecto sin preguntar (automatiza).          | Automatización |
| **sqlmap**            | `--dbms`   | Fuerza el motor de base de datos a un valor concreto (ej. `MySQL`).  | SQLi           |
| **whoami** | Comando para saber con qué usuario se está ejecutando el proceso actual. | 
| **uname -a**     | Muestra información detallada del sistema operativo. |
| Webshell       | Script que permite ejecutar comandos en el servidor desde un navegador. |
