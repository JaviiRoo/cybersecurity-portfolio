# 📚 Instalación y Ejecución de OWASP Juice Shop en Kali Linux

## 🔎 ¿Qué es OWASP Juice Shop?

OWASP Juice Shop es una aplicación web intencionalmente vulnerable diseñada para practicar **pentesting** y aprender sobre la seguridad web.
Contiene vulnerabilidades de los niveles **OWASP TOP 10** y más.

## 🖥️ Requisitos previos

- Una máquina virtual con **Kali Linux**.
- Acceso a Internet.
- Permisos de usuario con `sudo`.
- (Opcional) **Docker** instalado si deseamos usar el método con contenedores.

## 🚀 Métodos de instalación

### 1️⃣ Instalación mediante Node.js (recomendado para practicar)

1. **Actualizamos el sistema**

```bash
sudo apt update && sudo apt upgrade -y
```

2. **Instalamos Node.js y npm**

```bash
sudo apt install -y nodejs npm
```

3. **Clonamos el repositorio de Juice Shop**

```bash
git clone https://github.com/juice-shop/juice-shop.git
```

4. **Entramos en el directorio y descargamos dependencias**

```bash
cd juice-shop
npm install
```

5. **Iniciamos la aplicación**


```bash
npm start
```

6. **Acedemos a Juice Shop**
   - Abrimos navegador y entramos en: 👉 http://localhost:3000
  
### 2️⃣ Instalación mediante Docker (opcional, más rápido)

1. **Instalar Docker**

```bash
sudo apt install -y docker.io
```

2. **Ejecutamos Juice Shop en un contenedor**

```bash
sudo docker run --rm -p 3000:3000 bkimminich/juice-shop
```

3. **Accedemos a Juice Shop**
    - Abrimos navegador y entramos en: 👉 http://localhost:3000
  
## 🛠️ Tips de uso

- Si quieres que la app siga corriendo en segundo plano:

  ```bash
  npm start &
  ````

  o bien con Docker:

  ```bash
  sudo docker run -d -p 3000:3000 bkimminich/juice-shop
  ```

- Para detener el servidor en Node.js: Presionamos `CTRL + C`.
- Para detener el contenedor en Docker:

  ```Bash
  sudo docker ps # Vemos el ID del contenedor a detener.
  sudo docker stop <ID>
  ```

## ✅ Verificación final
  
- Si al entrar a http://localhost:3000 aparece la tienda con productos falsos → ¡Juice Shop está listo para pentesting!

## 📂 Recursos útiles

- [Repositorio oficial en Github](https://github.com/juice-shop/juice-shop?utm_source=chatgpt.com).
- [Documentación oficial](https://owasp.org/www-project-juice-shop/?utm_source=chatgpt.com)
