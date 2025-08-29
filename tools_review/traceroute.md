# 🧭 Traceroute — Rastreo de rutas en redes IP

## 📌 Descripción General

**Traceroute** es una herramienta de diagnóstico de red que permite rastrear la ruta que toman los paquetes IP desde tu máquina hasta un host de destino. Es fundamental para entender cómo se enruta el tráfico en Internet y detectar posibles problemas de conectividad o latencia.

🔍 Traceroute revela cada “salto” (router o nodo) por el que pasa un paquete, mostrando el tiempo que tarda en llegar a cada uno.

## ⚙️ ¿Cómo funciona?

- Utiliza el campo **TTL (Time To Live)** del protocolo IP.
- Envía paquetes con TTL creciente (1,2,3...) para provocar respuestas **ICMP TIME_EXCEEDED** desde cada router intermedio.
- Por defecto, en Linux usa **paquetes UDP**, aunque se puede configurar para usar **ICMP** o **TCP**.

## 🧪 ¿Para qué sirve?

- Diagnóstico de problemas de red.
- Identificación de cuellos de botella o latencia.
- Visualización del recorrido real de los datos.
- Verificación de rutas entre servidores.

## 🚀 Ejemplo de uso

```Bash
traceroute 8.8.8.8
```

Este comando rastrea la ruta desde tu máquina hasta el servidor DNS público de Google (8.8.8.8), mostrando cada salto y el tiempo de respuesta.

✅ La IP 8.8.8.8 es ideal para pruebas reales, ya que es pública, estable y ampliamente utilizada.

## 📋 Parámetros comunes

| Parámetro        | Descripción                                                                 |
|------------------|------------------------------------------------------------------------------|
| `-n`             | Muestra solo direcciones IP, sin resolver nombres de host.                  |
| `-m <n>`         | Establece el número máximo de saltos (por defecto 30).                      |
| `-w <n>`         | Tiempo de espera por respuesta en segundos (por defecto 5).                 |
| `-q <n>`         | Número de intentos por salto (por defecto 3).                               |
| `-I`             | Usa paquetes ICMP en lugar de UDP.                                          |
| `-T`             | Usa paquetes TCP en lugar de UDP.                                           |
| `-f <n>`         | TTL inicial (por defecto 1).                                                 |

## 📊 Interpretación de resultados

El comando traceroute muestra la ruta que siguen los paquetes desde tu máquina hasta el destino 8.8.8.8 (servidor DNS público de Google). Cada línea representa un salto (router o nodo intermedio), y los tiempos indican cuánto tarda el paquete en llegar y volver desde ese punto.

<img width="1035" height="268" alt="imagen" src="https://github.com/user-attachments/assets/449f3c40-4369-40cc-aa89-3a659ec3bdfc" />

### 🧾 Encabezado

```Text
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
```

- **Destino:** IP objetivo (8.8.8.8)
- **Máximo de saltos:** 30 (valor por defecto)
- **Tamaño de paquetes:** 60 bytes

### 📍 Saltos explicados

```Text
1  _gateway (10.127.246.216)  2.059 ms  1.918 ms  2.263 ms
```

- Primer salto: tu ***puerta de enlace local*** (router doméstico o de red corporativa).
- IP privada (10.x.x.x), no accesible desde Internet.
- Los tres valores indican el tiempo de respuesta en milisegundos de tres intentos.

```Text
2  * * *
```

- Segundo salto: sin respuesta.
- Puede estar ***filtrado, configurado para no responder***, o simplemente no accesible por ICMP.

```Text
3–8  10.x.x.x
```

- Saltos intermedios dentro de la ***infraestructura del proveedor de Internet***.
- Todas son IPs privadas (10.x.x.x), lo que indica que el ISP usa NAT o túneles internos.

```Text
9  193.251.249.1
```

- Primer salto con IP pública. Posiblemente ***el punto de salida del ISP*** hacia Internet.

```Text
10–12  IPs públicas de Google
```

- Estos salatos pertenecen a la ***infraestructura de Google***.
- Se observa cómo los paquetes pasan por diferentes routers internos antes de llegar al destino.

```Text
13  dns.google (8.8.8.8)  25.959 ms  25.749 ms  25.695 ms
```

- Último salto: el destino final.
- El paquete ha llegado correctamente al servidor DNS de Google.
- Los tiempos son bajos, lo que indica buena conectividad.

### 📌 Observaciones clave

- Los saltos con IP privada (10.x.x.x) indican redes internas, típicas en ISPs.

- Los * * * no son errores, sino saltos sin respuesta (por configuración o filtrado).

- Los tiempos en milisegundos permiten detectar latencia o cuellos de botella.

- El número de saltos ayuda a entender la complejidad de la ruta.

## 📖 Glosario de términos clave

| Término                  | Explicación sencilla                                                                 |
|--------------------------|--------------------------------------------------------------------------------------|
| **TTL (Time To Live)**   | Número máximo de saltos que puede hacer un paquete antes de ser descartado.         |
| **ICMP TIME_EXCEEDED**   | Mensaje que envía un router cuando un paquete excede su TTL.                        |
| **UDP / ICMP / TCP**     | Protocolos usados para enviar paquetes. UDP es el predeterminado en Linux.         |
| **RTT (Round Trip Time)**| Tiempo que tarda un paquete en ir y volver desde cada salto.                        |
| **Salto (Hop)**          | Cada router o nodo intermedio entre origen y destino.                               |
| **Red privada (IP privada)** | Direcciones IP reservadas para uso interno (ej. `10.x.x.x`, `192.168.x.x`).     |
| **NAT (Network Address Translation)** | Técnica que permite que múltiples dispositivos compartan una IP pública. |
| **DNSSEC**               | Extensión de seguridad para DNS que verifica la autenticidad de los registros.      |
| **Whois**                | Servicio que muestra información sobre el propietario de un dominio o IP.           |
| **Subdominio**           | Parte adicional de un dominio (ej. `blog.ejemplo.com`).                             |
| **Netcraft**             | Servicio que ofrece información sobre servidores web, tecnologías y hosting.        |
| **Buffer Overflow**      | Error que ocurre cuando un programa intenta usar más memoria de la que tiene asignada. |
| **Traceroute**           | Herramienta que rastrea la ruta que siguen los paquetes hasta un destino.           |
