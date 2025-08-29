# 🧭 Dmitry — Herramienta de Reconocimiento Pasivo Multifuncción

## 📌 Descripción General

**Dmitry** (Deepmagic Information Gathering Tool) es una herramienta de línea de comandos para sistemas Linux, diseñada para realizar tareas de ***reconocimiento pasivo*** sobre un host o dominio. Su objetivo es recolectar la mayor cantidad de información posible sin interactuar directamente con los sistemas internos del objetivo.

🔍 Dmitry es ideal para la fase inicial de un test de penetración, donde se busca mapear el entorno sin generar alertas ni tráfico sospechoso.

## 🧪 ¿Qué puede hacer Dmitry?

- 🔹 Consultas **Whois** sobre el dominio y su IP.
- 🔹 Búsqueda de **subdominios** asociados.
- 🔹 Enumeración de **correos electrónicos** públicos.
- 🔹 Consulta de información histórica en **Netcraft** (aunque actualmente limitada).
- 🔹 Escaneo de **puertos TCP** (opcional).
- 🔹 Guardado de resultados en un archivo.

## ⚙️ Instalación

En Kali Linux, Dmitry suele estar preinstalado. Si no lo está:

```Bash
sudo apt update
sudo apt install dmitry
```

## 🚀 Ejemplo de uso

```Bash
dimtry -w -e -n -s example.com -o /tmp/resultado_dmitry.txt
```

Este comando realiza:

- `-w`: Consulta Whois del dominio.
- `-e`: Búsqueda de correos electrónicos públicos.
- `-n`: Consulta en Netcraft.
- `-s`: Búsqueda de subdominios.
- `-o`: Guarda el resultado en /tmp/resultado_dmitry.txt.

✅ El dominio example.com es seguro, funcional y público. Ideal para pruebas sin afectar a terceros.

## 📋 Parámetros comunes

| Parámetro | Descripción                                                                 |
|-----------|-----------------------------------------------------------------------------|
| `-w`      | Realiza una consulta Whois sobre el dominio.                                |
| `-i`      | Realiza una consulta Whois sobre la IP del dominio.                         |
| `-e`      | Busca direcciones de correo electrónico asociadas al dominio.               |
| `-n`      | Intenta obtener información desde Netcraft (puede estar obsoleta).          |
| `-s`      | Busca subdominios relacionados.                                             |
| `-p`      | Realiza un escaneo de puertos TCP.                                          |
| `-f`      | Escaneo de puertos mostrando los filtrados.                                 |
| `-b`      | Lee el banner recibido del puerto escaneado.                                |
| `-t 0-9`  | Define el TTL (tiempo de espera) para escaneo de puertos.                   |
| `-o`      | Guarda la salida en un archivo especificado.                                |

## 📊 Interpretación de resultados

La siguiente salida corresponde a la ejecución del comando anterior con Dmitry sobre el dominio `example.com`, utilizando las opciones `-w -e -n -s -o`. 

## 🌐 Información general del host

<img width="480" height="156" alt="imagen" src="https://github.com/user-attachments/assets/cef5f0fb-b56d-4f2b-9014-cc6f25a94bb2" />

```Text
HostIP: 23.220.75.245
HostName: example.com
```

- **HostIP:** Dirección IP pública asociada al dominio.
- **HostName:** Nombre del dominio analizado.

## 🧾 Información Whois del dominio

<img width="745" height="405" alt="imagen" src="https://github.com/user-attachments/assets/e61a221d-590a-4aaa-9c6c-9047722a86e4" />

```Text
Domain Name: EXAMPLE.COM
Creation Date: 1995-08-14
Registry Expiry Date: 2026-08-13
Registrar: RESERVED-Internet Assigned Numbers Authority
Name Server: A.IANA-SERVERS.NET, B.IANA-SERVERS.NET
DNSSEC: signedDelegation
```

- **Creation Date:** Fecha en que se registró el dominio.
- **Expiry Date:** Fecha de expiración del registro actual.
- **Registrar:** Entidad responsable del dominio (IANA en este caso).
- **Name Servers:** Servidores DNS que gestionan el dominio.
- **DNSSEC:** Indica que el dominio usa seguridad DNS (verificación criptográfica).

💡 Esta información es útil para saber si el dominio está activo, quién lo gestiona y si tiene medidas de seguridad básicas.

## 🌍 Información Netcraft

<img width="415" height="120" alt="imagen" src="https://github.com/user-attachments/assets/d9599660-f09d-40ce-a8a2-91980b0390aa" />

```Text
Retrieving Netcraft.com information for example.com
Netcraft.com Information gathered
```

- Dmitry intenta consultar Netcraft para obtener información sobre el servidor web, tecnologías utilizadas y historial de hosting.
- En este caso, no se muestra información detallada, lo cual es común ya que la opción -n está parcialmente obsoleta.

## 🧭 Subdominios encontrados

<img width="720" height="151" alt="imagen" src="https://github.com/user-attachments/assets/4692185c-72e0-418c-8aac-1df7453cd9ff" />

```Text
HostName: www.example.com
HostIP: 2.16.54.147
Found 2 possible subdomain(s)
```

- Dmitry ha detectado subdominios como www.example.com, lo cual puede revelar servicios web activos.
- La IP indica dónde está alojado ese subdominio.

🔍 Descubrir subdominios es clave para ampliar la superficie de análisis en una auditoría.

## 📧 Correos electrónicos públicos

<img width="633" height="732" alt="imagen" src="https://github.com/user-attachments/assets/a0acff69-e1ff-44e7-a821-19408087ecea" />

```Text
Found 38 E-Mail(s) for host example.com
example@example.com
contact@example.com
support@example.com
...
```

- Dmitry ha encontrado 38 direcciones de correo electrónico asociadas al dominio, probablemente extraídas de fuentes públicas como Google.
- Estos correos pueden ser útiles para ingeniería social, análisis de exposición o contacto legítimo.

⚠️ Aunque estas direcciones son genéricas, en dominios reales pueden incluir nombres de empleados, roles internos o correos sensibles.

## ✅ Conclusión

Dmitry ha completado exitosamente:

- Consulta Whois del dominio.

- Búsqueda de subdominios.

- Recolección de correos electrónicos públicos.

- Intento de consulta Netcraft.

La información obtenida es valiosa para la fase de reconocimiento pasivo en auditorías de seguridad, sin generar tráfico sospechoso ni alertas en el sistema objetivo.

## 📖 Glosario de términos clave

| Término         | Explicación sencilla                                                                 |
|-----------------|--------------------------------------------------------------------------------------|
| **Whois**       | Servicio que muestra información sobre el propietario de un dominio o IP.           |
| **Subdominio**  | Parte adicional de un dominio (ej. `blog.example.com`).                             |
| **Netcraft**    | Servicio que ofrece información sobre servidores web, tecnologías y hosting.        |
| **Correo público** | Dirección de email visible en registros o páginas asociadas al dominio.         |
| **Escaneo TCP** | Proceso para detectar puertos abiertos en un host.                                  |
| **Banner**      | Texto que devuelve un servicio al conectarse a un puerto (puede revelar software).  |
| **TTL**         | Tiempo de espera para recibir respuesta en escaneos de red.                         |
