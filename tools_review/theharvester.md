# 🧭 theHarvester — Recolección de Inteligencia OSINT

## 📌 Descripción General

**theHarvester** es una herramienta de ***reconocimiento pasivo*** que permite recolectar información pública sobre dominios, empresas o entidades. Utiliza múltiples fuentes abiertas (OSINT) como motores de búsqueda, redes sociales, bases de datos de certificados y servicios especializados para obtener:

- Direcciones de correo electrónico.
- Subdominios.
- Hosts virtuales.
- Banners de puertos abiertos.
- Nombres de empleados.

🔍 Es ideal para la ***fase inicial*** de un test de penetración, donde se busca mapear la superficie de exposición sin interactuar directamente con los sistemas objetivo.

## ⚙️ Instalación

En Kali Linux, theHarvester suele estar preinstalado. Si no lo tienes:

```Bash
sudo apt update
sudo apt install theharvester
```

O puedes instalarlo manualmente:

```Bash
git clone https://github.com/laramies/theHarvester.git
cd theHarvester
pip3 install -r requirements.txt
```

## 🚀 Ejemplo de uso

Este comando solicita a theHarvester que busque información pública sobre el dominio mozilla.org utilizando el motor de búsqueda Bing, limitado a 100 resultados.

```Bash
theHarvester -d mozilla.org -l 100 -b bing
```

- `mozilla.org` es un dominio público y legítimo, ideal para pruebas reales.
- Se limita la búsqueda a 100 resultados.
- Se usa **Bing** como fuente de datos.

✅ Este comando buscará correos, subdominios y hosts relacionados con Mozilla usando Bing como motor.

## 📋 Parámetros comunes

| Parámetro       | Descripción                                                                 |
|-----------------|-----------------------------------------------------------------------------|
| `-d`            | Dominio o nombre de empresa a investigar.                                   |
| `-b`            | Fuente de datos (ej. `google`, `bing`, `crtsh`, `shodan`, `linkedin`).      |
| `-l`            | Número máximo de resultados a recolectar.                                   |
| `-c`            | Fuerza bruta de subdominios (DNS brute).                                    |
| `-r`            | Resuelve DNS de los subdominios encontrados.                                |
| `-f <archivo>`  | Guarda los resultados en formato XML y JSON.                                |
| `-h`            | Muestra el menú de ayuda.                                                    |

## 📊 Interpretación del resultado

Salida generada por theHarvester al consultar el dominio [mozilla.org](https://mozilla.org) usando Bing como fuente. Se identificó un subdominio activo, aunque no se encontraron correos ni IPs. También se documenta el error al intentar usar Google como fuente, actualmente no soportada. 

<img width="551" height="525" alt="imagen" src="https://github.com/user-attachments/assets/7bcb6912-ccab-47fc-9492-c2338f2b0ae8" />

### 🧾 Encabezado del programa

```Text
theHarvester 4.8.2
Coded by Christian Martorella
Edge-Security Research
```

- Muestra la versión y el autor de la herramienta.
- Confirma que se están leyendo los archivos de configuración (`proxies.yaml`, `api-keys.yaml`).

### 📍 Resultados obtenidos

```Text
[*] Target: mozilla.org
[*] Searching Bing.
[*] No IPs found.
[*] No emails found.
[*] No people found.
[*] Hosts found: 1
---------------------
support.mozilla.org
```

- **No IPs found:** No se encontraron direcciones IP asociadas directamente al dominio.
- **No emails found:** No se encontraron correos públicos en los resultados analizados.
- **No people found:** No se identificaron nombres de personas o empleados.
- **Hosts found:** Se encontró un subdominio: support.mozilla.org

✅ Esto indica que Bing devolvió resultados limitados, pero se logró identificar al menos un subdominio activo.


## 🌐 Fuentes disponibles

theHarvester puede consultar múltiples fuentes OSINT:

- Motores de búsqueda: bing, duckduckgo, yahoo, baidu.
- Redes sociales: linkedin, twitter, googleplus.
- Infraestructura: shoda, hackertarget, zoomeye.
- Otros: pgp, people123, jigsaw, vhost, googleCSW.

💡 Usar múltiples fuentes amplía la cobertura y mejora la calidad de los datos recolectados.

## 📖 Glosario técnico

| Término              | Explicación sencilla                                                                 |
|----------------------|--------------------------------------------------------------------------------------|
| **OSINT**            | Inteligencia obtenida de fuentes abiertas y públicas.                               |
| **Subdominio**       | Parte adicional de un dominio (ej. `blog.mozilla.org`).                             |
| **PGP**              | Sistema de cifrado que puede revelar claves públicas y correos asociados.           |
| **Shodan**           | Motor de búsqueda de dispositivos conectados a Internet.                            |
| **crt.sh**           | Base de datos de certificados SSL/TLS públicos.                                     |
| **Banners**          | Información que devuelve un servicio al conectarse (ej. versión de Apache).         |
| **DNS brute**        | Técnica para descubrir subdominios probando combinaciones comunes.                  |
| **LinkedIn**         | Fuente útil para encontrar nombres de empleados y correos corporativos.             |
