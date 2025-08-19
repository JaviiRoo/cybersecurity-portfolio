# ✅ Instalación de DVWA con Docker

## 1️⃣ Crear estructura de evidencias

```bash
mkdir -p ~/Pentesting/DVWA/{notes,loot,scans,requests,screens}
```

## 2️⃣ Función para loggear comandos

```bash
cat <<'EOF' > ~/Pentesting/DVWA/log.sh
#!/usr/bin/env bash
set -o pipefail
ts=$(date +"%F_%H-%M-%S")
out="~/Pentesting/DVWA/notes/cmd_${ts}.txt"
echo -e "\n[$(date)] $*\n" | tee -a ~/Pentesting/DVWA/notes/history.log
"$@" 2>&1 | tee "$HOME/Pentesting/DVWA/notes/${ts}.out"
EOF
chmod +x ~/Pentesting/DVWA/log.sh
```

## 3️⃣ Lanzar DVWA

```bash
docker pull vulnerables/web-dvwa
docker run -d --name dvwa -p 8080:80 vulnerables/web-dvwa
docker start dvwa
```

## 4️⃣ Acceder desde navegador

- URL: http://127.0.0.1:8080
- Usuario: admin
- Contraseña: password
- Setup → Create/Reset Database
- DVWA Security → Low
- PHPIDS → Disabled

