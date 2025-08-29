# 🕵️ Fierce — Enumeración de DNS para Localización de Objetivos

## 📌 Descripción General

**Fierce** es una herramienta de enumeración DNS diseñada para ayudar a profesionales de ciberseguridad a ***localizar espacios IP y nombres de host no contiguos*** dentro de un dominio específico. A diferencia de escáneres activos como `nmap` o `nikto`, Fierce se enfoca en el ***reconocimiento pasivo***, utilizando fuentes como DNS, WHOIS y ARIN para descubrir información sin interactuar directamente con los sistemas objetivos.

🔍 Fierce es ideal para mapear redes mal configuradas que exponen información interna, sin generar ruido ni alertas en los sistemas de seguridad.

## 🧪 ¿Qué puede hacer Fierce?

- 🔹 Consultar registros DNS para descubrir subdominios.
- 🔹 Utilizar servidores DNS personalizados para las consultas.
- 🔹 Realizar búsquedas WHOIS y ARIN para obtener información de rangos IP.
- 🔹 Detectar redes internas mal configuradas.
- 🔹 Usar listas de palabras para fuerza bruta de subdominios.
- 🔹 Guardar los resultados en archivos para análisis posterior.

## ⚙️ Instalación

En Kali Linux, Fierce suele estar disponible por defecto. Si no lo está, puedes instalarlo manualmente desde el repositorio oficial o clonar desde GitHub:

```Bash
sudo apt update
sudo apt install fierce
```

También puedes acceder al código fuente desde:

