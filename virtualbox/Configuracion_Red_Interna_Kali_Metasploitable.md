# 🖧 Configuración de Red Interna en VirtualBox: Kali Linux y Metasploitable2

Este documento explica cómo configurar correctamente una red interna entre dos máquinas virtuales en VirtualBox: Kali Linux y Metasploitable2. Es útil especialmente si estás usando una red móvil o tienes problemas de conectividad entre las máquinas.

---

## 📦 Requisitos

- VirtualBox instalado
- ISO de Kali Linux
- Imagen de Metasploitable2
- Conexión a Internet (opcional, solo para Kali si se desea acceso externo)

---

## 🛠️ Paso 1: Configurar adaptadores de red en VirtualBox

### 🔧 Kali Linux

1. Abre VirtualBox y selecciona tu máquina Kali
2. Ve a **Configuración → Red**
3. Activa **Adaptador 1**:
   - Modo: `Adaptador puente` (para acceso a Internet)
4. Activa **Adaptador 2**:
   - Modo: `Red interna`
   - Nombre: `RedInterna` (puedes usar cualquier nombre, pero debe coincidir en ambas máquinas)

### 🔧 Metasploitable2

1. Selecciona la máquina Metasploitable2
2. Ve a **Configuración → Red**
3. Activa **Adaptador 1**:
   - Modo: `Red interna`
   - Nombre: `RedInterna` (igual que en Kali)

---

## 🧬 Paso 2: Asignar IPs manualmente

### 🖥️ En Kali Linux

Abre una terminal y ejecuta:

```bash
sudo ip addr add 192.168.56.10/24 dev eth1
```

Esto asigna una IP a la interfaz de red interna (eth1).

Verificamos con:

```bash
ip a
```

### En Metasploitable2

Iniciamos sesión con:

usuario: msfadmin
contraseña: msfadmin

Luego ejecutamos:

```bash
sudo ifconfig eth0 192.168.56.102 netmask 255.255.255.0 up
```

Verificamos con:

```bash
ifconfig
```

## 🔍 Paso 3: Verificar conectividad

Desde la máquina Kali:

```bash
ping 192.168.56.102
```

Si responde al ping, la red está funcionando.

## 🧠 Notas útiles

- Si usas red móvil, el modo puente puede fallar. Asegúrate de que el adaptador de red de Kali esté correctamente enlazado a tu interfaz física.
- Puedes automatizar la configuración de IPs creando un script de inicio en Kali y Metasploitable2.
- Si reinicias las máquinas, puede que tengas que volver a asignar las IPs manualmente (a menos que configures IPs estáticas en el sistema).

## ✅ Soluciones para mantener IPs estáticas.

### 🛠️ En Kali Linux (Debian-based)

Editamos el archivo de configuración de red:

```bash
sudo nano /etc/network/interfaces
```

Agregamos la siguiente configuración para eth1:

```ini
auto eth1
iface eth1 inet static
    address 192.168.56.10
    netmask 255.255.255.0
```

Guardamos y reiniciamos el servicio de red:

```bash
sudo systemctl restart networking
```

O simplemente reinicia manualmente.

### 🛠️ En Metasploitable2 (Ubuntu 8.04-based)

Edita el archvo:

```bash
sudo nano /etc/network/interfaces
```

Agrega:

```ini
auto eth0
iface eth0 inet static
    address 192.168.56.102
    netmask 255.255.255.0
```

Guardamos y reiniciamos el servicio:

```bash
sudo /etc/init.d/networking restart
```

## 🧪 Verificación

Después de reiniciar ambas máquinas, ejecutamos:

```bash
ip a        # en Kali
ifconfig    # en Metasploitable2
```

Y probamos la conectividad:

```bash
ping 192.168.56.102
```



