#!/bin/bash

# 📂 Carpeta donde guardaremos los HTML
OUTPUT_DIR="$HOME/Pentesting/DVWA/sessions"
mkdir -p "$OUTPUT_DIR"

# 🌐 URL base de DVWA
BASE_URL="http://127.0.0.1:8080"

# 🔑 Lista de usuarios y contraseñas obtenidos
declare -A USERS
USERS[admin]="password"
USERS[gordonb]="abc123"
USERS[1337]="charley"
USERS[pablo]="letmein"
USERS[smithy]="password"

# 🍪 Función para obtener cookie PHPSESSID después de login
get_cookie() {
    USER=$1
    PASS=$2
    COOKIE=$(curl -s -i "$BASE_URL/login.php" \
        -d "username=$USER&password=$PASS&Login=Login" \
        | grep -i "Set-Cookie" | grep -o "PHPSESSID=[^;]*" | head -n 1)
    echo "$COOKIE"
}

# 📄 Guardar HTML para cada usuario
first=true
for USER in "${!USERS[@]}"; do
    PASS="${USERS[$USER]}"
    COOKIE=$(get_cookie "$USER" "$PASS")

    if [ -z "$COOKIE" ]; then
        echo "[❌] No se pudo obtener cookie para $USER:$PASS"
        continue
    fi

    echo "[✅] Cookie para $USER: $COOKIE"

    FILE="$OUTPUT_DIR/index_${USER}.html"
    curl -s "$BASE_URL/index.php" -H "Cookie: $COOKIE; security=low" > "$FILE"

    # Guardar el primero como base para comparación
    if $first; then
        BASE_FILE="$FILE"
        first=false
    else
        DIFF=$(diff -q "$BASE_FILE" "$FILE")
        if [ -z "$DIFF" ]; then
            echo "[=] $USER es igual al admin."
        else
            echo "[⚠] $USER tiene diferencias con admin."
        fi
    fi
done

echo "📂 HTML guardados en: $OUTPUT_DIR"