[🔗 Wiki de Fierce en Aldeid](https://www.aldeid.com/wiki/Fierce)

## 🚀 Ejemplo de uso

```Bash
fierce --dns-servers 8.8.8.8 --domain hackthissite.org --subdomain-file /usr/share/dnsenum/dns.txt > /tmp/resultado_fierce.txt
```

Este comando realiza una enumeración DNS sobre el dominio hackthissite.org utilizando el servidor DNS público de Google (8.8.8.8). Usa una lista de palabras ubicada en /usr/share/dnsenum/dns.txt para intentar descubrir subdominios mediante fuerza bruta, y guarda los resultados en el archivo /tmp/resultado_fierce.txt.

## 📋 Parámetros comunes

| Parámetro                        | Descripción                                                                 |
|----------------------------------|-----------------------------------------------------------------------------|
| `--dns-servers`                  | Define uno o varios servidores DNS que se usarán para las consultas.       |
| `--domain`                       | Especifica el dominio objetivo a escanear.                                 |
| `--subdomain-file`              | Ruta al archivo que contiene subdominios para fuerza bruta (uno por línea).|
| `>` (redirección de salida)      | Guarda los resultados en un archivo especificado.                          |


💡 La herramienta dnsenum incluye una lista de palabras llamada dns.txt que puede ser reutilizada con Fierce para descubrir subdominios.

💡 Fierce no tiene una opción --file para guardar resultados directamente. Para ello, se debe usar la redirección estándar de Bash (>), o el comando tee si se desea ver y guardar al mismo tiempo.

⚠️ Importante: Fierce no reconoce los parámetros con guiones simples (-) ni acepta nombres de servidores DNS como dominios (ej. d.ns.buddyns.com). Debes usar doble guion (--) y proporcionar la IP del servidor DNS si no usas uno público como 8.8.8.8.

## 📊 Interpretación de resultados de Fierce

Al utilizar el comando anterior, se nos muestra la siguiente información en la terminal:

<img width="750" height="643" alt="imagen" src="https://github.com/user-attachments/assets/3117cd7a-88f9-4c71-9a70-5c6114f1a810" />

### 🔍 Servidores DNS y SOA

```Text
NS: c.ns.buddyns.com. h.ns.buddyns.com. g.ns.buddyns.com. j.ns.buddyns.com. f.ns.buddyns.com.
SOA: c.ns.buddyns.com. (116.203.6.3)
```

- **NS (Name Servers)**: Son los servidores que gestionan las consultas DNS del dominio.
- **SOA (Start of Authority)**: Indica el servidor principal que gestiona la zona DNS del dominio. En este caso, `c.ns.buddyns.com` con IP `116.203.6.3`.

### 🚫 Transferencia de zona y comodines

```Text
Zone: failure
Wildcard: failure
```

- **Zone: failure**: El servidor DNS no permite transferencias de zona (AXFR), lo cual es una configuración segura y habitual.

- **Wildcard: failure**: No se detectó un registro comodín (*.), lo que significa que el dominio no responde a subdominios inexistentes. Esto también es una buena práctica de seguridad.

### 🌐 Subdominios encontrados

```Text
Found: forum.hackthissite.org. (137.74.187.103)
Found: forums.hackthissite.org. (137.74.187.101)
Found: irc.hackthissite.org. (185.24.222.13)
Found: stats.hackthissite.org. (137.74.187.135)
Found: www.hackthissite.org. (137.74.187.100)
```

Fierce ha identificado varios subdominios activos del dominio objetivo, junto con sus respectivas direcciones IP. Estos subdominios pueden representar servicios web, foros, servidores IRC, estadísticas, etc.

### 🧭 IPs cercanas (Nearby)

```Text
Nearby:
{'137.74.187.100': 'hackthissite.org.', ...}
```
Fierce escanea direcciones IP cercanas a las encontradas para detectar otros hosts relacionados. Esto permite descubrir infraestructura adicional que puede no estar directamente expuesta en DNS.

## 📘 Fierce — Explicación detallada de la ayuda (--help)

Como ayuda extra, al utilizar el comando --help veremos lo siguiente:

<img width="887" height="461" alt="imagen" src="https://github.com/user-attachments/assets/4d601c0e-97d6-4aff-80e1-46d311515446" />

Vamos a desglosar qué significa exactamente lo que vemos:

| Opción                        | Explicación en español                                                                 |
|------------------------------|----------------------------------------------------------------------------------------|
| `-h`, `--help`               | Muestra el mensaje de ayuda y cierra el programa.                                     |
| `--domain DOMAIN`            | Especifica el dominio que se quiere analizar (ej. `ejemplo.com`).                     |
| `--connect`                  | Intenta establecer una conexión HTTP con los hosts que no pertenecen a redes privadas (no RFC 1918). |
| `--wide`                     | Escanea toda la red de clase C de los registros DNS encontrados.                      |
| `--traverse TRAVERSE`        | Escanea direcciones IP cercanas a las descubiertas, pero sin salir de la clase C actual. |
| `--search SEARCH [...]`      | Filtra los dominios cuando se expande la búsqueda. Se pueden especificar varios.      |
| `--range RANGE`              | Escanea un rango de IP interno usando notación CIDR (ej. `192.168.1.0/24`).           |
| `--delay DELAY`              | Define el tiempo de espera entre cada consulta DNS (en segundos).                     |
| `--subdomains SUBDOMAINS [...]` | Usa una lista de subdominios específica para intentar descubrir hosts (ej. `www`, `mail`, `ftp`). |
| `--subdomain-file SUBDOMAIN_FILE` | Usa un archivo con subdominios (uno por línea) para fuerza bruta.                   |
| `--dns-servers DNS_SERVERS [...]` | Usa servidores DNS específicos para realizar búsquedas inversas.                    |
| `--dns-file DNS_FILE`        | Usa un archivo con servidores DNS (uno por línea) para búsquedas inversas.           |
| `--tcp`                      | Realiza las consultas DNS usando el protocolo TCP en lugar de UDP.                    |

### 🧠 ¿Qué significa “non-contiguous IP space”?

La frase “non-contiguous IP space” se refiere a ***espacios de direcciones IP que no están seguidos o agrupados***, es decir, que pueden estar dispersos en diferentes rangos. Fierce ayuda a descubrir estos espacios ocultos que no se ven fácilmente con escaneos tradicionales.

### 🧩 ¿Qué es RFC 1918?

Es un estándar que define los ***rangos de IP privadas*** que no son accesibles desde Internet. Ejemplos:

- 10.0.0.0/8
- 172.16.0.0/12
- 192.168.0.0/16

La opción `--connect` evita estos rangos y se enfoca en hosts públicos.

## 🧠 ¿Por qué usar Fierce?

Fierce es muy útil especialmente cuando:

- No se conoce el rango IP completo de una organización.
- Se quiere evitar escaneo activo que pueda ser detectado.
- Se busca identificar subdominios ocultos o mal configurados.
- Se desea realizar un reconocimiento inicial antes de usar herramientas más agresivas.

## 📚 Referencias y documentación

- [🔗 Wiki de Fierce en Aldeid](https://www.aldeid.com/wiki/Fierce)
- [📘 Kali Linux Tools - Fierce](https://tools.kali.org/information-gathering/fierce)
- [📖 OWASP DNS Enumeration](https://owasp.org/www-community/DNS_Enumeration)
- [🧠 ARIN Whois Database](https://www.arin.net/resources/registry/whois/)



## 📖 Glosario de términos clave

| Término                        | Explicación sencilla                                                                 |
|-------------------------------|--------------------------------------------------------------------------------------|
| **Dominio**                   | Nombre que identifica un sitio web (ej. `google.com`).                              |
| **DNS (Domain Name System)**  | Sistema que traduce nombres de dominio en direcciones IP.                           |
| **Servidor DNS**              | Máquina que responde consultas sobre nombres de dominio.                            |
| **Subdominio**                | Parte adicional de un dominio (ej. `blog.google.com`).                              |
| **Fuerza bruta de subdominios** | Técnica para descubrir subdominios probando muchas combinaciones de nombres.        |
| **WHOIS**                     | Servicio que muestra información sobre la propiedad de un dominio o IP.             |
| **ARIN**                      | Registro regional que gestiona direcciones IP en América del Norte.                 |
| **Rango IP**                  | Conjunto de direcciones IP dentro de una red (ej. `192.168.1.0/24`).                |
| **Reconocimiento pasivo**     | Recolección de información sin interactuar directamente con el sistema objetivo.    |
