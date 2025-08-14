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
