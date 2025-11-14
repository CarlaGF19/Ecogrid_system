# Propuesta de Cambios – Main Menu Screen

Este documento describe mejoras visuales y de UX para la pantalla principal, basadas en la maqueta que compartiste. No ejecuta código; es una guía verificable de lo que implementaré cuando lo indiques.

## Objetivo
- Mantener la estética actual (imagen hero con bordes redondeados, tarjetas y botones verdes) y eliminar espacios en blanco no deseados.
- Mejorar consistencia visual, legibilidad y respuesta en diferentes tamaños de pantalla (móvil/web).
- Respetar el alcance: tocar solo `lib/screens/main_menu_screen.dart` y assets si fuese necesario.

## Diagnóstico de la interfaz actual
- Header con imagen hero:
  - A veces aparece espacio en blanco a la derecha o debajo por disposición/padding.
  - Bordes redondeados correctos, sombra agradable.
  - Iconos superiores (volver y dron) superpuestos; requieren safe area control.
- Tarjeta “Guía”:
  - Estilo coherente, podría mejorar la jerarquía tipográfica y el espaciado interno.
- Bloque "Accesos Rápidos":
  - Gradiente y botones funcionales; padding y separación entre tarjetas pueden ser más consistentes.
  - Botones con estados/hover no homogéneos en web.
- Barra inferior (bottom navigation):
  - Aspecto correcto; conviene asegurar el espaciado superior para evitar solapamientos en scroll.

## Cambios propuestos (solo main_menu_screen.dart)
1. Header Image (sin espacios en blanco):
   - Forzar ancho completo con `width: double.infinity` y `constraints: BoxConstraints.expand(height: ...)`.
   - Mantener bordes redondeados y sombra. Usar `ClipRRect` con el mismo `borderRadius` para evitar bleed.
   - Reemplazar altura fija por `AspectRatio` (p.ej. 16:9) en móvil y `0.35 * screenHeight` en web para balance entre recorte y cobertura.
   - Envolver iconos superiores en `SafeArea` dentro de un `Stack` para garantizar margen en dispositivos con notch.
   - Pre-cache del asset en `initState` para evitar parpadeos; mantener fallback si el asset falta.

2. Estructura y Scroll:
   - Usar `Column` con `Expanded(SingleChildScrollView(...))` para estabilidad del layout (ya aplicado).
   - Asegurar `crossAxisAlignment: CrossAxisAlignment.stretch` en contenedores principales para evitar huecos horizontales.

3. Tarjeta “Guía”:
   - Alinear verticalmente título, descripción y botón con una escala de espaciado consistente (8/12/16 px).
   - Aumentar contraste del botón principal y fijar altura mínima (44 px) para accesibilidad.

4. Accesos Rápidos:
   - Mantener gradiente del contenedor; ajustar padding interno y separación entre tarjetas.
   - Normalizar estados hover/focus en web (opacidad/levitación ligera).
   - Hacer las tarjetas adaptables: si el ancho disponible lo permite, equilibrar a 2 columnas; en pantallas más anchas, permitir 3 columnas sin cambiar el contenido actual.

5. Responsividad y cohesión visual:
   - Definir breakpoints simples: móvil (<600 px), tablet (600–1024 px), desktop (>1024 px).
   - Escalar tipografías y paddings por breakpoint sin introducir temas nuevos.

6. Accesibilidad y performance:
   - Añadir `Semantics` en botones clave y descripciones breves.
   - `filterQuality: FilterQuality.medium` en la imagen y `precacheImage` para suavidad.

## Plan de implementación (cuando lo indiques)
- Ajustar `_buildHeaderImage()` a `Stack + SafeArea + AspectRatio/height dinámica` y `BoxConstraints.expand`.
- Revisar paddings globales para eliminar huecos laterales: `EdgeInsets.symmetric(horizontal: 16)` en contenido, `stretch` donde aplique.
- Normalizar estilos de botones de “Accesos Rápidos” con estados hover/focus en web.
- Afinar la tarjeta “Guía” con una escala de espaciado coherente y contraste del CTA.
- Pre-cache del asset del header y mantener fallback.

## Validación
- Ejecutar en Chrome/Edge y verificar:
  - La imagen del header cubre 100% del ancho sin espacios.
  - Bordes redondeados y sombra permanecen correctos.
  - Scroll suave sin solapamientos con la barra inferior.
  - Botones reaccionan correctamente en hover/focus.

Cuando confirmes, aplico estos cambios exclusivamente en `main_menu_screen.dart` y te muestro el resultado.