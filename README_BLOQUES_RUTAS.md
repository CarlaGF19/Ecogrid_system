# Bloques y Rutas de Datos (EcoGrid)

Este documento lista los bloques (pantallas/secciones) que muestran información en la app y las rutas (endpoints) que consumen para vincularlos correctamente.

## Resumen de Bloques y Rutas

- Bloque: Main Menu (Panel resumen)
  - Archivo: `lib/screens/main_menu_screen.dart`
  - Ruta: `GET http://<esp32Ip>/sensors`
  - Uso: Carga valores agregados del dispositivo para mostrar un resumen.
  - Claves esperadas (JSON): `timestamp`, `temperatura`, `humedad`, `ph`, `tds`.
  - Detalles técnicos:
    - IP guardada en `SharedPreferences` bajo clave `esp32_ip`.
    - Timeout de 3s para respuesta rápida.

- Bloque: Sensor Dashboard (Tarjetas de sensores)
  - Archivo: `lib/screens/sensor_dashboard_screen.dart`
  - Ruta: No consulta datos directamente.
  - Uso: Navega al detalle de cada sensor y pasa parámetros.
  - Parámetros al detalle: `esp32Ip`, `tipo`, `titulo`.
  - Acción:
    - Al tocar una tarjeta, llama a `SensorDetailPage(esp32Ip, tipo, titulo)`.

- Bloque: Sensor Detail (Gráfico y valor actual)
  - Archivo: `lib/screens/sensor_detail_page.dart`
  - Ruta: `GET ${esp32Ip}/${tipo}` (ESP32)
  - Uso: Lee el sensor específico, muestra el valor actual y grafica los últimos 15 valores.
  - Polling: cada 5 segundos.
  - Claves esperadas (JSON): según `tipo`.
    - `temperatura` → `{ "temperatura": <double> }`
    - `humedad` → `{ "humedad": <double> }`
    - `ph` → `{ "ph": <double> }`
    - `tds` → `{ "tds": <double> }`

- Bloque: Device Config (Configurar IP)
  - Archivo: `lib/screens/device_config_screen.dart`
  - Ruta: No consulta datos directamente.
  - Uso: Guarda `esp32_ip` en `SharedPreferences` para que Main Menu y Sensor Detail construyan sus URLs.

- Bloque: Device Connection (Estado y lista)
  - Archivo: `lib/screens/device_connection_screen.dart`
  - Ruta: Actualmente sin consultas (datos de ejemplo).
  - Uso: Presenta estado de conexión de forma estática; puede vincularse luego a un endpoint de estado si se requiere.

- Bloque: Notifications (Notificaciones)
  - Archivo: `lib/screens/notifications_screen.dart`
  - Ruta: No consulta datos.
  - Uso: Lista mock de notificaciones; pendiente de integrar con backend si se desea.

## Alternativa API (Google Sheets)

Si usas una API basada en Google Sheets/Apps Script, mantén las mismas claves y agrega series:

- Agregado (Main Menu): `GET <api_base_url>/sensors`
  - Respuesta: igual al ESP32.
- Series (Sensor Detail): `GET <api_base_url>/sensor?type=<tipo>&limit=<N>`
  - Respuesta:
    ```json
    { "type": "temperatura", "unit": "C", "points": [ {"timestamp": "2025-11-02T22:19:24.051Z", "value": 26.1} ] }
    ```
  - Orden: `points` por `timestamp` ascendente; `limit` sugerido 15–50.

## Cómo Vincular Bloques con Rutas

1. Configura la IP/URL:
   - En `DeviceConfigScreen`, guarda `esp32_ip` (ESP32) o guarda `api_base_url` (Sheets).
2. Main Menu:
   - Verifica que `esp32_ip` esté definido; la app construye `http://<esp32Ip>/sensors`.
3. Sensor Dashboard:
   - Pasa `esp32Ip`, `tipo`, `titulo` al detalle.
4. Sensor Detail:
   - Construye `"${esp32Ip}/${tipo}"` (ESP32) o `"<api_base_url>/sensor?type=<tipo>&limit=N"` (Sheets).
   - Mapea claves según `tipo` y agrega a la serie (`valores`) con límite de 15.

## Contrato de Datos (claves y unidades)

- `temperatura`: `°C` (double)
- `humedad`: `%` (double)
- `ph`: `0–14` (double)
- `tds`: `ppm` (int/double)
- `timestamp`: ISO 8601 UTC (`...Z`)

## Ejemplos Rutas y Respuestas

- Agregado (ESP32): `GET http://192.168.1.50/sensors`
  ```json
  { "timestamp": "2025-11-02T22:19:24.051Z", "temperatura": 26.2, "humedad": 66.6, "ph": 5.74, "tds": 1301 }
  ```
- Detalle (Temperatura): `GET http://192.168.1.50/temperatura`
  ```json
  { "temperatura": 26.2 }
  ```
- Series (Sheets, TDS): `GET https://script.google.com/.../exec/sensor?type=tds&limit=20`
  ```json
  { "type": "tds", "unit": "ppm", "points": [ {"timestamp": "2025-11-02T22:19:24.051Z", "value": 1280}, {"timestamp": "2025-11-02T22:24:24.051Z", "value": 1301} ] }
  ```

## Notas de Integración

- Si cambias de ESP32 a Sheets, conserva las claves (`temperatura`, `humedad`, `ph`, `tds`) para compatibilidad de UI.
- Maneja errores y nulos con valores por defecto (`0`) y muestra “Sin datos aún...”.
- Para tiempo local (UTC-5), convierte en la app antes de mostrar.