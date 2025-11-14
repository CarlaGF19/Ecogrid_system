# Guía de botones para la pestaña Sensor Dashboard (solo esta pantalla)

Esta guía describe cómo implementar los botones del **Sensor Dashboard** siguiendo el estilo de tu imagen y la paleta “crypto green”, respetando estrictamente el alcance: los cambios se aplican **solo** en `SensorDashboardScreen` y **no** modifican colores/tonos de otras pestañas ni los gráficos del tab **Sensor Details**.

## Resumen visual (basado en la imagen)
- Tarjeta con **borde redondeado** y contenedor claro.
- Ilustración/gráfico arriba (no se modifica).
- Título en mayúsculas, color verde.
- Botón inferior tipo **píldora** (“Show Details”) con fondo muy claro, borde y sombra suave.

## Paleta y sombras (exclusiva para Sensor Dashboard)
- Fondo AppBar: `#FFFFFF`.
- Verde primario (iconos/acentos): `#00E0A6`.
- Verde secundario (texto/títulos/bordes): `#009E73`.
- Fondo de tarjeta y botón claro: `#E6FFF5`.
- Hover/highlight (solo web): `#6DFFF5`.
- Sombra suave: `rgba(0, 160, 120, 0.15)`.

## Especificaciones del botón tipo píldora
- **Nombre**: Botón de acción primaria del dashboard (“Show Details”).
- **Tamaño**: altura 36–40 px, padding horizontal 16–20 px.
- **Forma**: Radio 18–24 px (píldora).
- **Fondo (default)**: `#E6FFF5`.
- **Borde**: 1 px `#009E73`.
- **Texto**: `#009E73`, peso `600`.
- **Sombra**: `rgba(0, 160, 120, 0.15)`, blur `10`, offset `(0, 4)`.
- **Hover (web)**: fondo `#6DFFF5` y ligera elevación visual.
- **Pressed**: mantener colores; reducción de escala a `0.98` opcional para feedback.
- **Disabled**: opacidad `0.4` del fondo y texto.

## Ubicación y jerarquía
- El botón se ubica **dentro de cada tarjeta de sensor**, debajo del título.
- Mantener márgenes verticales de `8–12 px` alrededor del botón para respiración visual.

## Implementación en Flutter (solo `lib/screens/sensor_dashboard_screen.dart`)

### 1) Componente reutilizable del botón
```dart
class SensorActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SensorActionButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE6FFF5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF009E73), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 160, 120, 0.15),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Show Details', // o 'Ver detalles' según idioma
          style: TextStyle(
            color: Color(0xFF009E73),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
```

### 2) Integración en la tarjeta de sensor
Reemplazar el texto plano “Ver detalles” por el nuevo componente, manteniendo `onTap` de la tarjeta:
```dart
// Dentro de SensorCard
SensorActionButton(
  label: 'Show Details',
  onTap: onTap,
),
```

### 3) Hover suave (opcional, solo web)
Para un hover mint sin librerías extra, envolver con `MouseRegion` y cambiar el color en estado **hover**:
```dart
class SensorActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const SensorActionButton({super.key, required this.label, required this.onTap});
  @override
  State<SensorActionButton> createState() => _SensorActionButtonState();
}

class _SensorActionButtonState extends State<SensorActionButton> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    final Color bg = _hovering ? const Color(0xFF6DFFF5) : const Color(0xFFE6FFF5);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF009E73), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 160, 120, 0.15),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFF009E73),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
```

## Accesibilidad
- Tamaño táctil mínimo del botón: 44 px de altura.
- Contraste suficiente entre texto y fondo (verde oscuro sobre mint claro).
- Estados de enfoque (focus) visibles en web/móvil.

## Restricciones y buenas prácticas
- **Prohibido** cambiar colores o tonos de otras pestañas.
- **Solo** se aplican cambios en `SensorDashboardScreen`.
- No modificar los **gráficos** del tab `Sensor Details`.
- Mantener la navegación de regreso con `Navigator.pop(context)`.

## Checklist de implementación
- [x] Header blanco con paleta verde (ya aplicado).
- [x] Tarjetas con fondo translúcido, borde y sombra suave (ya aplicado).
- [ ] Botón tipo píldora “Show Details” por tarjeta usando esta guía.

---
Si lo deseas, puedo integrar el componente `SensorActionButton` directamente en `sensor_dashboard_screen.dart` y validar en la preview sin tocar otras pantallas.