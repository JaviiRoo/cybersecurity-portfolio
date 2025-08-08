# UnrealIRCd 3.2.8.1 Backdoor Exploit (PoC)

## 📌 Descripción

Este script explota una backdoor presente en UnrealIRCd 3.2.8.1 que permite ejecutar comandos arbitrarios en el sistema remoto. La vulnerabilidad se activa enviando el prefijo `AB;` seguido del comando deseado a través del protocolo IRC.

## 🛠 Requisitos

- Bash o Python 3
- Netcat (`nc`) para la versión Bash
- Acceso a la red donde se encuentra el servidor vulnerable

## 🚀 Uso en bash:

```bash
chmod +x unreal_exploit.sh
./unreal_exploit.sh
```

## Uso Python:

```bash
python3 unreal_exploit.py
```

## ⚠️ Advertencia

Este script es solo para fines educativos y de auditoría autorizada. No lo uses contra sistemas sin permiso explícito.

## 📚 Referencias

- [Exploit Database - UnreallRCd Backdoor](https://www.exploit-db.com/exploits/13853).
- [Metasploit Module: unix/irc/unreal_ircd_3281_backdoor](https://github.com/rapid7/metasploit-framework).

- 
