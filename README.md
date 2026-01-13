# 📱 EcoGrid Mobile App

Aplicación móvil desarrollada en Flutter para la visualización y gestión de datos de sensores ambientales. Permite la generación de reportes en formatos PDF y CSV, facilitando la exportación de información histórica para análisis offline.

---

## 🚀 Funcionalidades principales

- **Dashboard de Sensores:** Visualización en tiempo real de métricas (Temperatura, Humedad, pH, TDS, UV).
- **Reportes Personalizados:** Selección de rango de fechas para consultas históricas.
- **Exportación PDF:** Generación de informes formateados listos para compartir.
- **Exportación CSV:** Descarga de datos crudos para análisis en hojas de cálculo.
- **Interfaz Moderna:** Diseño responsivo y optimizado para dispositivos móviles Android.
- **Gestión de Conexión:** Configuración de IP para dispositivos IoT (ESP32).

---

## 🛠️ Tecnologías utilizadas

### Frontend / Mobile
- **Flutter** (Framework UI)
- **Dart** (Lenguaje de programación)
- **Go Router** (Navegación y rutas)

### Visualización y Estilos
- **fl_chart** (Gráficos interactivos)
- **google_fonts** (Tipografía)
- **flutter_svg** (Iconos vectoriales)

### Generación de Archivos
- **pdf** & **printing** (Creación y renderizado de documentos PDF)
- **csv** (Conversión de datos a formato CSV)

### Gestión de Archivos y Sistema
- **path_provider** (Acceso al sistema de archivos)
- **open_file** (Apertura de archivos nativos)
- **share_plus** (Compartir archivos con otras apps)
- **http** & **dio** (Comunicación con API REST)

### Plataforma
- **Android** (Target principal)
- **Gradle** (Sistema de construcción)

---

## 📂 Estructura del proyecto

```
lib/
├── components/    # Widgets reutilizables (Calendarios, estado de conexión)
├── constants/     # Configuraciones globales, colores, iconos y textos
├── models/        # Modelos de datos (ImageData, SensorData)
├── screens/       # Pantallas principales (Dashboard, Menú, Reportes, Galería)
├── services/      # Lógica de negocio y comunicación (ConnectionManager)
├── styles/        # Temas y estilos globales
├── utils/         # Utilidades (FileSaver, PdfSaver, PlatformDetector)
└── widgets/       # Widgets específicos de UI (Navegación)
test/              # Pruebas unitarias y de widgets
android/           # Configuración nativa Android
```

---

## ⚙️ Requisitos del entorno

- **Flutter SDK:** >=3.35.7
- **Dart SDK:** >=3.9.2
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Android SDK** (API 34+ recomendado)
- **Java JDK** (versión compatible con Gradle)

---

## ▶️ Ejecución del proyecto

### Modo Desarrollo
Instrucciones para correr la app en un emulador o dispositivo conectado:

```bash
flutter pub get
flutter run
```

### 📦 Build Android (APK Release)
Comandos para generar el APK firmado para distribución:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

**Ruta del APK generado:**
`build/app/outputs/flutter-apk/app-release.apk`

---

## ✅ Verificación básica (QA)

Antes de distribuir, verifica los siguientes puntos:
1.  **Inicio:** La aplicación abre correctamente sin crashes.
2.  **UI:** No existen errores de overflow (bordes amarillos/rojos) en las pantallas.
3.  **Fechas:** El selector de rango de fechas funciona y filtra los datos.
4.  **PDF:** La generación y apertura del archivo PDF es exitosa.
5.  **CSV:** La exportación a CSV genera un archivo válido y compartible.

---

## 🔒 Notas importantes

- **Backend:** El backend y los endpoints de la API no se modifican desde este repositorio.
- **Seguridad:** Las claves de firma (`keystore`) y archivos `key.properties` **no se incluyen** en el repositorio por seguridad.
- **Conectividad:** La app requiere conexión a la red local del dispositivo IoT para obtener datos en tiempo real.

---

## 📄 Licencia

Este proyecto es de uso privado/académico. Todos los derechos reservados.
