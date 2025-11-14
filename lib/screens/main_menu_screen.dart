import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Se mantiene para _fetchSensorData
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart'; // <--- ELIMINADO (ya no se usa)

// --- NUEVAS IMPORTACIONES REQUERIDAS PARA PDFPage ---
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart'; // Para peticiones en PDFPage
import 'dart:io'; // Para PDFPage (Móvil)
import 'package:path_provider/path_provider.dart'; // Para PDFPage (Móvil)
import 'package:open_file/open_file.dart'; // Para PDFPage (Móvil)
import 'dart:html' as html; // Para PDFPage (Web)
// --- FIN NUEVAS IMPORTACIONES ---

import 'sensor_dashboard_screen.dart';
import 'image_gallery_screen.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../constants/app_icons.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String _esp32Ip = '';
  String _apiBaseUrl = ''; // <-- Esta URL se pasará a PDFPage
  Map<String, dynamic> _sensorData = {};
  bool _isLoading = true;
  Timer? _dataTimer;
  bool _imageLoaded = false;
  bool _imageExists = false;
  bool _isDisposed = false;
  bool _isDataFetching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIpAndFetchData();
      _preloadImageAsync();
    });

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

  Future<void> _fetchSensorDataWithDebounce() async {
    if (_isDataFetching || _isDisposed) return;
    _isDataFetching = true;

    try {
      await _fetchSensorData();
    } finally {
      _isDataFetching = false;
    }
  }

  // ▼▼▼ ¡FUNCIÓN CORREGIDA! ▼▼▼
  Future<void> _loadIpAndFetchData() async {
    if (_isDisposed) return;

    final prefs = await SharedPreferences.getInstance();
    _esp32Ip = prefs.getString("esp32_ip") ?? "";

    // ¡AQUÍ ESTÁ LA CORRECCIÓN!
    // Forzamos el uso de la URL de tu API de Google Apps Script.
    // Esto soluciona el error de "API no configurada".
    _apiBaseUrl =
        "https://script.google.com/macros/s/AKfycbygUivdTGdLb_2p7f80TAJiwm_elb7FfXvyIJn_ID-BYhedUWjOQs1Sqk2rmubtn80N/exec";

    // Ya no necesitamos cargar 'savedApi' o 'AppConfig.DEFAULT_API_BASE_URL'

    await _fetchSensorDataWithDebounce();
  }

  // ▼▼▼ ¡FUNCIÓN CORREGIDA! ▼▼▼
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
      http.Response response;
      if (_apiBaseUrl.isNotEmpty) {
        // ¡CORRECCIÓN! El endpoint es 'last1min' según tu API.
        response = await http
            .get(
              Uri.parse('$_apiBaseUrl?endpoint=last1min'), // <-- Corregido
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 3));
      } else {
        // Fallback al ESP32 si la API Falla (aunque ahora no debería)
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
          _buildHeaderImage(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildIntroductoryModule(),
                    const SizedBox(height: 8),
                    _buildQuickAccess(), // <-- El botón modificado está aquí
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
    // ... (Este widget no necesita cambios)
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
                      colors: [Color(0xFF00E0A6), Color(0xFF00B7B0)],
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
          color: const Color(
            0xFFE6FFF5,
          ), // fondo tarjeta verde muy claro (crypto)
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6FFF5), width: 1),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(width: 16),
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
                  const SizedBox(width: 16),

                  // ▼▼▼ ¡BOTÓN "DOWNLOAD" CORREGIDO! ▼▼▼
                  Flexible(
                    flex: 1,
                    child: Semantics(
                      label: 'Download PDF por Rango', // Semántica actualizada
                      button: true,
                      child: _buildQuickAccessButton(
                        'Download',
                        Icons.picture_as_pdf,
                        const Color(0xFF2E7D32),
                        () {
                          // ¡ACCIÓN REEMPLAZADA!
                          // Navegamos a la nueva pantalla PDFPage
                          // y le pasamos la URL de la API.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PDFPage(apiBaseUrl: _apiBaseUrl),
                            ),
                          );
                        },
                        iconAsset: 'recursos/iconos/archivo-pdf.png',
                        iconScale: 1.5,
                      ),
                    ),
                  ),
                  // ▲▲▲ ¡FIN DE LA CORRECCIÓN! ▲▲▲
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
    // ... (Este widget constructor no necesita cambios)
    double screenWidth = MediaQuery.of(context).size.width;
    double containerHeightBase = (screenWidth * 0.22).clamp(80.0, 110.0);
    double internalPadding = (screenWidth * 0.028).clamp(12.0, 16.0);
    double iconSize = (screenWidth * 0.085).clamp(30.0, 36.0);
    double textSize = (screenWidth * 0.036).clamp(13.0, 15.0);
    double effectiveIconSize = iconSize * (iconScale ?? 1.0);
    double contentHeightEstimate =
        effectiveIconSize +
        8 /*espaciado*/ +
        (textSize * 1.6) +
        (internalPadding * 1.6);
    double containerHeight = contentHeightEstimate > containerHeightBase
        ? contentHeightEstimate
        : containerHeightBase;

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
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00E0A6), Color(0xFF00B7B0)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: dynamicShadows,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(0, isHovered ? -2 : 0),
                      child: iconAsset != null
                          ? Image.asset(
                              iconAsset,
                              width: effectiveIconSize,
                              height: effectiveIconSize,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    icon,
                                    color: const Color(0xFF00E0A6),
                                    size: effectiveIconSize,
                                  ),
                            )
                          : Icon(
                              icon,
                              color: const Color(0xFF00E0A6),
                              size: effectiveIconSize,
                            ),
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

  // ▼▼▼ ¡FUNCIONES PDF ANTIGUAS ELIMINADAS! ▼▼▼
  // _generateAndDownloadPdf() ya no existe.
  // _parseCsv() ya no existe.
  // _buildTable() ya no existe.
  // ▲▲▲ ¡FUNCIONES PDF ANTIGUAS ELIMINADAS! ▲▲▲

  Widget _buildHeaderImage() {
    // ... (Este widget no necesita cambios)
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
            _buildImageContent(),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 12,
                    top: 6, // más arriba dentro del header
                    child: _buildCircularTopButton(
                      icon: Icons.arrow_back_ios_new,
                      baseIconColor: const Color(0xFF004C3F),
                      onTap: () {},
                      semanticsLabel: 'Atrás',
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 6, // más arriba dentro del header
                    child: _buildCircularTopButton(
                      icon: Icons
                          .notifications_none_outlined, // campana de notificaciones
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
    // ... (Este widget no necesita cambios)
    if (!_imageLoaded) {
      return _buildDefaultBackground();
    }
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
      return _buildDefaultBackground();
    }
  }

  Widget _buildDefaultBackground() {
    // ... (Este widget no necesita cambios)
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

  Widget _buildCircularTopButton({
    // ... (Este widget no necesita cambios)
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
          Color effectiveIconColor = (isHovered || isPressed)
              ? Colors.white
              : baseIconColor;
          return MouseRegion(
            onEnter: (_) => setInnerState(() => isHovered = true),
            onExit: (_) => setInnerState(() => isHovered = false),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              onHighlightChanged: (value) =>
                  setInnerState(() => isPressed = value),
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
                        const BoxShadow(
                          color: Color(0x4000E0A6), // rgba(0,224,166,0.25)
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                        BoxShadow(
                          color: (isHovered || isPressed)
                              ? const Color(0x9900E0A6) // rgba(0,224,1Y66,0.6)
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(
                                      0x2600E0A6,
                                    ), // sombra sutil acorde
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
} // <-- Fin de _MainMenuScreenState

// ======================================================
//  NUEVA PANTALLA AÑADIDA: PDFPage
// ======================================================

class PDFPage extends StatefulWidget {
  final String apiBaseUrl; // Recibe la URL de la API

  const PDFPage({super.key, required this.apiBaseUrl});

  @override
  State<PDFPage> createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  DateTime? fechaInicio;
  DateTime? fechaFin;
  bool cargando = false;
  String? error;

  Future<void> seleccionarFechaInicio() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => fechaInicio = picked);
  }

  Future<void> seleccionarFechaFin() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaFin ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => fechaFin = picked);
  }

  Future<void> generarPDF() async {
    if (fechaInicio == null || fechaFin == null) {
      setState(() => error = "Seleccione ambas fechas primero");
      return;
    }

    if (fechaInicio!.isAfter(fechaFin!)) {
      setState(
        () => error =
            "La fecha de inicio no puede ser posterior a la fecha de fin",
      );
      return;
    }

    setState(() {
      cargando = true;
      error = null;
    });

    // Validar que la URL base no esté vacía
    if (widget.apiBaseUrl.isEmpty) {
      setState(() {
        error = "Error: La URL de la API no está configurada.";
        cargando = false;
      });
      return;
    }

    try {
      // 1. Formatear fechas
      final fInicio = fechaInicio!.toIso8601String().split('T')[0];
      final fFin = fechaFin!.toIso8601String().split('T')[0];

      // 2. Construir URL y llamar a la API (¡usando widget.apiBaseUrl!)
      // Usamos el endpoint 'rango1min' que mencionaste
      final url =
          '${widget.apiBaseUrl}?endpoint=rango1min&fechaInicio=$fInicio&fechaFin=$fFin';

      final response = await Dio().get(url);

      if (response.data == null || response.data['ok'] == false) {
        final apiError =
            response.data?['error']?.toString() ??
            "Error desconocido de la API";
        throw Exception(apiError);
      }

      final List<dynamic> rawDatos = response.data['datos'] ?? [];

      if (rawDatos.length <= 1) {
        // 1 porque la fila 0 son los headers
        setState(() {
          error = "No hay datos en el rango seleccionado";
          cargando = false;
        });
        return;
      }

      final List<List<String>> datosComoTexto = rawDatos.map((fila) {
        return List<String>.from(fila.map((celda) => celda.toString()));
      }).toList();

      // 3. Preparar datos para la tabla
      // Tomamos los encabezados de la fila 0 de la API
      final List<String> headers = datosComoTexto.isNotEmpty
          ? datosComoTexto.first
          : <String>[];
      // Tomamos el resto de las filas
      final dataRows = datosComoTexto.length > 1
          ? datosComoTexto.sublist(1)
          : <List<String>>[];

      if (dataRows.isEmpty) {
        setState(() {
          error = "No hay datos en el rango seleccionado";
          cargando = false;
        });
        return;
      }

      // 4. Construir el documento PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Center(
              child: pw.Text(
                "📄 Reporte de Lecturas",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Desde: $fInicio    Hasta: $fFin",
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 15),
            pw.Table.fromTextArray(
              headers: headers,
              data: dataRows,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
              cellAlignment: pw.Alignment.centerLeft,
              border: pw.TableBorder.all(color: PdfColors.grey),
              cellStyle: const pw.TextStyle(fontSize: 9),
              // Ajusta los anchos de columna automáticamente
              columnWidths: {
                for (var i = 0; i < headers.length; i++)
                  i: const pw.IntrinsicColumnWidth(),
              },
            ),
          ],
        ),
      );

      final bytes = await pdf.save();

      // 5. Guardar y abrir el archivo (diferente para Web y Móvil)
      final fileName = 'Reporte_${fInicio}_a_$fFin.pdf';
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = "${dir.path}/$fileName";
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        await OpenFile.open(filePath); // Abre el PDF
      }
    } catch (e) {
      setState(() => error = "Error generando PDF: $e");
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un tema que coincida con tu app
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generar Reporte PDF"),
        backgroundColor: const Color(0xFF004C3F), // Color de tu app
        elevation: 0,
      ),
      // Usamos el color de fondo de tu MainMenuScreen
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: cargando
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: seleccionarFechaInicio,
                      label: Text(
                        fechaInicio == null
                            ? "Seleccionar fecha inicio"
                            : "Inicio: ${fechaInicio!.toLocal().toIso8601String().split('T')[0]}",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF009E73,
                        ), // Color de tu app
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: seleccionarFechaFin,
                      label: Text(
                        fechaFin == null
                            ? "Seleccionar fecha fin"
                            : "Fin: ${fechaFin!.toLocal().toIso8601String().split('T')[0]}",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF009E73,
                        ), // Color de tu app
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: generarPDF,
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "📄 Descargar Reporte",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF00B7B0,
                        ), // Color de tu app
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        error!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
