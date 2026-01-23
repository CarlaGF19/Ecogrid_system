# 📱 ESTRUCTURA DEL BOTTOM NAVIGATION BAR - EcoGrid

## 🎯 **VISIÓN GENERAL**

Este documento define la estructura actual del **Bottom Navigation Bar** para la aplicación EcoGrid, alineada con el rediseño visual "Eco-Corporate" y la arquitectura de navegación implementada.

**Estado:** Implementado ✅
**Estilo:** Glassmorphism Eco-Corporate

---

## 🎨 **DISEÑO VISUAL (MANDATORY)**

### **Paleta de Colores (EcoGrid System)**
- **Primary Mint (Activo):** `#00E0A6`
- **Dark Forest (Inactivo):** `#004C3F` (Opacidad 60%)
- **Base Background:** `#F1FBF9` (Opacidad 90%)
- **Border:** `#E6FFF5`
- **Shadow:** `#004C3F` (Opacidad 15%)

### **Estilo del Contenedor**
- **Forma:** Pill-shaped (Bordes redondeados 40px)
- **Margen:** Flotante (Horizontal 24px, Inferior 24px)
- **Efecto:** Glassmorphism con desenfoque suave (BackdropFilter)
- **Indicador Activo:** Punto circular sutil (`#00E0A6`, 4px)

---

## 🔧 **CONFIGURACIÓN DE ELEMENTOS**

### **Lista de Navegación**

| Posición | Etiqueta | Icono | Ruta | Descripción |
|----------|----------|-------|------|-------------|
| **1** | **HOME** | `Icons.home_filled` | `/app-home` | **HomeScreen**: Dashboard principal con accesos rápidos. |
| **2** | **SENSORES** | `Icons.sensors` | `/home` | **SensorDashboardScreen**: Monitoreo en tiempo real. |
| **3** | **GALERÍA** | `Icons.photo_library` | `/image-gallery` | **ImageGalleryScreen**: Historial visual. |
| **4** | **AJUSTES** | `Icons.settings` | `/ip` | **DeviceConfigScreen**: Configuración de conexión. |

---

## 🔄 **COMPORTAMIENTO**

### **Navegación (GoRouter)**
- Cada ítem utiliza `context.go(route)` para la navegación.
- El estado de selección se basa en la ruta actual o el índice proporcionado.

### **Interacción**
- **Feedback Táctil:** Animación de escala sutil (0.95x) al presionar.
- **Transiciones:** Cambio de color suave e indicador animado.
- **Hit Area:** Expandida para facilitar el toque en dispositivos móviles.

---

## 🚫 **RESTRICCIONES (STRICT SCOPE)**

1. **NO modificar lógica de navegación:** Los destinos y el orden son fijos.
2. **NO cambiar iconos:** Se mantienen los iconos definidos en el código.
3. **NO usar colores neón/oscuros:** Adherencia estricta a la paleta Eco-Corporate.

---

*Documentación actualizada - Enero 2026*
