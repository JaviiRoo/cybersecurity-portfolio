# 🧭 Amap — Application Mapper

## 📌 Descripción General

**Amap** (Application Mapper) es una herramienta de escaneo de primera generación diseñada para identificar aplicaciones que se ejecutan en puertos TCP/UDP, incluso si no están en sus puertos estándar. A diferencia de escáneres de puertos tradicionales, Amap se enfoca en el **fingerprinting de aplicaciones**, enviando paquetes activadores y comparando las respuestas con una base de datos de firmas.

> 🔍 Es especialmente útil cuando los servicios están ocultos o corriendo en puertos no convencionales.

---

## ⚙️ Instalación

En Kali Linux, Amap suele estar preinstalado. Si no lo tienes:

```bash
sudo apt update
sudo apt install amap
```

## 🚀 Ejemplo de uso

```Bash
amap -bq 192.168.56.102 1-100
```

- Escanea los puertos del 1 al 100 en la IP `192.168.56.102`.
- `-b`: imprime los banners recibidos en ASCII.
- `-q`: omite puertos cerrados o con alto tiempo de espera.

✅ Ideal para detectar servicios ocultos en Metasploitable2 o entornos de laboratorio.

## 📋 Parámetros comunes

| Parámetro       | Descripción                                                                 |
|-----------------|-----------------------------------------------------------------------------|
| `-b`            | Imprime banners ASCII si se reciben.                                        |
| `-q`            | No reporta puertos cerrados o con timeout.                                  |
| `-v`            | Modo verbose (más detalles).                                                |
| `-o <archivo>`  | Guarda la salida en un archivo.                                             |
| `-u`            | Escaneo UDP en lugar de TCP.                                                |
| `-p <proto>`    | Especifica protocolo (ej. `http`, `ftp`).                                   |
| `-i <archivo>`  | Usa salida de Nmap para escanear puertos detectados.                        |
| `-d`            | Muestra todas las respuestas recibidas.                                     |


## 🧪 Ejemplo avanzado

```Bash
amap -bvq 192.168.56.102 80,443 -o resultado_amap.txt
```

- Escanea puertos 80 y 443.
- Imprime banners, omite puertos cerrados, guarda resultados en `resultado_amap.txt`.

## 📊 Interpretación de resultados - amap -bq 192.168.56.102 1-100

Este comando escanea los puertos del 1 al 100 en la IP 192.168.56.102 (Metasploitable2) y trata de identificar qué servicios están corriendo en cada puerto, incluso si no están en su puerto habitual. La opción -b muestra los banners en ASCII, y -q evita reportar puertos cerrados.

“Salida generada por Amap al escanear los puertos 1–100 de Metasploitable2. Se identifican múltiples servicios activos, incluyendo Apache, FTP, SSH y SMTP. Los banners revelan versiones específicas del software, útiles para análisis de vulnerabilidades y planificación de auditorías.”

<img width="1899" height="274" alt="imagen" src="https://github.com/user-attachments/assets/e1be32c6-4455-43b2-bfae-c684aa5ff067" />

### 🧾 Línea por línea explicada

```Text
Protocol on 192.168.56.102:22/tcp matches ssh - banner: SSH-2.0-OpenSSH_4.7p1 Debian-8ubuntu1
Protocol on 192.168.56.102:22/tcp matches ssh-openssh - banner: SSH-2.0-OpenSSH_4.7p1 Debian-8ubuntu1
```

- **Puerto 22:** Se detecta el servicio **SSH**.
- El banner revela que se trata de **OpenSSH versión 4.7p1, corriendo sobre **Debian/Ubuntu**.
- Esto nos indica que el sistema permite conexiones remotas seguras.

```Text
Protocol on 192.168.56.102:23/tcp matches telnet - banner:  #'
```

- **Puerto 23**: Se detecta **Telnet**, un protocolo inseguro para acceso remoto.
- Aunque el banner es mínimo, Amap lo reconoce como Telnet.
- Telnet es inseguro y obsoleto, pero útil para prácticas de pentesting.

```Text
Protocol on 192.168.56.102:80/tcp matches http - banner: <html><head><title>Metasploitable2 - Linux</title>...
Protocol on 192.168.56.102:80/tcp matches http-apache-2 - banner: HTTP/1.1 200 OK ... Server Apache/2.2.8 (Ubuntu)
```

- **Puerto 80:** Servicio HTTP detectado.
- El banner muestra encabezados HTTP y parte del HTML de la página.
- Se confirma que el servidor usa **Apache 2.2.8 y PHP 5.2.4**, versiones antiguas con vulnerabilidades conocidas.

```Text
Protocol on 192.168.56.102:25/tcp matches smtp - banner: 220 metasploitable.localdomain ESMTP Postfix (Ubuntu)
```

- **Puerto 25:** Servicio SMTP (correo) detectado.
- El banner indica que se usa **Postfix**, un servidor de correo en Ubuntu.

```Text
Protocol on 192.168.56.102:21/tcp matches ftp - banner: 220 (vsFTPd 2.3.4)
```

- **Puerto 53:** Servicio DNS detectado.
- El banner es mínimo, pero suficiente para identificar el protocolo.

## 📋 Tabla resumen

### 🧠 Servicios detectados por Amap en Metasploitable2

| Puerto | Protocolo | Servicio detectado | Banner / Versión                         |
|--------|-----------|--------------------|------------------------------------------|
| 21     | TCP       | FTP                | vsFTPd 2.3.4                              |
| 22     | TCP       | SSH                | OpenSSH_4.7p1 Debian-8ubuntu1            |
| 23     | TCP       | Telnet             | #’ (mínimo pero identificable)           |
| 25     | TCP       | SMTP               | Postfix (Ubuntu)                         |
| 53     | TCP       | DNS                | (banner mínimo)                          |
| 80     | TCP       | HTTP / Apache      | Apache/2.2.8 + PHP/5.2.4                 |


## ✅ Buenas prácticas

- Usa Amap solo en entornos controlados o con autorización explícita.
- Complementa Amap con Nmap para escaneo de puertos y servicios.
- Guarda los resultados para análisis posterior.
- Usa SNMP y DNS enum solo si el entorno lo permite.

## 📘 Glosario técnico

| Término         | Explicación sencilla                                                                 |
|-----------------|--------------------------------------------------------------------------------------|
| **Fingerprinting** | Identificación de servicios mediante patrones de respuesta.                     |
| **Banner**      | Texto que devuelve un servicio al conectarse, revela versión y software.            |
| **Puerto no estándar** | Puerto diferente al habitual para un servicio (ej. HTTP en 8080).           |
| **Trigger packet** | Paquete diseñado para provocar una respuesta útil del servicio.                  |

## 🔗 Recursos adicionales

- [Documentación oficial de Amap en Kali Linux](https://www.kali.org/tools/amap/)
- [Tutorial práctico de Amap en Sweshi](https://sweshi.com/CyberSecurityTutorials/Penetration%20Testing%20and%20Ethical%20Hacking/amap%20tutorial.php)
- 
