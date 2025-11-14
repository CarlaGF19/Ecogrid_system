# 📱 ESTRUCTURA DEL BOTTOM NAVIGATION BAR - IoT Monitor App

## 🎯 **VISIÓN GENERAL**

Este documento define la estructura completa del **Bottom Navigation Bar** para la aplicación IoT Monitor, incluyendo los botones principales, sus destinos de navegación, iconografía y comportamientos.

---

## 🔧 **CONFIGURACIÓN DE BOTONES**

### **📊 Estructura de 3 Botones Principales**

| Posición | Botón | Icono | Pantalla Destino | Función Principal |
|----------|-------|-------|------------------|-------------------|
| **1** | **HOME** | `Icons.home` | `MainMenuScreen` | Dashboard principal |
| **2** | **CONEXIÓN** | `Icons.settings_input_antenna` | `DeviceConnectionScreen` | Gestión de dispositivos |
| **3** | **INFO** | `Icons.more_horiz` | `AboutScreen` | Información del proyecto |

---

## 🏠 **BOTÓN 1: HOME (Dashboard Principal)**

### **Información del Botón:**
- **Icono**: `Icons.home` 
- **Color Activo**: `Colors.green[600]`
- **Color Inactivo**: `Colors.grey[400]`
- **Label**: "Inicio"

### **Pantalla Destino: MainMenuScreen (Rediseñada)**
- **Ruta**: `/main-menu`
- **Función**: Dashboard principal con resumen del sistema

### **Contenido de la Pantalla:**
```
📊 DASHBOARD PRINCIPAL
├── 📈 Ultima Actualizacion [Hora peruana]
│   ├── 🌡️ Temperatura: 25.3°C
│   ├── 💧 Humedad: 68%
│   ├── ⚗️ pH: 7.2
│   └── 🧪 TDS: 450 ppm
└── 🚀 Accesos Rápidos
    ├── → Dashboard de Sensores
    └── → Galería de Imágenes
```


### **Navegación Desde Esta Pantalla:**
- **Dashboard de Sensores** → `/sensor-dashboard`
- **Galería de Imágenes** → `/image-gallery`
- **Configuración de Dispositivos** → `/device-config`

---

## 🔗 **BOTÓN 2: CONEXIÓN (Gestión de Dispositivos)**

### **Información del Botón:**
- **Icono**: `Icons.settings_input_antenna`
- **Color Activo**: `Colors.blue[600]`
- **Color Inactivo**: `Colors.grey[400]`
- **Label**: "Dispositivos"
- **Badge**: Muestra número de dispositivos conectados

### **Pantalla Destino: DeviceConnectionScreen (NUEVA)**
- **Ruta**: `/device-connection`
- **Función**: Centro de control de conexiones y dispositivos

### **Contenido de la Pantalla:**
```
🔗 GESTIÓN DE DISPOSITIVOS
├── 📡 Estado de Conexión Principal
│   ├── 🔴/🟢 ESP32 Status (Conectado/Desconectado)
│   ├── 📍 IP: 192.168.1.100
│   ├── 📶 WiFi: -45 dBm (Excelente)
│   ├── ⏱️ Conectado desde: 2h 15min
│   └── 🔄 Última comunicación: hace 30s
├── 📱 Lista de Dispositivos Detectados
│   ├── 🎛️ ESP32 Principal (Sensores IoT)
│   │   ├── Estado: ✅ Activo
│   │   ├── Sensores: 4 activos
│   │   └── Batería: 85%
│   ├── 📷 Cámara IoT (si disponible)
│   │   ├── Estado: ⚠️ Standby
│   │   └── Resolución: 1080p
│   └── 🔍 Buscar nuevos dispositivos
├── ⚙️ Configuración de Red
│   ├── 📶 Configurar WiFi
│   ├── 🌐 Cambiar IP estática
│   ├── 🔌 Puerto de comunicación: 80
│   └── 🔐 Configurar contraseña
├── 🔧 Herramientas de Diagnóstico
│   ├── 🏓 Test de conectividad (Ping)
│   ├── 📊 Monitor de latencia
│   ├── 📋 Log de conexiones
│   └── 🔄 Reiniciar conexión
└── 📊 Estadísticas de Conexión
    ├── ⏰ Tiempo total conectado: 8h 42min
    ├── ⚠️ Desconexiones hoy: 2
    ├── 📈 Uptime: 95.2%
    └── 📶 Calidad promedio: Buena
```

### **Navegación Desde Esta Pantalla:**
- **Configuración Avanzada** → `/device-config`
- **Test de Sensores** → `/sensor-dashboard`
- **Configuración WiFi** → Modal/Dialog interno

---

## ℹ️ **BOTÓN 3: INFO (Información y Configuración)**

### **Información del Botón:**
- **Icono**: `Icons.more_horiz`
- **Color Activo**: `Colors.orange[600]`
- **Color Inactivo**: `Colors.grey[400]`
- **Label**: "Más"

### **Pantalla Destino: AboutScreen (NUEVA)**
- **Ruta**: `/about`
- **Función**: Información del proyecto y configuraciones generales

### **Contenido de la Pantalla:**
```
ℹ️ INFORMACIÓN Y CONFIGURACIÓN
├── 📖 Acerca del Proyecto
│   ├── Descripción del Sistema IoT
│   ├── Objetivos del proyecto
│   ├── Tecnologías utilizadas
│   └── Versión de la aplicación
├── 🎓 Guía de Uso
│   ├── Tutorial interactivo
│   ├── Explicación de sensores
│   ├── Cómo interpretar datos
│   └── Solución de problemas comunes
├── ⚙️ Configuraciones de la App
│   ├── Tema (Claro/Oscuro)
│   ├── Idioma de la interfaz
│   ├── Frecuencia de actualización
│   └── Notificaciones push
├── 🔧 Información Técnica
│   ├── Especificaciones del ESP32
│   ├── Rangos de sensores
│   ├── Protocolos de comunicación
│   └── API endpoints
└── 👥 Créditos y Contacto
    ├── Desarrolladores
    ├── Instituciones involucradas
    ├── Licencias de software
    └── Información de contacto
```

### **Navegación Desde Esta Pantalla:**
- **Tutorial Interactivo** → Modal/Overlay
- **Configuración Avanzada** → `/settings` (nueva)
- **Información Técnica** → Expandible in-place

---

## 🎨 **ESPECIFICACIONES DE DISEÑO**

### **Bottom Navigation Bar Styling:**
```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.white,
  selectedItemColor: Colors.green[600],
  unselectedItemColor: Colors.grey[400],
  selectedFontSize: 12,
  unselectedFontSize: 10,
  elevation: 8,
  items: [...]
)
```

### **Comportamientos Especiales:**
- **Badge en Conexión**: Muestra número de dispositivos activos
- **Indicador de Estado**: Color del icono cambia según conectividad
- **Animaciones**: Transición suave entre tabs (300ms)
- **Persistencia**: Mantiene estado al cambiar entre tabs

---

## 🔄 **FLUJO DE NAVEGACIÓN**

### **Navegación Principal:**
```
SplashScreen (3s)
    ↓
WelcomeScreen
    ↓
BottomNavigationWrapper
    ├── [HOME] MainMenuScreen
    │   ├── → SensorDashboardScreen
    │   ├── → ImageGalleryScreen
    │   └── → DeviceConfigScreen
    ├── [CONEXIÓN] DeviceConnectionScreen
    │   ├── → DeviceConfigScreen
    │   └── → SensorDashboardScreen
    └── [INFO] AboutScreen
        └── → SettingsScreen (nueva)
```

### **Rutas GoRouter Actualizadas:**
```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/welcome', builder: (context, state) => WelcomeScreen()),
    
    // Bottom Navigation Wrapper
    ShellRoute(
      builder: (context, state, child) => BottomNavigationWrapper(child: child),
      routes: [
        GoRoute(path: '/main-menu', builder: (context, state) => MainMenuScreen()),
        GoRoute(path: '/device-connection', builder: (context, state) => DeviceConnectionScreen()),
        GoRoute(path: '/about', builder: (context, state) => AboutScreen()),
      ],
    ),
    
    // Pantallas individuales (sin bottom nav)
    GoRoute(path: '/sensor-dashboard', builder: (context, state) => SensorDashboardScreen()),
    GoRoute(path: '/image-gallery', builder: (context, state) => ImageGalleryScreen()),
    GoRoute(path: '/device-config', builder: (context, state) => DeviceConfigScreen()),
  ],
);
```

---

## 📋 **ARCHIVOS A CREAR/MODIFICAR**

### **Nuevos Archivos:**
- `lib/widgets/bottom_navigation_wrapper.dart`
- `lib/screens/device_connection_screen.dart`
- `lib/screens/about_screen.dart`
- `lib/screens/settings_screen.dart` (opcional)

### **Archivos a Modificar:**
- `lib/main.dart` (GoRouter configuration)
- `lib/screens/main_menu_screen.dart` (rediseño como dashboard)

### **Dependencias Adicionales:**
```yaml
# En pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^13.0.0  # Ya existe
  # Posibles adiciones:
  badges: ^3.1.2      # Para badges en navigation
  animations: ^2.0.8  # Para transiciones suaves
```

---

## 🎯 **PRÓXIMOS PASOS DE IMPLEMENTACIÓN**

### **Fase 1: Estructura Base**
1. ✅ Crear `BottomNavigationWrapper`
2. ✅ Implementar `DeviceConnectionScreen`
3. ✅ Implementar `AboutScreen`
4. ✅ Modificar configuración de GoRouter

### **Fase 2: Funcionalidad**
1. ⏳ Rediseñar `MainMenuScreen` como dashboard
2. ⏳ Implementar lógica de estado de conexión
3. ⏳ Agregar badges y indicadores visuales

### **Fase 3: Pulimiento**
1. ⏳ Animaciones y transiciones
2. ⏳ Optimización de rendimiento
3. ⏳ Testing en diferentes dispositivos

---

## 📊 **MÉTRICAS DE ÉXITO**

- **UX**: Reducción del 60% en pasos para acceder a funciones principales
- **Navegación**: Tiempo promedio <2 segundos para cambiar entre secciones
- **Usabilidad**: 95% de usuarios encuentran funciones sin ayuda
- **Performance**: Transiciones fluidas <300ms

---

*Documento creado: $(date)*
*Versión: 1.0*
*Estado: Pendiente de implementación*