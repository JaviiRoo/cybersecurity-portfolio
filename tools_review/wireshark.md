# 🧪 Wireshark: Guía Completa para Principiantes

## 📌 ¿Qué es Wireshark?

**Wireshark** es una herramienta de análisis de protocolos de red (network protocol analyzer) que permite capturar, inspeccionar y visualizar el tráfico que pasa por una interfaz de red. Es ampliamente utilizada en ciberseguridad, administración de redes y análisis forense digital.

Wireshark es como un microscopio para redes: te permite ver lo que está ocurriendo a nivel de paquetes, entender cómo se comunican los dispositivos y detectar posibles vulnerabilidades o comportamientos sospechosos.

---

## 🛠️ Características principales

- Captura en tiempo real del tráfico de red.
- Soporte para cientos de protocolos (TCP, UDP, HTTP, FTP, DNS, etc.).
- Filtros avanzados para búsqueda y análisis.
- Exportación de capturas en formato `.pcap` para análisis posterior.
- Interfaz gráfica intuitiva y potente.
- Compatible con Linux, Windows y macOS.

---

## 🚀 Instalación en Kali Linux

Wireshark ya viene preinstalado en Kali. Para ejecutarlo:

```bash
sudo wireshark
```

Si no lo tienes instalado, utiliza:

```bash
sudo apt update
sudo apt install wireshark
```

Durante la instalación, se te preguntará si los usuarios no root pueden capturar paquetes. Elige "Sí" si quieres evitar usar sudo cada vez.

## 🎯 ¿Para qué se usa Wireshark?

| Uso común                  | Descripción                                                                 |
|---------------------------|------------------------------------------------------------------------------|
| 🕵️‍♂️ Pentesting            | Identificación de credenciales en texto plano, protocolos inseguros, etc.   |
| 🧑‍💻 Administración de redes | Diagnóstico de problemas de conectividad y rendimiento.                    |
| 🔍 Análisis forense        | Investigación de incidentes de seguridad y reconstrucción de sesiones.     |
| 📡 Educación               | Aprendizaje de cómo funcionan los protocolos de red en tiempo real.        |


## 🧭 Primeros pasos: Captura básica

1. Abrir Wireshark.
2. Selecciona la interfaz de red activa (eth0, wlan0...).
3. Haz clic en el botón de inicio (tiburón azul).
4. Observa cómo se capturan paquetes en tiempo real.

## 🔎 Filtros útiles

Wireshark permite aplicar filtros para enfocar el análisis. Algunos ejemplos:

- http -> Muestra solo tráfico HTTP.
- ip.addr == 192.168.1.10 -> Filtra paquetes relacionados con esa IP.
- tcp.port == 21 -> Mutra tráfico FTP.
- ftp || telnet -> Muestra tráfico de protocolos inseguros.

## 📂 Guardar y abrir capturas

- Para guardar una captura: File > Save As -> formato .pcapng o .pcap.
- Para abrir una captura previa: File > Open.

Esto permite analizar el tráfico más tarde o compartirlo con otros analistas.

## 🧠 Análisis de credenciales en texto plano

Ejemplo: Si capturas tráfico FTP o Telnet, puedes buscar paquetes que contengan:

- USER <nombre_usuario>
- PASS <contraseña>

Estos protocolos no cifran la información, por lo que las credenciales pueden verse directamente en Wireshark.

## ⚙️ Automatización con TShark

TShark es la versión por línea de comandos de Wireshark. Ideal para automatizar tareas.

Ejemplo: Capturar tráfico FTP y guardar en archivo

```bash
tshark -i eth0 -f "port 21" -w ftp_capture.pcap
```

Ejemplo: Extraer líneas con credenciales

```bash
tshark -r ftp_capture.pcap -Y "ftp.request.command == USER || ftp.request.command == PASS"
```

## 🧰 Integración con otras herramientas

Wireshark puede trabajar junto a herramientas como:

- **tcpdump**: Captura rápida desde terminal.
- **Ettercap**: Sniffing y MITM.
- **Nmap**: Escaneo de puertos y servicios.
- **Metasploit**: Explotación de vulnerabilidades.

## 📚 Recursos recomendados

- [Documentación oficial de Wireshark](https://www.wireshark.org/docs/).
- [Wireshark Wiki](https://wiki.wireshark.org/).
- [Tutoriales en Youtube](https://www.youtube.com/results?search_query=wireshark+tutorial).

## 🧠 Conclusión

Wireshark es una herramienta esencial para cualquier profesional o estudiante de ciberseguridad. Aprender a usarla te permitirá entender el funcionamiento interno de las redes, detectar vulnerabilidades y mejorar tus habilidades de análisis técnico.

¡Explora, experimenta y captura el conocimiento, paquete por paquete! 📦🔍


