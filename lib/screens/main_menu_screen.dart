import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'sensor_dashboard_screen.dart';
import 'image_gallery_screen.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../constants/app_icons.dart';
import '../constants/app_config.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String _esp32Ip = '';
  String _apiBaseUrl = '';
  Map<String, dynamic> _sensorData = {};
  bool _isLoading = true;
  Timer? _dataTimer;
  bool _imageLoaded = false;
  bool _imageExists = false;
  bool _isDisposed = false; // Añadido para evitar setState después de dispose
  bool _isDataFetching =
      false; // Añadido para evitar múltiples llamadas simultáneas

  @override
  void initState() {
    super.initState();
    // Optimización: Cargar datos de forma asíncrona sin bloquear la UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIpAndFetchData();
      _preloadImageAsync();
    });

    // Optimización: Reducir frecuencia del timer de 10s a 15s para mejor rendimiento
    _dataTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isDisposed && mounted) {
        _fetchSensorDataWithDebounce();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _dataTimer?.cancel();
    super.dispose();
  }

  // Optimización: Precarga de imagen asíncrona para no bloquear la UI inicial
  Future<void> _preloadImageAsync() async {
    if (_isDisposed) return;

    try {
      await precacheImage(
        const AssetImage('assets/images/img_main_menu_screen.jpg'),
        context,
      );
      if (!_isDisposed && mounted) {
        setState(() {
          _imageExists = true;
          _imageLoaded = true;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _imageExists = false;
          _imageLoaded = true;
        });
      }
    }
  }

  // Optimización: Debouncing para evitar múltiples llamadas simultáneas
  Future<void> _fetchSensorDataWithDebounce() async {
    if (_isDataFetching || _isDisposed) return;
    _isDataFetching = true;

    try {
      await _fetchSensorData();
    } finally {
      _isDataFetching = false;
    }
  }

  Future<void> _loadIpAndFetchData() async {
    if (_isDisposed) return;

    final prefs = await SharedPreferences.getInstance();
    _esp32Ip = prefs.getString("esp32_ip") ?? "";
    final savedApi = prefs.getString('api_base_url') ?? '';
    _apiBaseUrl = savedApi.isNotEmpty ? savedApi : AppConfig.DEFAULT_API_BASE_URL;
    await _fetchSensorDataWithDebounce();
  }

  Future<void> _fetchSensorData() async {
    if (_isDisposed || !mounted) return;

    if (_esp32Ip.isEmpty && (_apiBaseUrl.isEmpty)) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _sensorData = {};
        });
      }
      return;
    }

    try {
      // Si existe API Sheets, usar lastReading; si no, usar ESP32 /sensors
      http.Response response;
      if (_apiBaseUrl.isNotEmpty) {
        response = await http
            .get(
              Uri.parse('$_apiBaseUrl?endpoint=lastReading'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 3));
      } else {
        // Optimización: Timeout reducido de 5s a 3s para respuesta más rápida
        response = await http
            .get(
              Uri.parse('http://$_esp32Ip/sensors'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 3));
      }

      if (!_isDisposed && mounted) {
        if (response.statusCode == 200) {
          final parsed = json.decode(response.body);
          setState(() {
            _sensorData = parsed is Map<String, dynamic> ? parsed : {};
            _isLoading = false;
          });
        } else {
          setState(() {
            _sensorData = {};
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _sensorData = {};
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Verde muy claro de fondo
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen decorativa que cubre todo el header
          _buildHeaderImage(),

          // Contenido con padding en un Expanded para ocupar el resto del espacio
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Módulo introductorio
                    _buildIntroductoryModule(),

                    const SizedBox(height: 8),

                    // Accesos Rápidos
                    _buildQuickAccess(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
    );
  }

  Widget _buildIntroductoryModule() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: Color(0xFF009E73), size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Guía',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004C3F),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  // Aquí se puede agregar la navegación al módulo introductorio
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Módulo introductorio próximamente'),
                      backgroundColor: Color(0xFF00E0A6),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF00E0A6),
                        Color(0xFF00B7B0),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x6600E0A6),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Módulo introductorio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess() {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardPadding = (screenWidth * 0.035).clamp(14.0, 18.0);
    double buttonSpacing = (screenWidth * 0.015).clamp(10.0, 12.0);
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6FFF5), // fondo tarjeta verde muy claro (crypto)
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE6FFF5),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2600A078), // sombra suave rgba(0,160,120,0.15)
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: cardPadding,
            vertical: cardPadding * 0.6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flash_on,
                    color: Color(0xFF009E73), // icono secundario crypto
                    size: 24,
                  ),
                  SizedBox(width: buttonSpacing * 0.8),
                  const Text(
                    'Accesos Rápidos',
                    style: TextStyle(
                      fontSize: 17, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004C3F), // texto principal crypto
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: cardPadding * 0.5),
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Flexible(
        flex: 1,
        child: _buildQuickAccessButton(
          'Sensores',
          Icons.dashboard,
          const Color(0xFF43A047), // Verde 600
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SensorDashboardScreen(ip: _esp32Ip),
              ),
            );
          },
          iconAsset: AppIcons.sensor,
          iconScale: 1.5,
        ),
      ),
      SizedBox(width: buttonSpacing),
       Flexible(
         flex: 1,
         child: _buildQuickAccessButton(
           'Galería',
           Icons.photo_library,
           const Color(0xFF2E7D32), // Verde 800
           () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => const ImageGalleryScreen(),
               ),
             );
           },
           iconAsset: AppIcons.gallery,
            iconScale: 1.5,
         ),
       ),
    ],
  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? iconAsset,
    double? iconScale,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerHeightBase = (screenWidth * 0.22).clamp(80.0, 110.0);
    double internalPadding = (screenWidth * 0.028).clamp(12.0, 16.0);
    double iconSize = (screenWidth * 0.085).clamp(30.0, 36.0);
    double textSize = (screenWidth * 0.036).clamp(13.0, 15.0);
    double effectiveIconSize = iconSize * (iconScale ?? 1.0);
    // Estimamos la altura necesaria en función del icono, texto y padding,
    // y garantizamos que el contenedor sea lo suficientemente alto para evitar overflow.
    double contentHeightEstimate =
        effectiveIconSize + 8 /*espaciado*/ + (textSize * 1.6) + (internalPadding * 1.6);
    double containerHeight = contentHeightEstimate > containerHeightBase
        ? contentHeightEstimate
        : containerHeightBase;

    // Estados de hover/press para web/desktop
    bool isHovered = false;
    bool isPressed = false;

    return StatefulBuilder(
      builder: (context, setInnerState) {
        double scaleFactor = isPressed ? 0.985 : (isHovered ? 1.02 : 1.0);
        final List<BoxShadow> dynamicShadows = [
          const BoxShadow(
            color: Color(0x6600E0A6),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: (isHovered || isPressed)
                ? const Color(0x3300E0A6)
                : const Color(0x1A00E0A6),
            blurRadius: (isHovered || isPressed) ? 14 : 8,
            offset: const Offset(0, 0),
          ),
        ];

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setInnerState(() => isHovered = true),
          onExit: (_) => setInnerState(() => isHovered = false),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            onHighlightChanged: (v) => setInnerState(() => isPressed = v),
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: AnimatedScale(
              scale: scaleFactor,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              child: Container(
                height: containerHeight,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: internalPadding,
                  vertical: internalPadding * 0.8,
                ),
                decoration: BoxDecoration(
                  // Gradiente crypto green
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF00E0A6),
                      Color(0xFF00B7B0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: dynamicShadows,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ícono con ligero desplazamiento en hover
                    Transform.translate(
                      offset: Offset(0, isHovered ? -2 : 0),
                      child: iconAsset != null
                          ? Image.asset(
                              iconAsset,
                              width: effectiveIconSize,
                              height: effectiveIconSize,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(icon, color: const Color(0xFF00E0A6), size: effectiveIconSize),
                            )
                          : Icon(icon, color: const Color(0xFF00E0A6), size: effectiveIconSize),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderImage() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      height: (screenHeight * 0.37), // 37% de la pantalla según preferencia
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo
            _buildImageContent(),

            // Controles superiores sobre la imagen
            SafeArea(
              child: Stack(
                children: [
                  // Izquierda superior
                  Positioned(
                    left: 12,
                    top: 6, // más arriba dentro del header
                    child: _buildCircularTopButton(
                      icon: Icons.arrow_back_ios_new, // flecha más delgada
                      baseIconColor: const Color(0xFF004C3F),
                      onTap: () {
                        // Navegar directamente a la pantalla de configuración de IP
                        if (mounted) {
                          context.go('/ip');
                        }
                      },
                      semanticsLabel: 'Atrás',
                    ),
                  ),
                  // Derecha superior
                  Positioned(
                    right: 12,
                    top: 6, // más arriba dentro del header
                    child: _buildCircularTopButton(
                      icon: Icons.notifications_none_outlined, // campana de notificaciones
                      showBadge: true,
                      baseIconColor: const Color(0xFF004C3F),
                      onTap: () {
                        if (mounted) {
                          context.go('/notifications');
                        }
                      },
                      semanticsLabel: 'Acción',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    // Si la imagen no ha terminado de cargar, muestra el fondo por defecto
    if (!_imageLoaded) {
      return _buildDefaultBackground();
    }

    // Si la imagen existe y está cargada, la muestra
    if (_imageExists) {
      return Image.asset(
        'assets/images/img_main_menu_screen.jpg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultBackground();
        },
      );
    } else {
      // Si no existe la imagen, usa el fondo por defecto
      return _buildDefaultBackground();
    }
  }

  Widget _buildDefaultBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/img_main_menu_screen.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Botón circular reutilizable para controles superiores
  Widget _buildCircularTopButton({
    required IconData icon,
    bool showBadge = false,
    required Color baseIconColor,
    required VoidCallback onTap,
    required String semanticsLabel,
  }) {
    bool isHovered = false;
    bool isPressed = false;
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: StatefulBuilder(
        builder: (context, setInnerState) {
          Color effectiveIconColor = (isHovered || isPressed) ? Colors.white : baseIconColor;
          return MouseRegion(
            onEnter: (_) => setInnerState(() => isHovered = true),
            onExit: (_) => setInnerState(() => isHovered = false),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              onHighlightChanged: (value) => setInnerState(() => isPressed = value),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.35),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        // Sombra de caída suave con tono mint (crypto)
                        const BoxShadow(
                          color: Color(0x4000E0A6), // rgba(0,224,166,0.25)
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                        // Halo energético (se intensifica en hover/press)
                        BoxShadow(
                          color: (isHovered || isPressed)
                              ? const Color(0x9900E0A6) // rgba(0,224,166,0.6)
                              : const Color(0x3300E0A6), // sutil en reposo
                          blurRadius: (isHovered || isPressed) ? 12 : 8,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Icon(
                            icon,
                            color: effectiveIconColor,
                            size: 20,
                          ),
                        ),
                        if (showBadge)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF66BB6A),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x2600E0A6), // sombra sutil acorde
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
