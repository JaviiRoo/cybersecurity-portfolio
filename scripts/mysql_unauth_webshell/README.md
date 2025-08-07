# MySQL Webshell Writer (Metasploitable2)

Este módulo contiene dos scripts que explotan una configuración insegura del servicio MySQL en Metasploitable2. El objetivo es escribir una webshell PHP en el directorio público de Apache usando la función `SELECT ... INTO OUTFILE`.

## Archivos

- `mysql_webshell_writer.py`: Script en Python que se conecta como root sin contraseña y escribe la webshell.
- `mysql_webshell_writer.sh`: Script en Bash que realiza la misma operación usando el cliente `mysql`.

## Requisitos

- MySQL debe estar corriendo en el objetivo (`192.168.56.102`)
- El usuario `root` debe tener acceso sin contraseña
- MySQL debe tener permisos para escribir en `/var/www/html/`

## Uso

### Python

```bash
python3 mysql_webshell_writer.py
