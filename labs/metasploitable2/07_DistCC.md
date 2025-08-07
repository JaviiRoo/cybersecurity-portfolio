# 🧠 Objetivo del laboratorio (DistCC)

Aprenderemos a identificar, explotar y obtener acceso remoto a un sistema con DistCC mal configurado. Este servicio, cuando está expuesto y sin autenticación, permite ejecutar comandos arbitrarios en el sistema remoto, lo que facilita una Remote Command Execution (RCE).

# 🧩 ¿Qué es DistCC?

DistCC es una herramienta diseñada para distribuir compilaciones de código C/C++ a través de múltiples máquinas, acelerando el proceso de compilación.
Sin embargo, si no está configurado adecuadamente (sin autenticación y expuesto en la red), permite a cualquier atacante remoto ejecutar comandos arbitrarios, lo cual es crítico.

# 🎯 Qué haremos

1. Escanearemos la máquina para detectar el servicio DistCC.
2. Verificaremos manualmente si está vulnerable.
3. Explotaremos la vulnerabilidad.

## 🔍 Paso 1: Escaneo con Nmap

```bash
nmap -sV -p 3632 192.168.26.102
```

Obtenemos como resultado:



