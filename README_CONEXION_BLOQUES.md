# README de Conexión: Bloques y Rutas para Vinculación

Este documento mapea, de forma precisa, los bloques (pantallas/secciones) que muestran información en la app y las rutas (endpoints) que consumen, para facilitar su correcta vinculación tanto con ESP32 como con la API de Google Sheets (Apps Script Web App `/exec`).

## Objetivo
- Identificar qué bloque consulta qué ruta.
- Especificar contratos de datos (claves, formatos y unidades) esperados por cada bloque.
- Indicar cómo configurar y priorizar el origen de datos (ESP32 vs Sheets).

## Resumen de comportamiento actual
- Origen Sheets (Web App): si existe `api_base_url` en `SharedPreferences` o se define `DEFAULT_API_BASE_URL` en código, la app prioriza Sheets.
- Sensor Detail: usa la serie histórica desde Sheets automáticamente (`endpoint=history`).
- Main Menu: usa `endpoint=lastReading` de Sheets si está configurado; si no, consulta `http://<esp32Ip>/sensors`.
- Origen ESP32: si no hay `api_base_url` ni `DEFAULT_API_BASE_URL`, se consulta al ESP32 directamente.

## Bloques y Rutas

### 1) Main Menu (Resumen de Sensores)
- Archivo: `lib/screens/main_menu_screen.dart`
- Rutas consumidas (modo dual):
  - Sheets (si `api_base_url`/default existe): `GET <api_base_url>?endpoint=lastReading`
    - Contrato esperado (JSON): `{ "temperatura": number, "humedad": number, "ph": number, "tds": number }`
  - ESP32 (fallback): `GET http://<esp32Ip>/sensors`
    - Contrato esperado (JSON): `{ "temperatura": number, "humedad": number, "ph": number, "tds": number }`
- Uso: Presenta el estado agregado de los sensores para navegación rápida.
- Notas:
  - Timeout: 3s.
  - Fuente: Prioriza Sheets si está configurado.

### 2) Sensor Detail (Gráfico y valor actual)
- Archivo: `lib/screens/sensor_detail_page.dart`
- Rutas consumidas (modo dual):
  - Modo Sheets (prioritario si `api_base_url`/`DEFAULT_API_BASE_URL` existe):
    - `GET <api_base_url>?endpoint=history&type=<tipo>&limit=15`
    - Respuesta esperada: `{ "type": "<tipo>", "unit": "<unidad>", "points": [{ "timestamp": "ISO-8601", "value": number }, ...] }`
    - Uso: Toma `points[].value` para graficar y calcular el valor actual (último punto).
  - Modo ESP32 (fallback si Sheets no está configurado):
    - `GET http://<esp32Ip>/<tipo>`
    - Respuesta esperada: `{ "temperatura": number }` o `{ "humedad": number }` o `{ "ph": number }` o `{ "tds": number }` según `tipo`.
- Tipos soportados: `temperatura`, `humedad`, `ph`, `tds`.
- Frecuencia de actualización: cada 5 segundos.

### 3) Sensor Dashboard (Navegación a detalle)
- Archivo: `lib/screens/sensor_dashboard_screen.dart`
- Ruta consumida: no consume directamente; crea navegación hacia `SensorDetailPage` pasando `esp32Ip`, `tipo`, `titulo`.
- Contrato: N/A (solo routing interno).

### 4) Device Config (Configuración de IP)
- Archivo: `lib/screens/device_config_screen.dart`
- Claves de configuración:
  - `esp32_ip`: IP/host del ESP32.
  - (Opcional futuro) `api_base_url`: URL de la Web App de Sheets `/exec`.
- Rutas consumidas: N/A (persiste configuración local).

### 5) Device Connection (Estado de Conexión)
- Archivo: `lib/screens/device_connection_screen.dart`
- Rutas consumidas: N/A (muestra información simulada/estática en la versión actual). Puede evolucionar a ping/health.

### 6) Notifications
- Archivo: `lib/screens/notifications_screen.dart`
- Rutas consumidas: N/A en la versión actual.

## Configuración del origen de datos

- `SharedPreferences`:
  - `esp32_ip`: requerido para el modo ESP32.
  - `api_base_url`: recomendado para modo Sheets; tiene prioridad sobre el default.
- `DEFAULT_API_BASE_URL` (código):
  - Archivo: `lib/constants/app_config.dart`
  - Campo: `static const String DEFAULT_API_BASE_URL = '<TU_EXEC_URL>';`
  - Si `api_base_url` no existe o está vacío, `SensorDetail` usa este valor por defecto.

## Contratos de datos y unidades

- ESP32 `/sensors`:
  - Claves: `temperatura` (°C), `humedad` (%), `ph` (pH), `tds` (ppm).
- ESP32 `/<tipo>`:
  - Clave única según `tipo`.
- Sheets `?endpoint=history&type=<tipo>&limit=N`:
  - Claves: `points[].timestamp` (UTC ISO-8601), `points[].value` (number), `unit` (string), `type` (string).
  - Ejemplo: `{ "type": "temperatura", "unit": "C", "points": [{ "timestamp": "2025-11-10T13:45:00Z", "value": 24.1 }] }`.

## Ejemplos de endpoints

- Sheets base (comprobación):
  - `GET <api_base_url>` → `{ "ok": true, "endpoints": ["lastReading","history","export"] }`
- Sheets historia de temperatura:
  - `GET <api_base_url>?endpoint=history&type=temperatura&limit=15`
- ESP32 sensores agregados:
  - `GET http://<esp32Ip>/sensors`
- ESP32 lectura individual:
  - `GET http://<esp32Ip>/temperatura` (idem para `humedad`, `ph`, `tds`).

## Cómo vincular correctamente

1) Definir origen:
- Solo ESP32: guarda `esp32_ip` y deja vacío `api_base_url` y `DEFAULT_API_BASE_URL`.
- Sheets prioritario: define `api_base_url` en preferencias o `DEFAULT_API_BASE_URL` en código.

2) Verificar respuesta de la API elegida:
- Sheets: revisa que devuelva `points[].value` en `history`.
- ESP32: revisa que `/<tipo>` entregue la clave correcta.

3) Probar en la app:
- Main Menu debe cargar valores desde Sheets (`lastReading`) si está configurado; en caso contrario, desde `http://<esp32Ip>/sensors`.
- Sensor Detail debe graficar valores desde Sheets si está configurado, si no, desde ESP32.

## Extensiones opcionales

- Hacer que Main Menu consuma Sheets también:
  - Implementar `GET <api_base_url>?endpoint=lastReading` o crear `GET <api_base_url>/sensors` con el contrato `{ temperatura, humedad, ph, tds }`.
- Añadir un campo en `DeviceConfigScreen` para ingresar/editar `api_base_url` desde la UI.
- Health check/ping en `DeviceConnectionScreen` para mostrar estado real de conectividad.

## Errores comunes y soluciones

- 404/400 en Sheets: confirma que el endpoint sea `history` y los parámetros `type` y `limit` estén presentes.
- Tiempo de espera: las llamadas en detalle tienen timeout de ~3s; verifica latencia de Apps Script.
- Claves incorrectas: el gráfico espera `points[].value` en Sheets; en ESP32, la clave debe coincidir con `tipo`.

---

Para cualquier ajuste de rutas, contratos o soporte de nuevos bloques, indícanos qué endpoint quieres exponer y actualizamos la vinculación y el parser correspondiente.