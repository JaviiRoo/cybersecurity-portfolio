# 📚 Introducción

Burp Suite es una plataforma integrada para realizar pruebas de seguridad en aplicaciones web. Desarrollada por PortSwigger, ofrece herramientas manuales y automáticas para interceptar, modificar, analizar y automatizar tráfico HTTP/S. Es ampliamente utilizada por pentesters, bug bounty hunters y equipos de seguridad ofensiva.

# 🧰 Ediciones disponibles

| Edición              | Características principales                                         |
|----------------------|---------------------------------------------------------------------|
| **Community Edition** | Gratuita, ideal para aprendizaje y pruebas manuales                |
| **Professional**      | Licencia de pago, incluye escaneo automático y funciones avanzadas |
| **Enterprise**        | Pensada para equipos grandes, automatización CI/CD                 |


✅ Para pentesting manual, la edición Community es suficiente. Para escaneo automatizado, se recomienda la Professional.

# ⚙️ Instalación

```bash
# En Linux (usando archivo .jar)
java -jar burpsuite_community_vX.X.X.jar

# En Windows/macOS
Descargar desde: https://portswigger.net/burp/releases
```
# 🧭 Componentes principales

| Herramienta | Función clave |
|-------------|----------------|
| **Proxy** | Intercepta y modifica tráfico entre navegador y servidor |
| **Target** | Mapea y organiza la estructura de la aplicación web |
| **Intruder** | Ataques automatizados (fuerza bruta, fuzzing, etc.) |
| **Repeater** | Reenvía y modifica peticiones manualmente |
| **Scanner** | Detecta vulnerabilidades automáticamente (solo en Pro) |
| **Decoder** | Codifica/decodifica datos (Base64, URL, Hex, etc.) |
| **Comparer** | Compara respuestas para detectar diferencias |
| **Extender** | Añade funcionalidades mediante plugins y BApp Store |

# 🌐 Configuración del Proxy

1. Abre Burp Suite y activa el proxy en 127.0.0.1:8080
2. Configura tu navegador para usar ese proxy.
3. Instala el certificado de Burp para interceptar HTTPS:
   - Visita http://burpsuite desde el navegador.
   - Descarga e instala el certificado CA.

✅ Esto permite interceptar tráfico cifrado sin alertas de seguridad.

# 🧪 Uso práctico: Interceptar y modificar peticiones

1. Activa "Intercept is on" en la pestaña Proxy.
2. Navega a una URL desde el navegador.
3. Burp mostrará la petición interceptada.
4. Modifica parámetros, cabeceras o cookies.
5. Envía la petición modificada al servidor.

# 🚀 Ataques con Intruder

1. Envía una petición desde Proxy a Intruder.
2. Define los puntos de inyección (posición de payloads).
3. Selecciona el tipo de ataque:
   - Sniper
   - Battering ram
   - Pitchfork
   - Cluster bomb
4. Carga diccionarios o payloads personalizados.
5. Ejecuta el ataque y analiza las respuestas.

✅ Ideal para fuerza bruta de login, fuzzing de parámetros, detección de inyecciones.

# 🧠 Buenas prácticas

✅ Usa Repeater para validar manualmente vulnerabilidades antes de reportarlas  
✅ Organiza tus objetivos en la pestaña Target para no perder contexto  
✅ Guarda el estado del proyecto para continuar más tarde (`.burp` file)  
✅ Usa extensiones como "Logger++", "Active Scan++" o "Autorize" para ampliar capacidades  
✅ No escanees sin autorización: Burp puede generar tráfico agresivo

# 📦 Extensiones recomendadas (BApp Store)

| Extensión         | Función destacada                                  |
|-------------------|----------------------------------------------------|
| **Logger++**      | Registro avanzado de peticiones/respuestas         |
| **Active Scan++** | Mejora el escaneo automático                       |
| **Autorize**      | Detecta fallos de control de acceso                |
| **Hackvertor**    | Codificación avanzada y payload crafting           |


# 📋 Exportar resultados

✅ Puedes guardar:
- Peticiones individuales (botón derecho > Save item)
- Todo el proyecto (`File > Save project`)
- Reportes en HTML (solo en edición Pro)

# 📚 Recursos adicionales

- [Documentación oficial de Burp Suite](https://portswigger.net/burp/documentation).
- [Guía completa en PDF](https://github.com/DosX-dev/pdf/blob/main/A%20Complete%20Guide%20to%20Burp%20Suite.pdf).
- [Tutorial para principiantes](https://es.slideshare.net/slideshow/a-complete-guide-to-burp-suite-for-beginners-pdf/273207789).
- - [Tutorial para principiantes](https://es.slideshare.net/slideshow/a-complete-guide-to-burp-suite-for-beginners-pdf/273207789).

- 
