# 🕵️‍♂️ Metagoofil — Reconocimiento Pasivo a Través de Metadatos
## 📌 Descripción General

Metagoofil es una herramienta de reconocimiento pasivo que permite recolectar documentos públicos disponibles en Internet asociados a un dominio específico, y extraer sus metadatos. Estos metadatos pueden revelar información sensible como nombres de usuario, correos electrónicos, rutas internas, versiones de software y más.

🔍 Metagoofil no explota vulnerabilidades, sino que aprovecha la información que las organizaciones publican sin darse cuenta.

## 🧰 ¿Para qué sirve?

Metagoofil es útil en la fase de reconocimiento de un test de penetración o auditoría de seguridad. Permite:

- Identificar posibles vectores de ataque.

- Descubrir usuarios internos y software utilizado.

- Obtener información sin interactuar directamente con el sistema objetivo (evitando alertas en sistemas de detección).

## ⚙️ Instalación en Kali Linux

```bash
sudo apt update
sudo apt install metagoofil
```

Esto instalará también la dependencia python3-googlesearch, que permite realizar búsquedas en Google desde la terminal.

## 🧪 Ejemplo de uso

```bash
metagoofil -d ejemplo.com -t pdf,doc,xls -l 100 -n 10 -o /tmp/ -f /tmp/resultados.html
```

Parámetros:

| Parámetro | Descripción |
|-----------|-------------|
| `-d`      | Dominio objetivo (ej. `ejemplo.com`) |
| `-t`      | Tipos de archivo a buscar (`pdf`, `doc`, `xls`, etc.) |
| `-l`      | Número máximo de resultados a buscar |
| `-n`      | Número máximo de documentos a descargar |
| `-o`      | Carpeta de salida para los documentos |
| `-f`      | Archivo HTML con el resumen de resultados |

## 📄 ¿Qué metadatos se pueden extraer?

Una vez descargados los documentos, Metagoofil analiza los metadatos usando herramientas como exiftool o strings. Algunos datos que puede revelar:

- Autor del documento

- Software utilizado para crearlo

- Fecha de creación/modificación

- Ruta interna del sistema (ej. C:\Users\Juan\Documents\...)

- Nombre de la máquina o usuario

## 🧠 Buenas prácticas

- Utiliza Metagoofil en entornos controlados o con autorización explícita.

- Complementa su uso con herramientas como theHarvester, Maltego, Recon-ng para un reconocimiento más completo.

- No te limites a un solo tipo de archivo: los .docx, .xlsx y .pptx también pueden contener metadatos valiosos.

## 📚 Documentación y referencias

- [🔗 Repositorio oficial en GitHub (archivado)](https://github.com/laramies/metagoofil)
- [📖 OWASP Reconnaissance Guide](https://owasp.org/www-community/Reconnaissance)
- [📘 Kali Tools Metagoofil](https://tools.kali.org/information-gathering/metagoofil)
- [📄 Google Dorks para búsqueda avanzada](https://www.exploit-db.com/google-hacking-database)

## 🧩 Ejemplo práctico

```Bash
metagoofil -d microsoft.com -t pdf -l 50 -n 10 -o ./docs -f ./metagoofil_microsoft.html
```

Este comando buscará hasta 50 PDFs públicos en el dominio microsoft.com, descargará 10 de ellos, y generará un informe HTML con los metadatos extraídos.

