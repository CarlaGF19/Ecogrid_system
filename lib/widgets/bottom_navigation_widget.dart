import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget de navegación inferior personalizado con estilo Eco-Corporate
/// Diseño Glassmorphism minimalista con paleta de colores estricta
class BottomNavigationWidget extends StatefulWidget {
  final int currentIndex;

  const BottomNavigationWidget({super.key, required this.currentIndex});

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget>
    with TickerProviderStateMixin {
  // Controladores de animación
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Estado de interacción
  int _tappedIndex = -1;
  bool _isAnimating = false;

  // PALETA DE COLORES (MANDATORY — EcoGrid System)
  static const Color _primaryMint = Color(0xFF00E0A6); // Active state
  // ignore: unused_field
  static const Color _turquoiseSupport = Color(0xFF00B7B0); // Subtle accents
  static const Color _darkForest = Color(0xFF004C3F); // Inactive icons/text
  static const Color _baseBackground = Color(0xFFF1FBF9); // Base Background
  static const Color _borderColor = Color(0xFFE6FFF5); // Border / Divider
  static const Color _shadowEco = Color(
    0x26004C3F,
  ); // Dark Forest at ~15% opacity

  // Configuración de animaciones
  static const Duration _tapAnimationDuration = Duration(milliseconds: 100);

  // Datos de navegación (NO MODIFICAR)
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_filled,
      label: 'HOME',
      route: '/app-home',
      semanticLabel: 'Ir a la página de inicio',
    ),
    NavigationItem(
      icon: Icons.sensors,
      label: 'SENSORES',
      route: '/home',
      semanticLabel: 'Ver dashboard de sensores',
    ),
    NavigationItem(
      icon: Icons.photo_library,
      label: 'GALERÍA',
      route: '/image-gallery',
      semanticLabel: 'Ver galería de imágenes',
    ),
    NavigationItem(
      icon: Icons.settings,
      label: 'AJUSTES',
      route: '/ip',
      semanticLabel: 'Configuración del dispositivo',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  /// Inicializa las animaciones
  void _initializeAnimations() {
    // Animación de escala para feedback táctil
    _scaleController = AnimationController(
      duration: _tapAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  /// Libera recursos de animación
  void _disposeAnimations() {
    _scaleController.dispose();
  }

  /// Verifica si el índice es válido
  bool _isValidIndex(int index) {
    return index >= 0 && index < _navigationItems.length;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cálculo responsivo de dimensiones
        final screenWidth = constraints.maxWidth;
        final containerHeight = _calculateContainerHeight(screenWidth);
        final horizontalMargin = _calculateHorizontalMargin(screenWidth);

        return Container(
          margin: EdgeInsets.fromLTRB(
            horizontalMargin,
            0,
            horizontalMargin,
            20,
          ), // Slight increase in bottom margin
          height: containerHeight,
          child: _buildNavigationContainer(),
        );
      },
    );
  }

  /// Calcula la altura del contenedor basada en el ancho de pantalla
  double _calculateContainerHeight(double screenWidth) {
    if (screenWidth < 360) return 65;
    if (screenWidth < 600) return 70;
    return 75;
  }

  /// Calcula el margen horizontal basado en el ancho de pantalla
  double _calculateHorizontalMargin(double screenWidth) {
    if (screenWidth < 360) return 16;
    if (screenWidth < 600) return 24;
    return 32; // More padding for floating effect
  }

  /// Construye el contenedor principal de navegación
  Widget _buildNavigationContainer() {
    return Container(
      decoration: _buildContainerDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40), // More rounded (pill-like)
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Subtle blur
          child: Container(
            decoration: BoxDecoration(
              color: _baseBackground.withValues(
                alpha: 0.90,
              ), // High opacity for readability
              borderRadius: BorderRadius.circular(40),
            ),
            child: _buildNavigationRow(),
          ),
        ),
      ),
    );
  }

  /// Construye la decoración del contenedor
  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(40),
      border: Border.all(color: _borderColor, width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: _shadowEco,
          blurRadius: 20, // Medium blur
          offset: Offset(0, 8), // Vertical offset
          spreadRadius: -2,
        ),
      ],
    );
  }

  /// Construye la fila de elementos de navegación
  Widget _buildNavigationRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        _navigationItems.length,
        (index) => _buildNavigationItem(
          item: _navigationItems[index],
          index: index,
          isSelected: widget.currentIndex == index,
        ),
      ),
    );
  }

  /// Construye un elemento individual de navegación
  Widget _buildNavigationItem({
    required NavigationItem item,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: Semantics(
        label: item.semanticLabel,
        button: true,
        selected: isSelected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleItemTap(index),
          onTapDown: (_) => _handleTapDown(index),
          onTapUp: (_) => _handleTapUp(),
          onTapCancel: _handleTapCancel,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              final scale = (_tappedIndex == index)
                  ? _scaleAnimation.value
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: _buildItemContent(item, index, isSelected),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Construye el contenido del elemento de navegación
  Widget _buildItemContent(NavigationItem item, int index, bool isSelected) {
    return Container(
      height: double.infinity,
      color: Colors.transparent, // Hit area
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            color: isSelected
                ? _primaryMint
                : _darkForest.withValues(alpha: 0.6),
            size: 26,
          ),
          // Subtle active indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(top: 6),
            width: isSelected ? 4 : 0,
            height: isSelected ? 4 : 0,
            decoration: const BoxDecoration(
              color: _primaryMint,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  /// Maneja el evento de tap down
  void _handleTapDown(int index) {
    if (_isValidIndex(index)) {
      setState(() {
        _tappedIndex = index;
        _isAnimating = true;
      });
      _scaleController.forward();
    }
  }

  /// Maneja el evento de tap up
  void _handleTapUp() {
    if (_isAnimating) {
      _scaleController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _tappedIndex = -1;
            _isAnimating = false;
          });
        }
      });
    }
  }

  /// Maneja la cancelación del tap
  void _handleTapCancel() {
    if (_isAnimating) {
      _scaleController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _tappedIndex = -1;
            _isAnimating = false;
          });
        }
      });
    }
  }

  /// Maneja el tap en un elemento
  void _handleItemTap(int index) {
    if (!_isValidIndex(index)) return;

    final route = _navigationItems[index].route;
    if (mounted) {
      context.go(route);
    }
  }
}

/// Clase de datos para elementos de navegación
class NavigationItem {
  final IconData icon;
  final String label;
  final String route;
  final String semanticLabel;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.semanticLabel,
  });
}
