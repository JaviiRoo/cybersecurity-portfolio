# 🐳 DOCKER — Herramienta para entornos de pentesting

## 📌 ¿Qué es Docker?

**Docker** es una plataforma que permite crear, desplegar y ejecutar aplicaciones en contenedores. Estos contenedores son entornos ligeros, portables y aislados que incluyen todo lo necesario para ejecutar una aplicación: código, dependencias, librerías, etc.

### 🚀 Ventajas para pentesters

- ⚡**Rápido:** despliegue en segundos.
- 🧼 **Limpio:** sin contaminar tu sistema.
- 🔁 **Reproducible:** mismo entorno en cualquier máquina.
- 🧪 **Ideal para laboratorios:** como DVWA, Juice Shop, Metasploitable...

### 🛠️ Instalación de Docker en Kali Linux

#### ✅ Opción 1: Instalación rápida

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
newgrp docker
```

#### 🧩 Opción 2: Instalación oficial (si hay errores)

```bash
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### 📦 Comandos básicos de Docker para pentesting

#### 🔍 Ver contenedores

```Bash
docker ps            # Contenedores activos
docker ps -a         # Todos los contenedores (activos y detenidos)
```

#### ▶️ Iniciar, detener y eliminar contenedores

```Bash
docker start <nombre>      # Inicia un contenedor detenido
docker stop <nombre>       # Detiene un contenedor activo
docker rm <nombre>         # Elimina un contenedor detenido
```

#### 🧱 Crear y ejecutar un contenedor

```Bash
docker run -d --name dvwa -p 8080:80 vulnerables/web-dvwa
```

- -d: modo "detached" (en segundo plano).
- --name: nombre personalizado del contenedor.
- -p: mapea el puerto del host al contenedor.

#### 🔄 Reiniciar un contenedor

```Bash
docker restart <nombre>
```

### 🧪 Ejemplo práctico: DVWA

#### 1. Descargar la imagen

```Bash
docker pull vulnerables/web-dvwa
```

#### 2. Ejecutar el contenedor

```Bash
docker run -d --name dvwa -p 8080:80 vulnerables/web-dvwa
```

#### 3. Acceder desde el navegador

```Code
http://127.0.0.1:8080
```

#### 4. Verificar con curl

```Bash
curl -I http://127.0.0.1:8080
```

### 🧰 Otros comandos útiles

```Bash
docker images              # Ver imágenes descargadas
docker rmi <imagen>        # Eliminar una imagen
docker exec -it <nombre> bash   # Acceder al contenedor con bash
docker logs <nombre>       # Ver logs del contenedor
```

