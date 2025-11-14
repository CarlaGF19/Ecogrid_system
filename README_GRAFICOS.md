# Conexión de Gráficos (EcoGrid)

Este README describe cómo la app sincroniza los gráficos de sensores con el backend (ESP32 o API basada en Google Sheets), qué variables se requieren y el contrato de datos esperado.

## Objetivo
- Mostrar valores en tiempo real y series históricas para sensores: `temperatura`, `humedad`, `ph`, `tds`.
- Mantener un contrato simple y estable: backend entrega en UTC y la app presenta en UTC-5 (Perú) si se requiere.

## Arquitectura de Datos
- Pantalla `SensorDashboardScreen` (dashboard): consulta un endpoint agregado con los últimos valores.
- Pantalla `SensorDetailPage` (detalle): consulta valores del sensor específico y renderiza una serie con `fl_chart`.

## Endpoints y Contrato de API

### Opción A: ESP32 (contrato simple por clave)
- Dashboard agregado:
  - `GET http://<esp32Ip>/sensors`
  - Respuesta JSON:
    - `{ "timestamp": "2025-11-02T22:19:24.051Z", "temperatura": 26.2, "humedad": 66.6, "ph": 5.74, "tds": 1301 }`
- Detalle por sensor:
  - `GET http://<esp32Ip>/<tipo>` donde `<tipo> ∈ {temperatura, humedad, ph, tds}`
  - Respuesta JSON:
    - `{"temperatura": 26.2}` o `{"humedad": 66.6}` o `{"ph": 5.74}` o `{"tds": 1301}` según el tipo.

### Opción B: API Google Sheets (serie de puntos)
- Dashboard agregado:
  - `GET <baseUrl>/sensors`
  - Respuesta JSON:
    - `{ "timestamp": "2025-11-02T22:19:24.051Z", "temperatura": 26.2, "humedad": 66.6, "ph": 5.74, "tds": 1301 }`
- Detalle por sensor (series):
  - `GET <baseUrl>/sensor?type=<tipo>&limit=<N>`
  - Respuesta JSON:
    - `{ "type": "temperatura", "unit": "C", "points": [ {"timestamp": "2025-11-02T22:19:24.051Z", "value": 26.1}, {"timestamp": "2025-11-02T22:19:29.051Z", "value": 26.2} ] }`
  - Reglas:
    - `limit`: número de puntos (recomendado 15–50).
    - `points`: ordenados por `timestamp` ascendente.

## Variables y Sincronización (lado app)
- `tipo`: cadena con el sensor (`temperatura`, `humedad`, `ph`, `tds`).
- `valorActual`: número doble que se muestra destacado en detalle.
- `valores`: lista de números (`List<double>`) que se grafican como serie; se limita a 15 valores en memoria.
- `esp32Ip`: dirección base del dispositivo (guardada en `SharedPreferences` clave `esp32_ip`).
- `baseUrl` (opcional para Sheets): URL del Web App o API intermedia (sugerido guardar como `api_base_url`).
- Intervalo de muestreo (detalle): 5 segundos (polling con `Timer.periodic`).
- Timeout (dashboard): 3 segundos para respuestas rápidas.

## Requisitos del Backend
- Entregar `Content-Type: application/json` válido.
- Claves esperadas para dashboard: `temperatura`, `humedad`, `ph`, `tds`, más `timestamp` en ISO 8601 UTC.
- Claves esperadas para detalle simple: una clave por tipo (p. ej. `{"ph": 5.74}`).
- Claves esperadas para detalle serie: `{type, unit, points[]}` con cada punto `{timestamp, value}`.
- Unidades: `temperatura (°C)`, `humedad (%)`, `ph (0–14)`, `tds (ppm)`.
- Números normalizados (punto decimal, sin separadores de miles).
- Si el backend devuelve filas crudas (texto), transformarlas a JSON antes de enviar a la app.

## Ejemplos de Respuestas
- Último dato agregado:
  - `{ "timestamp": "2025-11-02T22:19:24.051Z", "temperatura": 26.2, "humedad": 66.6, "ph": 5.74, "tds": 1301 }`
- Detalle simple (ESP32):
  - `{"temperatura": 26.2}`
- Detalle serie (Sheets):
  - `{ "type": "tds", "unit": "ppm", "points": [ {"timestamp": "...", "value": 1280}, {"timestamp": "...", "value": 1301} ] }`

## Integración en Flutter
- Archivo: `lib/screens/sensor_detail_page.dart`
  - Construcción de URL (modo ESP32): `"${widget.esp32Ip}/${widget.tipo}"`
  - Mapeo de claves:
    - `switch (widget.tipo) { case "temperatura": valor = (data["temperatura"] ?? 0).toDouble(); ... }`
  - Serie: agregar a `valores` y limitar a 15 elementos.
- Archivo: `lib/screens/main_menu_screen.dart` (dashboard)
  - Consulta agregada: `GET 'http://$_esp32Ip/sensors'` con timeout 3s.
  - Parseo: `json.decode(response.body)` y lectura de claves.

## Manejo de Tiempo (UTC → UTC-5)
- Guardar y entregar `timestamp` en UTC (`...Z`).
- Convertir en la app para presentar en UTC-5 (Perú):
  - Simple: `DateTime.parse(ts).toUtc().subtract(const Duration(hours: 5))`.
  - Robusto: librería `timezone` y `America/Lima`.
- Mostrar claramente “Hora local (UTC-5)” cuando corresponda.

## Errores y Fallback
- Códigos ≠ 200: no actualizar valores y mostrar “Sin datos aún...”.
- Campos ausentes o nulos: usar `0` por defecto para evitar fallos.
- Manejar excepciones de red con `try/catch` y logs (`debugPrint`).

## Checklist de Despliegue Backend
- [ ] Endpoints responden con JSON válido y claves esperadas.
- [ ] `timestamp` en ISO 8601 UTC.
- [ ] Series limitadas y ordenadas ascendentemente.
- [ ] Unidades documentadas y consistentes.
- [ ] (Opcional) Autenticación por API key si el Web App es público.

## Notas
- Si migras de ESP32 a Sheets, mantén el contrato de claves para evitar cambios en la UI.
- Para mejor rendimiento, cachear `/sensors` por unos segundos del lado backend.