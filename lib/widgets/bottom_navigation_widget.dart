import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget de navegación inferior personalizado con animaciones optimizadas
/// y características de accesibilidad mejoradas
class BottomNavigationWidget extends StatefulWidget {
  final int currentIndex;
  
  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
  });

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget>
    with TickerProviderStateMixin {
  
  // Controladores de animación optimizados
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  // Estado de interacción
  int _tappedIndex = -1;
  bool _isAnimating = false;
  
  // Configuración de tema y colores
  static const Color _primaryGreen = Color(0xFF56AB91);
  static const Color _mintGreen = Color(0xFFA8E6CF);
  static const Color _activeIconColor = Color(0xFF2E7D32);
  static const Color _inactiveIconColor = Color(0xFFFFFFFF);
  
  // Configuración de animaciones optimizada para mayor velocidad
  static const Duration _tapAnimationDuration = Duration(milliseconds: 100);  // Reducido de 150 a 100
  static const Duration _glowAnimationDuration = Duration(milliseconds: 1500);  // Reducido de 2000 a 1500
  
  // Datos de navegación
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_rounded,
      label: 'Home',
      route: '/main-menu',
      semanticLabel: 'Ir a la página de inicio',
    ),
    NavigationItem(
      icon: Icons.info_rounded,
      label: 'Info',
      route: '/about',
      semanticLabel: 'Ver información de la aplicación',
    ),
    NavigationItem(
      icon: Icons.settings,
      label: 'Device',
      route: '/device-connection',
      semanticLabel: 'Conectar con dispositivo',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startGlowAnimationIfNeeded();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  void didUpdateWidget(BottomNavigationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _handleIndexChange();
    }
  }

  /// Inicializa las animaciones con configuración optimizada
  void _initializeAnimations() {
    // Animación de escala para feedback táctil
    _scaleController = AnimationController(
      duration: _tapAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Animación de resplandor para elemento activo
    _glowController = AnimationController(
      duration: _glowAnimationDuration,
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  /// Libera recursos de animación
  void _disposeAnimations() {
    _scaleController.dispose();
    _glowController.dispose();
  }

  /// Inicia la animación de resplandor si es necesario
  void _startGlowAnimationIfNeeded() {
    if (_isValidIndex(widget.currentIndex)) {
      _glowController.repeat(reverse: true);
    }
  }

  /// Maneja el cambio de índice
  void _handleIndexChange() {
    if (_isValidIndex(widget.currentIndex)) {
      if (!_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
    } else {
      _glowController.stop();
      _glowController.reset();
    }
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
          margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 16),
          height: containerHeight,
          child: _buildNavigationContainer(),
        );
      },
    );
  }

  /// Calcula la altura del contenedor basada en el ancho de pantalla
  double _calculateContainerHeight(double screenWidth) {
    if (screenWidth < 360) return 70;  // Aumentado de 65 a 70
    if (screenWidth < 600) return 75;  // Aumentado de 70 a 75
    return 80;  // Aumentado de 75 a 80
  }

  /// Calcula el margen horizontal basado en el ancho de pantalla
  double _calculateHorizontalMargin(double screenWidth) {
    if (screenWidth < 360) return 13;  // Aumentado de 12 a 13 (+1px cada lado = -2px ancho total)
    if (screenWidth < 600) return 17;  // Aumentado de 16 a 17 (+1px cada lado = -2px ancho total)
    return 21;  // Aumentado de 20 a 21 (+1px cada lado = -2px ancho total)
  }

  /// Construye el contenedor principal de navegación
  Widget _buildNavigationContainer() {
    return Container(
      decoration: _buildContainerDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
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
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _primaryGreen.withValues(alpha: 0.95),
          _mintGreen.withValues(alpha: 0.9),
        ],
      ),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: _primaryGreen.withValues(alpha: 0.3),
          blurRadius: 15,
          offset: const Offset(0, 5),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
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
          onTap: () => _handleItemTap(index),
          onTapDown: (_) => _handleTapDown(index),
          onTapUp: (_) => _handleTapUp(),
          onTapCancel: _handleTapCancel,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              final scale = (_tappedIndex == index) ? _scaleAnimation.value : 1.0;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),  // Reducido de 12 a 8
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconContainer(item.icon, isSelected),
          // Etiqueta removida para mostrar solo iconos
        ],
      ),
    );
  }

  /// Construye el contenedor del icono con efectos
  Widget _buildIconContainer(IconData icon, bool isSelected) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(6),  // Reducido de 8 a 6
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected 
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.transparent,
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.white.withValues(alpha: _glowAnimation.value * 0.6),
                blurRadius: 8 * _glowAnimation.value,
                spreadRadius: 1 * _glowAnimation.value,
              ),
              BoxShadow(
                color: _activeIconColor.withValues(alpha: _glowAnimation.value * 0.3),
                blurRadius: 12 * _glowAnimation.value,
                spreadRadius: 1 * _glowAnimation.value,
              ),
            ] : null,
          ),
          child: Icon(
            icon,
            color: isSelected 
                ? _inactiveIconColor
                : _inactiveIconColor.withValues(alpha: 0.7),
            size: 22,
          ),
        );
      },
    );
  }

  /// Construye la etiqueta del elemento
  Widget _buildLabel(String label, bool isSelected) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        color: isSelected 
            ? _inactiveIconColor
            : _inactiveIconColor.withValues(alpha: 0.7),
        fontSize: 10,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
      // Iniciar animación de escala de forma no bloqueante
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

    // Navegar inmediatamente sin esperar animaciones
    final route = _navigationItems[index].route;
    if (mounted) {
      context.go(route);
    }

    // Proporcionar feedback háptico después de la navegación
    _provideFeedback();
  }

  /// Proporciona feedback háptico
  void _provideFeedback() {
    // Implementar feedback háptico si es necesario
    // HapticFeedback.lightImpact();
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