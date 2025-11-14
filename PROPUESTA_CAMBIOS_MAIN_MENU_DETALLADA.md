# Propuesta de Cambios – Main Menu Screen (versión detallada)

Este documento es la guía de implementación para mejorar el Main Menu respetando tu maqueta. No ejecuta código y define con precisión qué se cambiará y qué no.

## Restricciones (obligatorias)
- No modificar archivos fuera de `lib/screens/main_menu_screen.dart`.
- Prohibido cambiar estilos, tonos o identidad visual de:
  - `lib/screens/sensor_detail_page.dart` (sensor detail)
  - `lib/screens/splash_screen.dart` (splash)
- Mantener comportamiento actual de navegación y lógica; los cambios son visuales/maquetación.

## Alcance
- Ajustes visuales del header (imagen hero) y sus dos botones circulares superpuestos.
- Refinar espaciados y consistencia de “Guía” y “Accesos Rápidos”.
- Responsividad y estados en web (hover/focus) sin alterar rutas ni lógica.

## Diagnóstico de la maqueta y estado actual
- La imagen hero puede dejar espacios en blanco laterales si el contenedor no se estira al 100%.
- Los dos botones circulares (izquierda: volver; derecha: acción auxiliar) necesitan SafeArea, z-index y padding consistentes.
- Tarjeta “Guía” y bloque “Accesos Rápidos” tienen buena base; se propone afinar espaciados y contraste.

## Especificación de cambios (solo main_menu_screen.dart)
1) Header: imagen hero sin espacios en blanco
- Contenedor: `width: double.infinity` y `constraints: BoxConstraints.tightFor(height: H)`, con H adaptativa:
  - Móvil: `H = min(360, max(240, 0.35 * screenHeight))`
  - Web: `H ≈ 28–35vh` según pantalla
- Bordes: solo esquinas inferiores redondeadas (`Radius.circular(16)`).
- Sombra: `BoxShadow(color: rgba(0,0,0,0.10), blurRadius: 8, spreadRadius: 2, offset: (0,4))`.
- Clip: `ClipRRect` con el mismo radio para evitar fugas.
- Imagen: `Image.asset('assets/images/img_main_menu_screen.jpg', fit: BoxFit.cover, filterQuality: FilterQuality.medium)`.
- Precarga: `precacheImage(const AssetImage(...), context)` en `initState` para evitar parpadeos.
- Estructura: `Stack(children: [Imagen, SafeArea(child: _TopControls())])`.

2) Botones circulares superpuestos (izq/dcha) – verificación y mejora
- Forma: circular, diámetro 48dp (mínimo 44dp), padding interno 8dp.
- Fondo: blanco con leve degradado radial (`#FFFFFF → #F5F7F5`).
- Borde: `Border.all(color: #E7ECE8, width: 1)` (sutil).
- Sombra: `BoxShadow rgba(0,0,0,0.12), blur 10, offset (0,4)`.
- Iconos:
  - Izquierda: `Icons.arrow_back` (color `#1B5E20`, tamaño 22–24dp).
  - Derecha: mantener el icono actual del proyecto (p. ej. dron/sensor), color `#1B5E20`, tamaño 22–24dp.
- Posicionamiento: `Positioned(left: 12, top: 12)` y `Positioned(right: 12, top: 12)` dentro de `SafeArea`.
- Interacción: `InkWell`/`InkResponse` con ripple suave; accesible (`Semantics(label: "Atrás" / "Acción")`).
- Verificación: se confirma la presencia de ambos botones circulares y se normaliza su estilo (tamaño, icono, color, degradado y sombra) sin cambiar su función.

3) Tarjeta “Guía” (afinado visual)
- Espaciado interno: 16–20dp; separación entre título y botón: 12–16dp.
- CTA “Módulo introductorio”: altura mínima 44dp, color verde actual, texto con contraste AA.
- Bordes y sombra: mantener estilo del sistema actual (radio 16, sombra suave).

4) Bloque “Accesos Rápidos”
- Contenedor: gradiente existente (verde claro → verde medio), radio 16, padding 16–20dp.
- Tarjetas: separación horizontal 16dp, vertical 12dp; borde y sombra coherentes.
- Estados web: hover con elevación +1 y opacidad 0.96; focus visible para accesibilidad.
- Layout adaptable: 2 columnas por defecto; permitir ajuste proporcional en pantallas anchas sin añadir nuevas tarjetas.

5) Responsividad y cohesión
- Breakpoints: móvil (<600), tablet (600–1024), desktop (>1024).
- Escalar tipografías y paddings por breakpoint manteniendo la paleta actual.

6) Accesibilidad y performance
- `Semantics` en botones clave y descripciones.
- `filterQuality` medio en imagen + `precacheImage`.

## No cambios (garantías)
- No se tocan: `sensor_detail_page.dart` y `splash_screen.dart`.
- No se modifican rutas, navegación ni lógica de negocio.
- No se cambian paletas globales ni temas compartidos.

## Plan de implementación (cuando indiques)
- Ajuste de `_buildHeaderImage()` con `Stack + SafeArea`, altura adaptativa y clip consistente.
- Creación/refactor de `_TopControls()` para los dos botones circulares (izq/dcha) con las especificaciones anteriores.
- Revisión de paddings globales (contenido principal) para eliminar cualquier hueco lateral restante.
- Afinado visual de “Guía” y “Accesos Rápidos” (espaciado, estados web) sin modificar su lógica.

## Validación visual
- Abrir en Chrome y Edge; comprobar:
  - La imagen cubre 100% del ancho sin espacios en blanco.
  - Bordes inferiores redondeados + sombra correcta.
  - Botones circulares visibles, alineados, con degradado y sombra; tap target ≥ 44dp.
  - Scroll fluido y sin solapamiento con la barra inferior.

Listo para aplicar en `main_menu_screen.dart` cuando lo indiques.

## Paleta mejorada (verde agrícola moderno)
- Fondo general: `#E8F3EA` (verde claro casi blanco).
- Botones primarios / acento: `#3C8D2F` (verde vibrante natural).
- Gradiente de tarjetas (módulos / accesos rápidos): `linear-gradient(135deg, #A9DB80, #6FBF73)`.
- Detalles / íconos secundarios: `#2E5F3D` (verde oscuro para contraste).
- Acentos de energía o IA: `#FFD166` (amarillo cálido).

Aplicación concreta en componentes:
- Header: mantiene imagen y estética; iconos superiores usan `#2E5F3D`. Si el icono derecho requiere destacar, se puede añadir un pequeño badge `#FFD166`.
- Botones circulares (izq/dcha): icono `#2E5F3D`, fondo blanco con degradado radial sutil; borde `#E7ECE8`.
- Tarjeta “Guía”: CTA con fondo `#3C8D2F` y texto blanco; icono del título en `#2E5F3D`.
- Accesos Rápidos: aplicar el gradiente `(#A9DB80 → #6FBF73 @ 135°)` al contenedor; los botones internos pueden usar contornos/íconos `#2E5F3D` y pequeños acentos `#FFD166` en indicadores de estado.
- Contraste: asegurar AA mínimo (ratio 4.5:1) en textos sobre verdes; si alguna combinación baja de contraste, oscurecer el verde en 4–6%.

Equivalente en Flutter para el gradiente (referencia):
- `LinearGradient(colors: [Color(0xFFA9DB80), Color(0xFF6FBF73)], begin: Alignment.topLeft, end: Alignment.bottomRight)`.

## Jerarquía y relieve (neumorfismo ligero)
- Sombra suave: `box-shadow: 0 4px 10px rgba(0,0,0,0.15)` → en Flutter: `BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: Offset(0,4))`.
- Bordes redondeados marcados: `border-radius: 20px` → `BorderRadius.circular(20)`.
- Fondo con ligero degradado en “Accesos Rápidos” para profundidad: usar el gradiente especificado; evitar saturación en sombras para que el neumorfismo se perciba limpio.
- Estados: hover/focus elevan 1 nivel (blur +2, opacidad 0.96) en web; en móvil mantener ripple sutil.

Plan de ajuste con esta paleta y relieve (sin ejecutar aún):
- Aplicar nueva paleta en íconos y CTAs del Main Menu respetando la identidad actual.
- Actualizar el contenedor de “Accesos Rápidos” al gradiente `#A9DB80 → #6FBF73` con radio 20.
- Normalizar las sombras a la receta neumórfica y aumentar radios a 20 donde corresponda (header: bordes inferiores; tarjetas: todos los bordes).
- Revisar contraste y acentos `#FFD166` en “Sensores” y “Galería” para dar energía visual.