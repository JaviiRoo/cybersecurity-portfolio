# 🧭 p0f — Fingerprinting pasivo de sistemas operativos

## 📌 Descripción General

**p0f** es una herramienta de análisis pasivo de tráfico TCP/IP que permite identificar el sistema operativo, tipo de conexión, distancia de red y otras características del host remoto sin enviar ningún paquete. A diferencia de herramientas activas como Nmap, p0f ***no genera tráfico***, sino que analiza las conexiones que pasan por la interfaz de red.

🔍 Ideal para entornos donde no se puede escanear activamente, como redes protegidas por IDS o firewalls.

## ⚙️ Instalación

En Kali Linux, p0f suele estar preinstalado. Si no lo tienes:

```Bash
sudo apt update
sudo apt install p0f
```

## 🚀 Ejemplo de uso

Activamos la herramienta p0f y la ponemos en modo escucha:

```Bash
sudo p0f -i eth0 -d -o /tmp/resultado_p0f.txt
```

- `-i` es el parámetro para indicar la interfaz de red.
- `eth0` es la interfaz de red (puede ser wlan0, enp0s3, etc).
- `-d` ejecuta p0f en segundo plano, modo demonio.
- `-o` guarda los resultados en un archivo.

✅ Para generar tráfico que p0f pueda analizar, puedes usar:

Una vez que p0f está escuchando, necesitas provocar una conexión TCP para que tenga algo que analizar. Por ejemplo:

```Bash
echo -e "HEAD / HTTP/1.0\r\n" | nc -n 192.168.56.102 80
```

- IP `192.168.56.101` corresponde a una máquina virtual Metasploitable2 en red local.
- Esto simula una conexión HTTP que p0f puede interceptar y analizar.

Verificamos los resultados:

```Bash
cat /tmp/resultado_p0f.txt
```

## 📊 Interpretación de resultados

**Primer comando: `sudo p0f -i eth0 -d -o /tmp/resultado_p0f.txt`**

<img width="482" height="237" alt="imagen" src="https://github.com/user-attachments/assets/7b47a8ab-fd05-4087-a0f2-3d397f0ed4fb" />

### 🧾 Salida explicada primer comando

```Text
[!] Consider specifying -u in daemon mode (see README).
```

- Advertencia opcional: se recomienda usar `-u` para ejecutar como usuario no privilegiado por seguridad, pero no es obligatorio.

```Text
[+] Loaded 322 signatures from '/etc/p0f/p0f.fp'.
```

- p0f ha cargado su base de datos de 322 firmas para identificar sistemas operativos y configuraciones de red.

```Text
[+] Intercepting traffic on interface 'eth0'.
```

- Está escuchando tráfico TCP en la interfaz `eth0`.

```Text
[+] Log file '/tmp/resultado_p0f.txt' opened for writing.
```

- Los resultados se guardarán en ese archivo.

```Text
[+] Daemon process created, PID 3590
```

- p0f se ha ejecutado en segundo plano con el PID 2124.

**Segundo comando: `echo -e "HEAD / HTTP/1.0\r\n" | nc -n 192.168.56.102 80`**

<img width="474" height="133" alt="imagen" src="https://github.com/user-attachments/assets/1f612068-3fff-435a-a240-879d2b572617" />

### 🧾 Salida explicada segundo comando

```Text
HTTP/1.1 200 OK
```

- HTTP/1.1: Versión del protocolo HTTP que usa el servidor.
- 200 OK: Código de estado que indica que la petición fue exitosa. El servidor está disponible y respondió correctamente.

```Text
Date: Sat, 30 Aug 2025 15:34:07 GMT
```

- Fecha y hora en que el servidor generó la respuesta.
- El formato GMT es estándar en protocolos web para sincronización global.

```Text
Server: Apache/2.2.8 (Ubuntu) DAV/2
```

- El servidor web es **Apache versión 2.2.8**, corriendo sobre **Ubuntu**.
- **DAV/2** indica que tiene habilitado WebDAV, una ***extensión de HTTP para gestión de archivos remotos***.

🔍 Esta línea revela el software y sistema operativo del servidor, útil para fingerprinting y análisis de vulnerabilidades.

```Text
X-Powered-By: PHP/5.2.4-2ubuntu5.10
```

- El servidor usa **PHP versión 5.2.4**, una tecnología para generar contenido dinámico.
- Esta versión es antigua y puede tener vulnerabilidades conocidas.

⚠️ En auditorías de seguridad, esta línea puede indicar vectores de ataque si el software está desactualizado.

```Text
Connection: close
```

- El servidor indica que cerrará la conexión después de enviar la respuesta.
- Esto es típico en HTTP/1.0, donde no se mantiene la conexión abierta por defecto.

```Text
Content-Type: text/html
```

- El tipo de contenido que el servidor enviaría si se hubiera usado GET en lugar de HEAD.
- En este caso, sería una página HTML.

## 📋 Parámetros comunes

| Opción                  | Descripción                                                                |
|-------------------------|----------------------------------------------------------------------------------------|
| `-i <interfaz>`         | Escucha tráfico en la interfaz de red especificada.                                   |
| `-r <archivo>`          | Analiza tráfico desde un archivo pcap.                                                |
| `-p`                    | Modo promiscuo: captura todo el tráfico que pasa por la interfaz.                     |
| `-L`                    | Lista todas las interfaces disponibles.                                               |
| `-o <archivo>`          | Guarda los resultados en un archivo de log.                                           |
| `-s <socket>`           | Crea un socket UNIX para consultas API.                                               |
| `-f <archivo>`          | Usa una base de datos de firmas personalizada.                                        |
| `-d`                    | Ejecuta en segundo plano (requiere `-o` o `-s`).                                       |
| `-u <usuario>`          | Ejecuta como usuario no privilegiado.                                                 |
| `-t c,h`                | Define tiempo de vida de caché de conexiones y hosts.                                 |
| `-m c,h`                | Límite de conexiones y hosts activos.                                                 |

## 📖 Glosario técnico

| Término              | Explicación sencilla                                                                 |
|----------------------|--------------------------------------------------------------------------------------|
| **Fingerprinting**   | Técnica para identificar sistemas operativos y servicios analizando patrones de red.|
| **Pasivo**           | No genera tráfico, solo analiza lo que ya circula.                                   |
| **SYN**              | Paquete TCP inicial para establecer una conexión.                                    |
| **NAT**              | Traducción de direcciones IP entre redes privadas y públicas.                        |
| **Promiscuo**        | Modo de red que permite capturar todo el tráfico, no solo el destinado al host.      |
| **Interfaz de red**  | Punto de conexión entre el sistema y la red (ej. `eth0`, `wlan0`).                   |
