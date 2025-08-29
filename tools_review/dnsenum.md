# 🧭 DNSenum — Enumeración de DNS para Reconocimiento Pasivo

## 📌 Descripción General

**DNSenum** es una herramienta de enumeración de DNS escrita en lenguaje Perl, diseñada para recolectar la mayor cantidad de información posible sobre un dominio objetivo. Se utiliza principalmente en la ***fase de reconocimiento pasivo*** de una auditoría de seguridad o test de penetración.
Su objetivo es mapear la infraestructura de red de una organización a través de consultas DNS, búsuqedas en Google, fuerza bruta de subdominios y análisis de rangos IP.

🔍 DNSenum no interactúa directamente con los sistemas internos del objetivo, lo que lo convierte en una herramienta ideal para recopilar información sin ser detectado.

## 🧪 ¿Qué operaciones realiza?

DNSenum puede realizar las siguientes tareas:

- 🔹Obtener la ***IP del host*** (registro A).
- 🔹Identificar los ***servidores de nombres*** (registros NS).
- 🔹Obtener el ***registro MX*** (servidores de correo).
- 🔹Realizar ***consultas AXFR*** (transferencias de zona DNS).
- 🔹Detectar la ***versión BIND*** (software de servidor DNS).
- 🔹Buscar ***subdominios adicionales*** mediante Google Dorks.
- 🔹Realizar ***fuerza bruta*** de subdominios desde un archivo.
- 🔹Ejecutar ***recursividad*** sobre subdominios con registros NS.
- 🔹Calcular ***rangos de red*** en clase C y realizar ***consultas Whois***.
- 🔹Realizar ***consultas inversas*** sobre rangos IP.
- 🔹Guardar los bloques IP en un archivo domain_ips.txt.

## ⚙️ Instalación

En Kali Linux, DNSenum suele estar preinstalado. Si no lo está, puedes instalarlo manualmente:

```Bash
sudo apt update
sudo apt install dnsenum
```

## 🚀 Ejemplo básico de uso

```Bash
dnsenum --enum hackthissite.org
```

Este comando realiza una enumeración completa del dominio `hackthissite.org`.

## 📋 Parámetros comunes

| Parámetro     | Descripción                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `--enum`      | Atajo que ejecuta `--threads 5 -s 15 -w` para una enumeración completa.     |
| `--threads`   | Número de hilos para ejecutar consultas en paralelo.                        |
| `-s`          | Número máximo de subdominios a extraer desde Google.                        |
| `-w`          | Realiza consultas Whois sobre rangos de red clase C.                        |
| `-f`          | Archivo de subdominios para fuerza bruta.                                   |
| `-r`          | Activa recursividad sobre subdominios con registros NS.                     |
| `-t`          | Realiza transferencia de zona (AXFR) si es posible.                         |
| `-o`          | Especifica archivo de salida para guardar resultados.                       |

## 🧠 ¿Qué significa --enum?

La opción `--enum` es un **atajo** que ejecuta tres acciones clave a la vez:

- `--threads 5`: Usa 5 hilos para acelerar las consultas.
- `-s 15`: Extra hasta 15 subdominios desde Google.
- `-w`: Realiza consultas Whois sobre los rangos IP encontrados.

En otras palabras, `--enum` es como si dijéramos: "Hazme una búsqueda completa, rápida y profunda del dominio".

## 📚 Referencias y documentación

- [🔗 Repositorio archivado en Google Code](https://code.google.com/archive/p/dnsenum/)
- [📘 Kali Linux Tools - DNSenum](https://tools.kali.org/information-gathering/dnsenum)
- [📖 OWASP DNS Enumeration Guide](https://owasp.org/www-community/DNS_Enumeration)
- [🧠 Google Hacking Database (Exploit-DB)](https://www.exploit-db.com/google-hacking-database)

## 📖 Glosario de términos clave

| Término                    | Explicación sencilla                                                                 |
|---------------------------|--------------------------------------------------------------------------------------|
| **Dominio**               | Nombre que identifica un sitio web (ej. `google.com`).                              |
| **IP del Host (Registro A)** | Dirección IP asociada al dominio principal.                                         |
| **Registro MX**           | Servidores encargados de recibir correos electrónicos del dominio.                  |
| **Consulta AXFR**         | Solicitud para copiar toda la zona DNS de un servidor (si está mal configurado, puede revelar todo el mapa de red). |
| **Versión BIND**          | Software que gestiona servidores DNS. Saber la versión puede ayudar a detectar vulnerabilidades. |
| **Recursividad en subdominios** | Técnica para investigar si los subdominios también tienen sus propios servidores DNS. |
| **Registro NS**           | Indica qué servidores gestionan el DNS del dominio.                                 |
| **Clase C**               | Segmento de red que agrupa direcciones IP similares (ej. `192.168.1.0/24`).         |
| **Consulta Whois**        | Permite saber quién es el propietario de un dominio o IP, incluyendo datos de contacto y ubicación. |
