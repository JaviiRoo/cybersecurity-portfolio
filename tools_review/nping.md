# 🧭 Nping — Generador de paquetes y analizador de red

## 📌 Descripción General

**Nping** es una herramienta de línea de comandos desarrollada por los creadores de Nmap. Permite generar paquetes personalizados para múltiples protocolos (ICMP, TCP, UDP, ARP, etc) y analizar las respuestas recibidas. Es útil tanto para tareas simples como verificar si un host está activo, como para pruebas avanzadas de red, análisis de latencia, trazado de rutas, pruebas de firewall y simulación de ataques.
🔍 Nping es como un “ping avanzado” que te permite controlar cada aspecto del paquete enviado y ver cómo responde la red.

## ⚙️ Instalación

En Kali Linux, Nping suele estar incluido con Nmap. Si no lo tienes:

```Bash
sudo apt update
sudo apt install nmap
```

## 🚀 Ejemplo de uso

```Bash
nping 93.184.216.34
```

- IP `93.184.216.34` corresponde a `example.com`, un dominio público ideal para pruebas.
- Este comando envía paquetes ICMP (como `ping`) y mide el tiempo de respuesta.

```Bash
nping --tcp 93.184.216.34
```

- Este comando envía paquetes TCP, útil si el host bloquea ICMP.

## 📊 Interpretación de resultados

Salida generada por Nping al enviar paquetes ICMP al servidor [example.com](https://example.com). Se observa el tiempo de respuesta, la cantidad de paquetes enviados y recibidos, y la latencia promedio. Ideal para verificar conectividad y analizar rendimiento de red.

<img width="1021" height="228" alt="imagen" src="https://github.com/user-attachments/assets/f3c5b244-dc33-4ccf-94fc-17ea12d869cf" />

### 🧾 Encabezado

```Text
Starting Nping 0.7.95 ( https://nmap.org/nping ) at 2025-08-30 16:56 CEST
```

- Muestra la versión de Nping y la fecha/hora de ejecución.
- Se ejecuta con privilegios (sudo), necesarios para enviar paquetes ICMP sin restricciones.

### 📍 Paquetes enviados

```Text
SENT (0.0222s) ICMP [10.127.246.31 > 93.184.216.34 Echo request (type=8/code=0) id=25371 seq=1]
...
```

- Se enviaron ***5 paquetes ICMP tipo Echo Request*** (como los que usa `ping`).
- Cada línea muestra:

   - Tiempo de envío (`SENT`).
   - Protocolo (`ICMP`).
   - IP origen y destino.
   - Tipo de paquete (`type=8/code=0` → solicitud de eco).
   - TTL (Time To Live): 64.
   - ID y número de secuencia.
 
### ❌ Resultado final

```Text
Max rtt: N/A | Min rtt: N/A | Avg rtt: N/A
Raw packets sent: 5 (140B) | Rcvd: 0 (0B) | Lost: 5 (100.00%)
```

- ***No se recibió ninguna respuesta*** de los 5 paquetes enviados.
- 100% de pérdida de paquetes, lo que indica que el host:
  - Está ***filtrando ICMP*** (muy común en servidores protegidos).
  - O bien ***no está disponible*** en ese momento.
- Los valores de RTT (Round Trip Time) no se calculan porque no hubo respuestas.

## 📋 Parámetros comunes

| Parámetro         | Descripción                                                                 |
|-------------------|------------------------------------------------------------------------------|
| `--icmp`          | Fuerza el uso del protocolo ICMP.                                            |
| `--tcp`           | Fuerza el uso del protocolo TCP.                                             |
| `--udp`           | Fuerza el uso del protocolo UDP.                                             |
| `--arp`           | Usa paquetes ARP para descubrir hosts en la red local.                       |
| `--echo`          | Activa el modo eco para ver cómo cambian los paquetes en tránsito.           |
| `-c <n>`          | Número de paquetes a enviar.                                                 |
| `-p <puerto>`     | Puerto de destino (para TCP/UDP).                                            |
| `--privileged`    | Ejecuta con privilegios para enviar paquetes sin restricciones.              |
| `--delay <ms>`    | Tiempo de espera entre paquetes.                                             |

## 🧪 ¿Qué puedes hacer con Nping?

- Verificar si un host está activo.
- Medir latencia, pérdida de paquetes y jitter.
- Probar reglas de firewall.
- Simular tráfico TCP/UDP para pruebas de rendimiento.
- Ver cómo se modifican los paquetes en tránsito (modo eco).
- Realizar trazado de rutas (similar a traceroute).



## 📖 Glosario técnico

| Término              | Explicación sencilla                                                                 |
|----------------------|--------------------------------------------------------------------------------------|
| **ICMP**             | Protocolo usado por `ping` para verificar conectividad.                             |
| **TCP / UDP / ARP**  | Protocolos de red para diferentes tipos de comunicación.                            |
| **Echo Request / Reply** | Paquetes ICMP que indican si un host responde.                                 |
| **rtt (Round Trip Time)** | Tiempo que tarda un paquete en ir y volver.                                  |
| **Jitter**           | Variación en el tiempo de respuesta entre paquetes.                                 |
| **Modo eco**         | Permite ver cómo se modifican los paquetes en tránsito.                             |
| **Firewall**         | Sistema que filtra o bloquea tráfico de red.                                        |


