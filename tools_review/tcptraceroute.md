# 🧭 tcptraceroute — Rastreo de rutas usando paquetes TCP

## 📌 Descripción General

**Tcptraceroute** es una variante de la herramienta clásica traceroute, diseñada para rastrear la ruta que toman los paquetes en una red IP, pero utilizando el ***protocolo TCP*** en lugar de UDP o ICMP. Esto lo hace especialmente útil en entornos donde los paquetes ICMP están bloqueados por firewalls o routers.

🔍 tcptraceroute es ideal para diagnosticar rutas hacia servicios específicos (como servidores web, SSH, etc.) que operan sobre TCP.

## ⚙️ ¿Cómo funciona?

- Envía paquetes TCP con un TTL (Time To Live) inicial de 1, incrementándolo en cada intento.
- Cada router intermedio responde con un mensaje **ICMP TIME_EXCEEDED** cuando el TTL expira.
- Al llegar al destino, se recibe una respuesta TCP (como SYN-ACK o RST), confirmando que el host está alcanzable.

## 🧪 ¿Para qué sirve?

- Diagnóstico de rutas hacia servicios TCP (HTTP, HTTPS, SSH, etc.).

- Identificación de firewalls que bloquean ICMP.

- Verificación de conectividad real hacia puertos específicos.

- Análisis de latencia y saltos intermedios.

## 🚀 Ejemplo de uso

Este comando rastrea la ruta que siguen los paquetes TCP desde tu máquina hasta el servidor web de example.com (93.184.216.34) en el puerto 80 (HTTP). A diferencia de traceroute, que usa ICMP o UDP, esta versión utiliza TCP, lo que permite atravesar redes que bloquean otros protocolos.

```Bash
sudo tcptraceroute 93.184.216.34 80
```

- IP `93.184.216.34` corresponde a `example.com`, un dominio público ideal para pruebas.
- Puerto `80` es el estándar para HTTP.

⚠️ tcptraceroute requiere privilegios de superusuario (sudo) para enviar paquetes TCP sin restricciones.

## 📋 Parámetros comunes

| Parámetro                  | Descripción                                                                 |
|----------------------------|-----------------------------------------------------------------------------|
| `host`                     | IP o dominio del destino.                                                   |
| `port`                     | Puerto TCP al que se desea rastrear la ruta.                                |
| `packet_length`            | Tamaño del paquete TCP enviado (opcional).                                  |
| `-p <source_port>`         | Puerto de origen local (opcional).                                          |
| `-s <source_address>`      | Dirección IP de origen (útil en sistemas con múltiples interfaces).         |

## 📊 Interpretación de resultados

Salida generada por tcptraceroute al rastrear la ruta hacia el servidor HTTP de [example.com](https://example.com). Se observa cada salto intermedio y el tiempo de respuesta, útil para diagnosticar conectividad TCP.

<img width="967" height="588" alt="imagen" src="https://github.com/user-attachments/assets/a50772a4-b5dc-415d-8f50-03fe84d8bf8e" />

### 🧾 Encabezado

```Text
traceroute to 93.184.216.34 (93.184.216.34), 30 hops max, 60 byte packets
```

- **Destino:** IP del servidor (93.184.216.34).
- **Puerto:** TCP 80 (HTTP).
- **Máximo de saltos:** 30.
- **Tamaño de paquetes:** 60 bytes.

### 📍 Saltos explicados

```Text
 1  _gateway (10.127.246.216)  2.181 ms  2.260 ms  2.290 ms
```

- Primer salto: tu puerta de enlace local (router).

- IP privada (10.x.x.x), no accesible desde Internet.

- Tiempos bajos indican buena conexión local.

```Text
 2  * * *
```

- Segundo salto: sin respuesta.
- Puede estar ***filtrado por firewall, no configurado para responder o no accesible por TCP***.

```Text
 3–8  IPs privadas (`10.x.x.x`)
```

- Estos saltos pertenecen a la ***infraestructura interna del proveedor de Internet (ISP)***.

- Aunque son IPs privadas, indican que el tráfico está siendo enrutado correctamente.

- Los tiempos (entre 25 ms y 55 ms) son normales para redes intermedias.

```Text
 9–30  * * *
```

- A partir del salto 9, no hay respuesta.
- Esto puede deberse a:

  - **Filtrado de paquetes TCP** en routers intermedios.

  - **Firewalls** que bloquean trazas TCP.

  - El destino (example.com) puede estar configurado para no responder a paquetes TCP con TTL bajo.

  - El puerto 80 puede estar **cerrado o protegido** contra escaneo.
 
### 📌 ¿Qué significa esto?

- La ruta se rastrea correctamente hasta el salto 8.

- A partir de ahí, los paquetes no reciben respuesta, lo que indica restricciones de red.

- Esto es común en redes corporativas, servidores protegidos o ISPs que filtran tráfico.

## 📖 Glosario

| Término                  | Explicación sencilla                                                                 |
|--------------------------|--------------------------------------------------------------------------------------|
| **TCP (Transmission Control Protocol)** | Protocolo orientado a conexión, usado por servicios como HTTP, SSH, etc. |
| **Puerto TCP**           | Número que identifica un servicio específico en un host (ej. 80 para HTTP).         |
| **SYN / SYN-ACK / RST**  | Tipos de respuesta TCP que indican si el puerto está abierto, cerrado o filtrado.   |
| **ICMP TIME_EXCEEDED**   | Respuesta de routers cuando el TTL de un paquete expira.                            |
| **TTL (Time To Live)**   | Número máximo de saltos que puede hacer un paquete antes de ser descartado.         |
| **RTT (Round Trip Time)**| Tiempo que tarda un paquete en ir y volver desde cada salto.                        |

