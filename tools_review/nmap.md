# 📚 Introducción.

Nmap (Network Mapper) es una herramienta de código abierto para descubrimiento de hosts y servicios en una red. Su potencia radica en su versatilidad: desde escaneos rápidos hasta auditorías completas de redes. Es una herramienta imprescindible para pentesters, administradores de red, y equipos de seguridad.

# ⚙️ Instalación.

## En Debian/Ubuntu
```bash
sudo apt install nmap
```
## En macOS con Homebrew
brew install nmap

## Windows
Descargar desde https://nmap.org/download.html

# 🔍 Principales funcionalidades.

- Host discovery (Ping Scan) – Identificación de dispositivos activos

- Port scanning – Detección de puertos abiertos y servicios

- Version detection – Identificación de versiones de servicios

- OS detection – Determinación del sistema operativo

- Script scanning (NSE) – Ejecución de scripts personalizados para detectar vulnerabilidades

# 🧪 Tipos de escaneo.

| Tipo de escaneo           | Comando     | Descripción                                      |
|---------------------------|-------------|--------------------------------------------------|
| Escaneo TCP Connect       | `nmap -sT`  | Establece conexión completa TCP                 |
| Escaneo SYN (Stealth)     | `nmap -sS`  | Semiconexión (half-open)                        |
| Escaneo UDP               | `nmap -sU`  | Escanea puertos UDP                             |
| Escaneo de versiones      | `nmap -sV`  | Detecta versiones de servicios                  |
| Escaneo de OS             | `nmap -O`   | Intenta identificar el sistema operativo        |
| Escaneo ICMP              | `nmap -PE`  | Ping mediante ICMP Echo                         |
| Escaneo de ping           | `nmap -sn`  | Detecta hosts activos sin escanear puertos      |


# 🧠 NSE – Nmap Scripting Engine.

- Permite usar scripts para detección avanzada, explotación, enumeración, etc.

- Scripts organizados por categoría en /usr/share/nmap/scripts/

# 🗂️ Categorías útiles:

| Categoría  | Ejemplo de uso                            |
|------------|--------------------------------------------|
| `auth`     | Autenticación: fuerza bruta, bypass        |
| `vuln`     | Pruebas de vulnerabilidades                |
| `default`  | Conjunto estándar de scripts útiles        |
| `malware`  | Detección de bots, backdoors               |


📌 Ejemplo:

nmap --script vuln -p 80,443 <IP>

📋 Ejemplos prácticos
```bash
# Escaneo rápido
nmap -F <IP>

# Escaneo completo de puertos TCP
nmap -p- <IP>

# Detección de sistema operativo y versiones
nmap -A <IP>

# Enumeración de servicios específicos
nmap -p 21,22,80 -sV <IP>

# Utilizar script específico
nmap --script http-enum -p 80 <IP>
```
🧠 Buenas prácticas en pentesting

✅ Realiza escaneos de reconocimiento primero (-sn o -F)

✅ Usa -Pn para omitir ping si el firewall bloquea ICMP

✅ Ajusta el “timing” según el entorno con -T0 a -T5

✅ Exporta resultados para análisis posterior (-oA, -oN, -oX)

# 🧾 Exportar resultados

| Formato | Comando              |
|---------|----------------------|
| Normal  | `-oN resultado.txt`  |
| XML     | `-oX resultado.xml`  |
| Grep    | `-oG resultado.grep` |
| Todos   | `-oA resultado_base` |


# 📚 Recursos adicionales

- [Documentación oficial](https://nmap.org/docs.html).

- [Base de datos NSE Script](https://nmap.org/nsedoc/).

- Libro: Nmap Network Scanning por Gordon “Fyodor” Lyon.

📌 Consejos personales como pentester

- Crea tus propios perfiles de escaneo (nmap -iL targets.txt).

- Automatiza escaneos con tus propios scripts en Bash o Python.

- Usa Wireshark paralelo a Nmap para validar tráfico y fingerprint.

Automatiza escaneos con tus propios scripts en Bash o Python

Usa Wireshark paralelo a Nmap para validar tráfico y fingerprint
