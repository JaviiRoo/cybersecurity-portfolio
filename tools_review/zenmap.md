# 🧭 Zenmap — Interfaz Gráfica de Nmap

## 📌 Descripción General

**Zenmap** es la interfaz gráfica oficial de **Nmap**, el escáner de seguridad más utilizado en el mundo. Diseñado para facilitar el uso de Nmap tanto a principiantes como a usuarios avanzados, Zenmap permite ejecutar escaneos de red, visualizar resultados, guardar perfiles personalizados y comparar escaneos anteriores.

Es una herramienta **multiplataforma**, **open source** y **gratuita**, disponible para Linux, Windows, macOS y BSD.

---

## ⚙️ Instalación

### En Debian/Ubuntu/Kali Linux

```bash
sudo apt update
sudo apt install zenmap
```

### En Fedora

```Bash
sudo dnf install nmap-ncat zenmap
```

### En Arch Linux

```Bash
sudo pacman -S nmap zenmap
```

Una vez instalado, se puede ejecutar desde el menú de aplicaciones con:

```Bash
zenmap
```

## 🖥️ Interfaz de Zenmap

La interfaz de Zenmap se compone de:

- **Campo de destino:** IP o dominio a escanear.
- **Perfil de escaneo:** Selección de tipo de escaneo (intenso, rápido, ping, etc).
- **Campo de comandos:** Muestra el comando Nmap equivalente.
- **Panel de resultados:** Visualización en pestañas (Nmap Output, Ports/Hosts, Topology, Host Details, Scans).
- **Mapa topológico:** Representación gráfica de la red descubierta.

## 🚀 Funcionalidades clave

- ✅ Escaneos predefinidos y personalizados.
- ✅ Generador interactivo de comandos Nmap.
- ✅ Visualización de resultados en múltiples formatos.
- ✅ Comparación entre escaneos anteriores.
- ✅ Base de datos local de escaneos recientes.
- ✅ Exportación de resultados en XML, TXT y otros formatos.
- ✅ Mapa topológico de red.
- ✅ Búsqueda avanzada por puertos, servicios o IPs.

## 🧪 Ejemplos de uso

### Escaneo rápido de una IP

- Perfil: `Quick Scan`
- Comando generado: `nmap -T4 -F <IP>`

### Escaneo intenso de todos los puertos

- Perfil: `Intense Scan`
- Comando generado: `nmap -T4 -A -V <IP>`

### Escaneo de subred completa

- Destino: `192.168.1.0/24`
- Perfil: `Ping Scan`
- Comando generado: `nmap -sn 192.168.1.0/24`

## 📊 Comparativa: Zenmap vs Nmap CLI

| Característica             | Nmap CLI             | Zenmap GUI                          |
|---------------------------|----------------------|-------------------------------------|
| Facilidad de uso          | Requiere experiencia | Intuitivo y visual                  |
| Visualización de resultados | Solo texto           | Tablas, gráficos, mapas             |
| Creación de comandos      | Manual               | Asistente interactivo               |
| Guardado de escaneos      | Manual               | Automático y buscable               |
| Comparación de escaneos   | No disponible        | Sí, con resaltado de diferencias    |


## 📘 Glosario técnico

| Término         | Explicación sencilla                                                                 |
|-----------------|--------------------------------------------------------------------------------------|
| **Nmap**        | Herramienta de escaneo de redes y detección de servicios.                           |
| **Zenmap**      | Interfaz gráfica oficial de Nmap.                                                    |
| **Perfil de escaneo** | Configuración predefinida para ejecutar escaneos específicos.               |
| **Mapa topológico** | Representación visual de los hosts descubiertos y su relación en la red.       |
| **Escaneo intenso** | Escaneo profundo que incluye detección de sistema operativo y servicios.        |
| **Ping Scan**   | Escaneo que detecta qué hosts están activos sin escanear puertos.                   |

## ✅ Buenas prácticas

- Usa [Scanme.nmap.org](https://Scanme.nmap.org) como entorno legal para pruebas públicas.
- Guarda tus escaneos para comparar cambios en la red.
- Usa perfiles personalizados para automatizar auditorías.
- No escanee redes sin autorización: es ilegal.

## 🔗 Recursos adicionales

- [Documentación oficial de Zenmap](https://nmap.org/zenmap/)
- [Guía práctica de Zenmap en TheLinuxCode](https://thelinuxcode.com/zenmap_ubuntu_nmap)
- [Tutoría en español con ejemplos prácticos](https://ciberseguridadmax.com/zenmap/)
