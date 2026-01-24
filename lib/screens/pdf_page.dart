import 'package:flutter/material.dart';
import 'dart:async';
import '../styles/app_styles.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:dio/dio.dart';
import '../utils/pdf_saver.dart';
import '../utils/platform_detector.dart' as platform;
import 'package:csv/csv.dart';
import '../utils/file_saver.dart';

class PDFPage extends StatefulWidget {
  final String apiBaseUrl; // Recibe la URL de la API

  const PDFPage({super.key, required this.apiBaseUrl});

  // Rango máximo de selección
  static const int maxYear = 2030;
  static DateTime get maxDate => DateTime(maxYear, 12, 31);
  static const List<String> _mesesStatic = <String>[
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  static String formatDateStatic(DateTime d, {bool onlyYear = false}) {
    return onlyYear
        ? d.year.toString()
        : '${_mesesStatic[d.month - 1]} ${d.day} ${d.year}';
  }

  static const String routeName = '/pdf-page';

  // Colores específicos para botones de cancelar y aceptar
  static const Color colorCancelar = Color.fromARGB(
    255,
    220,
    53,
    69,
  ); // Rojo para cancelar
  static const Color colorAceptar = Color.fromARGB(
    255,
    40,
    167,
    69,
  ); // Verde para aceptar
  static void open(BuildContext context, String apiBaseUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PDFPage(apiBaseUrl: apiBaseUrl),
        settings: const RouteSettings(name: routeName),
      ),
    );
  }

  @override
  State<PDFPage> createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  DateTime? fechaInicio;
  DateTime? fechaFin;
  bool cargando = false;
  String? error;
  String _selectedFormat = 'PDF'; // Default format
  static const List<String> _meses = <String>[
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  final Map<String, String> _cacheFecha = {};

  /// Formatea fechas exclusivamente para visualización.
  /// - full: "Mes día año" (p.ej.: "Enero 15 2023")
  /// - year: "YYYY" (p.ej.: "2023")
  String formatDate(DateTime d, {bool onlyYear = false}) {
    final String k = '${d.year}-${d.month}-${d.day}-${onlyYear ? 'y' : 'f'}';
    final String? cached = _cacheFecha[k];
    if (cached != null) return cached;
    final String res = onlyYear
        ? d.year.toString()
        : '${_meses[d.month - 1]} ${d.day} ${d.year}';
    _cacheFecha[k] = res;
    return res;
  }

  bool get _fechasValidas {
    if (fechaInicio == null || fechaFin == null) return false;
    return !fechaInicio!.isAfter(fechaFin!);
  }

  Future<void> seleccionarFechaInicio() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaInicio ?? DateTime.now(),
      firstDate: DateTime(1, 1, 1),
      lastDate: PDFPage.maxDate,
      helpText: '',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        // ignore: unused_local_variable
        final palettePrimary = const Color(0xFF0F6659);
        final paletteDark = const Color(0xFF247E5A);
        // ignore: unused_local_variable
        final paletteAccent = const Color(0xFF63B069);
        final paletteBorder = const Color(0x6698C98D);
        return Dialog(
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0x6698C98D), width: 1),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: const Color.fromARGB(255, 168, 255, 102),
              ),
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.focused) ||
                        states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.pressed)) {
                      return Colors.white;
                    }
                    return Colors
                        .black; // WCAG AA compliance - black text for better contrast
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    // Accept button color (green)
                    Color baseColor = PDFPage.colorAceptar;

                    if (states.contains(WidgetState.pressed)) {
                      return baseColor.withValues(alpha: 0.8);
                    } else if (states.contains(WidgetState.hovered)) {
                      return baseColor.withValues(alpha: 0.9);
                    }
                    return baseColor;
                  }),
                  overlayColor: WidgetStatePropertyAll(
                    PDFPage.colorAceptar.withValues(alpha: 0.1),
                  ),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              datePickerTheme: DatePickerThemeData(
                headerBackgroundColor: const Color.fromARGB(255, 249, 248, 250),
                headerForegroundColor: const Color.fromARGB(255, 32, 164, 111),
                // Encabezado minimalista sin texto ni espaciado adicional
                dayForegroundColor: WidgetStatePropertyAll(Colors.black),
                dayOverlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color.fromARGB(
                      255,
                      252,
                      243,
                      174,
                    ).withValues(alpha: 0.3);
                  }
                  return Colors.transparent;
                }),
                dayShape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                todayForegroundColor: WidgetStatePropertyAll(paletteDark),
                todayBorder: const BorderSide(
                  color: Color(0xFF98C98D),
                  width: 1,
                ),
                rangeSelectionBackgroundColor: const Color.fromARGB(
                  255,
                  32,
                  164,
                  111,
                ).withValues(alpha: 0.15),
                rangeSelectionOverlayColor: WidgetStatePropertyAll(
                  const Color.fromARGB(
                    255,
                    32,
                    164,
                    111,
                  ).withValues(alpha: 0.08),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: paletteBorder),
                ),
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
            child: ConstrainedBox(
              //box
              constraints: const BoxConstraints(maxWidth: 320, maxHeight: 500),
              child: child!,
            ),
          ),
        );
      },
    );
    if (picked != null) setState(() => fechaInicio = picked);
  }

  Future<void> seleccionarFechaFin() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaFin ?? DateTime.now(),
      firstDate: DateTime(1, 1, 1),
      lastDate: PDFPage.maxDate,
      helpText: '',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        // ignore: unused_local_variable
        final palettePrimary = const Color(0xFF0F6659);
        // ignore: unused_local_variable
        final paletteDark = const Color(0xFF247E5A);
        // ignore: unused_local_variable
        final paletteAccent = const Color(0xFF63B069);
        final paletteBorder = const Color(0x6698C98D);
        return Dialog(
          backgroundColor: const Color.fromARGB(
            255,
            255,
            255,
            255,
          ).withValues(alpha: 0.12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0x6698C98D), width: 1),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: const Color.fromARGB(255, 168, 255, 102),
              ),
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.focused) ||
                        states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.pressed)) {
                      return Colors.white;
                    }
                    return Colors
                        .black; // WCAG AA compliance - black text for better contrast
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    // Accept button color (green)
                    Color baseColor = PDFPage.colorAceptar;

                    if (states.contains(WidgetState.pressed)) {
                      return baseColor.withValues(alpha: 0.8);
                    } else if (states.contains(WidgetState.hovered)) {
                      return baseColor.withValues(alpha: 0.9);
                    }
                    return baseColor;
                  }),
                  overlayColor: WidgetStatePropertyAll(
                    PDFPage.colorAceptar.withValues(alpha: 0.1),
                  ),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              datePickerTheme: DatePickerThemeData(
                headerBackgroundColor: const Color.fromARGB(255, 249, 248, 250),
                headerForegroundColor: const Color.fromARGB(255, 32, 164, 111),
                // Encabezado minimalista sin texto ni padding adicional
                dayForegroundColor: WidgetStatePropertyAll(Colors.black),
                dayOverlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color.fromARGB(
                      255,
                      253,
                      254,
                      189,
                    ).withValues(alpha: 0.3);
                  }
                  return Colors.transparent;
                }),
                dayShape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                todayForegroundColor: WidgetStatePropertyAll(paletteDark),
                todayBorder: const BorderSide(
                  color: Color(0xFF98C98D),
                  width: 1,
                ),
                rangeSelectionBackgroundColor: const Color.fromARGB(
                  255,
                  32,
                  164,
                  111,
                ).withValues(alpha: 0.15),
                rangeSelectionOverlayColor: WidgetStatePropertyAll(
                  const Color.fromARGB(
                    255,
                    32,
                    164,
                    111,
                  ).withValues(alpha: 0.08),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: paletteBorder),
                ),
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320, maxHeight: 500),
              child: child!,
            ),
          ),
        );
      },
    );
    if (picked != null) setState(() => fechaFin = picked);
  }

  Future<void> _generarYCompartirCSV({
    required List<Map<String, dynamic>> data,
    required String fileName,
  }) async {
    if (data.isEmpty) {
      throw Exception('No hay datos para exportar');
    }

    final headers = data.first.keys.toList();
    final rows = <List<dynamic>>[];

    rows.add(headers);

    for (final item in data) {
      rows.add(headers.map((h) => item[h]).toList());
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csvString);

    await saveFile(
      // ignore: unnecessary_cast
      bytes as dynamic,
      fileName,
      'text/csv',
    );
  }

  Future<void> generarReporte() async {
    if (!_fechasValidas) {
      setState(
        () => error = fechaInicio == null || fechaFin == null
            ? "Seleccione ambas fechas primero"
            : "La fecha de inicio no puede ser posterior a la fecha de fin",
      );
      return;
    }

    // Validar que la URL base no esté vacía
    if (widget.apiBaseUrl.isEmpty) {
      setState(() {
        error = "Error: La URL de la API no está configurada.";
      });
      return;
    }

    setState(() {
      cargando = true;
      error = null;
    });

    try {
      // 1. Formatear fechas
      final fInicio = fechaInicio!.toIso8601String().split('T')[0];
      final fFin = fechaFin!.toIso8601String().split('T')[0];

      // 2. Construir URL y llamar a la API
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

      // Procesar datos según el formato seleccionado
      if (_selectedFormat == 'CSV') {
        // Convertir rawDatos (List<List>) a List<Map<String, dynamic>>
        final List<String> headers = List<String>.from(
          rawDatos[0].map((e) => e.toString()),
        );
        final List<Map<String, dynamic>> mappedData = [];

        for (int i = 1; i < rawDatos.length; i++) {
          final row = rawDatos[i];
          final Map<String, dynamic> rowMap = {};
          // Asegurar que no accedemos fuera de rango si la fila está incompleta
          for (int j = 0; j < headers.length && j < row.length; j++) {
            rowMap[headers[j]] = row[j];
          }
          mappedData.add(rowMap);
        }

        await _generarYCompartirCSV(
          data: mappedData,
          fileName: 'Reporte_${fInicio}_a_$fFin.csv',
        );
      } else {
        // Lógica PDF existente
        final List<List<String>> datosComoTexto = rawDatos.map((fila) {
          return List<String>.from(fila.map((celda) => celda.toString()));
        }).toList();

        // 3. Preparar datos para la tabla
        final List<String> headers = datosComoTexto.isNotEmpty
            ? datosComoTexto.first
            : <String>[];
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
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: dataRows,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.green,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(color: PdfColors.grey),
                cellStyle: const pw.TextStyle(fontSize: 9),
                columnWidths: {
                  for (var i = 0; i < headers.length; i++)
                    i: const pw.IntrinsicColumnWidth(),
                },
              ),
            ],
          ),
        );

        final bytes = await pdf.save();
        final fileName = 'Reporte_${fInicio}_a_$fFin.pdf';
        await savePdf(bytes, fileName);
      }
    } catch (e) {
      setState(() => error = "Error generando reporte: $e");
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Paleta de colores verdes extraída del menú principal
    const Color verdePrincipal = Color(0xFF43A047); // Verde 600 - Sensores
    const Color verdeOscuro = Color(0xFF2E7D32); // Verde 800 - Galería
    const Color verdeClaro = Color(0xFF66BB6A); // Verde 400 - para hover
    const Color verdeSombra = Color(0xFF4CAF50); // Verde 500 - para sombras

    return Scaffold(
      body: Container(
        decoration: AppStyles.internalScreenBackground,
        child: Column(
          children: [
            // Header con diseño consistente al Main Menu
            _buildPDFHeader(),

            // Contenido principal
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isSmall = constraints.maxWidth < 480;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Espaciador superior
                      const SizedBox(height: 24),

                      // Contenedor principal centrado con diseño verde
                      Container(
                        width: math.min(constraints.maxWidth * 0.9, 800),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.all(isSmall ? 20 : 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: verdeSombra.withValues(alpha: 0.15),
                              spreadRadius: 2,
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: verdeClaro.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Contenedor de botones con estilo verde
                            cargando
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      verdePrincipal,
                                    ),
                                  )
                                : Column(
                                    children: [
                                      _ButtonContainer(
                                        children: [
                                          _StyledButton(
                                            label: fechaInicio == null
                                                ? 'Fecha de Inicio'
                                                : '${fechaInicio!.year.toString().padLeft(4, '0')}-${fechaInicio!.month.toString().padLeft(2, '0')}-${fechaInicio!.day.toString().padLeft(2, '0')}',
                                            onTap: seleccionarFechaInicio,
                                            key: const ValueKey(
                                              'btn-start-date',
                                            ),
                                            semanticLabel:
                                                'Seleccionar fecha inicio',
                                            icon: Icons.calendar_today,
                                            enabled: !platform.isAndroidWeb(),
                                          ),
                                          _StyledButton(
                                            label: fechaFin == null
                                                ? 'Fecha de Fin'
                                                : '${fechaFin!.year.toString().padLeft(4, '0')}-${fechaFin!.month.toString().padLeft(2, '0')}-${fechaFin!.day.toString().padLeft(2, '0')}',
                                            onTap: seleccionarFechaFin,
                                            key: const ValueKey('btn-end-date'),
                                            semanticLabel:
                                                'Seleccionar fecha fin',
                                            icon: Icons.calendar_today,
                                            enabled: !platform.isAndroidWeb(),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 24),

                                      // Selector de Formato
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Formato de reporte',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: verdeOscuro,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => setState(
                                                  () => _selectedFormat = 'PDF',
                                                ),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        _selectedFormat == 'PDF'
                                                        ? verdePrincipal
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          _selectedFormat ==
                                                              'PDF'
                                                          ? verdePrincipal
                                                          : verdeClaro,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.picture_as_pdf,
                                                        color:
                                                            _selectedFormat ==
                                                                'PDF'
                                                            ? Colors.white
                                                            : verdePrincipal,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'PDF',
                                                        style: TextStyle(
                                                          color:
                                                              _selectedFormat ==
                                                                  'PDF'
                                                              ? Colors.white
                                                              : verdePrincipal,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => setState(
                                                  () => _selectedFormat = 'CSV',
                                                ),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        _selectedFormat == 'CSV'
                                                        ? verdePrincipal
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          _selectedFormat ==
                                                              'CSV'
                                                          ? verdePrincipal
                                                          : verdeClaro,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.table_chart,
                                                        color:
                                                            _selectedFormat ==
                                                                'CSV'
                                                            ? Colors.white
                                                            : verdePrincipal,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'CSV',
                                                        style: TextStyle(
                                                          color:
                                                              _selectedFormat ==
                                                                  'CSV'
                                                              ? Colors.white
                                                              : verdePrincipal,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 20,
                                          top: 8,
                                          bottom: 24,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            _selectedFormat == 'PDF'
                                                ? 'Ideal para imprimir y compartir'
                                                : 'Ideal para Excel y análisis',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Botón CTA Descargar
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        width: double.infinity,
                                        child: _StyledButton(
                                          label: 'Descargar',
                                          onTap: _fechasValidas
                                              ? generarReporte
                                              : null,
                                          key: const ValueKey('btn-download'),
                                          semanticLabel: 'Descargar Reporte',
                                          enabled:
                                              _fechasValidas &&
                                              !platform.isAndroidWeb(),
                                          icon: Icons.download,
                                        ),
                                      ),

                                      if (error != null) ...[
                                        const SizedBox(height: 20),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.red.shade200,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red.shade600,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  error!,
                                                  style: TextStyle(
                                                    color: Colors.red.shade700,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                          ],
                        ),
                      ),

                      // Espaciador inferior flexible
                      const Spacer(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header consistente con el diseño del Main Menu
  Widget _buildPDFHeader() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      height: (screenHeight * 0.37), // 37% de la pantalla como en Main Menu
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
            // Fondo con imagen del Main Menu
            _buildPDFHeaderBackground(),
            SafeArea(
              child: Stack(
                children: [
                  // Flecha de retroceso alineada a la izquierda
                  Positioned(
                    left: 12,
                    top: 6,
                    child: _buildCircularTopButton(
                      icon: Icons.arrow_back_ios_new,
                      baseIconColor: const Color(0xFF004C3F),
                      onTap: () => Navigator.of(context).pop(),
                      semanticsLabel: 'Atrás',
                    ),
                  ),
                  // Título centrado horizontalmente (solo fondo, sin texto)
                  const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fondo del header con la misma imagen del Main Menu
  Widget _buildPDFHeaderBackground() {
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

  /// Botón circular superior consistente con Main Menu
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
                      color: Colors.white.withValues(alpha: 0.35),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0x4000E0A6),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                        BoxShadow(
                          color: (isHovered || isPressed)
                              ? const Color(0x9900E0A6)
                              : const Color(0x3300E0A6),
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
                                    color: Color(0x2600E0A6),
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

/// Nuevo contenedor de botones con diseño moderno según especificaciones
class _ButtonContainer extends StatelessWidget {
  final List<Widget> children;

  const _ButtonContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 480;
        final bool isMediumScreen = constraints.maxWidth < 768;

        // Paleta de colores verdes del menú principal
        const Color verdePrincipal = Color(0xFF43A047); // Verde 600 - Sensores
        const Color verdeClaro = Color(0xFF66BB6A); // Verde 400 - para hover

        // Ancho del contenedor: 80% con máximo de 600px
        final double containerWidth = isMediumScreen
            ? constraints.maxWidth * 0.95
            : math.min(constraints.maxWidth * 0.8, 600);

        return Container(
          width: containerWidth,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Bordes más redondeados
            boxShadow: [
              BoxShadow(
                color: verdePrincipal.withValues(alpha: 0.15),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: verdeClaro.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: isSmallScreen
              ? Column(
                  children:
                      children
                          .map(
                            (child) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SizedBox(
                                width: double.infinity,
                                child: child,
                              ),
                            ),
                          )
                          .toList()
                        ..last = Padding(
                          padding: EdgeInsets.zero,
                          child: SizedBox(
                            width: double.infinity,
                            child: children.last,
                          ),
                        ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      children
                          .map(
                            (child) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: child,
                              ),
                            ),
                          )
                          .toList()
                        ..last = Expanded(
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: children.last,
                          ),
                        ),
                ),
        );
      },
    );
  }
}

/// Nuevo botón estilizado con paleta de colores verdes del menú principal
class _StyledButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final String semanticLabel;
  final IconData? icon;
  final bool enabled;

  const _StyledButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.semanticLabel,
    this.icon,
    required this.enabled,
  });

  @override
  State<_StyledButton> createState() => _StyledButtonState();
}

class _StyledButtonState extends State<_StyledButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Paleta de colores verdes del menú principal
    const Color verdePrincipal = Color(0xFF43A047); // Verde 600 - Sensores
    const Color verdeOscuro = Color(0xFF2E7D32); // Verde 800 - Galería
    const Color verdeClaro = Color(0xFF66BB6A); // Verde 400 - para hover

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: widget.enabled,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ), // Transición suave 0.2s
            curve: Curves.ease,
            height: 40, // Altura uniforme de 40px
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? (_isHovered
                        ? verdeClaro // Color verde claro en hover
                        : verdePrincipal) // Color verde principal normal
                  : verdePrincipal.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(
                6,
              ), // Bordes redondeados de 6px
              border: Border.all(
                color: widget.enabled
                    ? (_isHovered
                          ? verdeOscuro // Color verde oscuro en hover
                          : verdePrincipal.withValues(
                              alpha: 0.8,
                            )) // Color verde normal
                    : verdePrincipal.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered && widget.enabled
                      ? verdePrincipal.withValues(alpha: 0.3)
                      : Colors.transparent,
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 16,
                    color: widget.enabled
                        ? Colors
                              .white // Iconos en blanco para contraste
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14, // Tamaño de fuente 14px
                    fontWeight: FontWeight.w600, // Peso semibold (600)
                    color: widget.enabled
                        ? Colors
                              .white // Texto en blanco para mejor contraste
                        : Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InteractiveRectButton extends StatefulWidget {
  final double width;
  final double aspectRatio; // width:height
  final double radius;
  final Color baseColor;
  final Color hoverColor;
  final bool enabled;
  final String label;
  final String semanticLabel;
  final VoidCallback? onTap;
  final IconData? icon;
  final EdgeInsets contentPadding;

  const _InteractiveRectButton({
    super.key,
    required this.width,
    required this.aspectRatio,
    required this.radius,
    required this.baseColor,
    required this.hoverColor,
    required this.enabled,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    this.icon,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
  });

  @override
  State<_InteractiveRectButton> createState() => _InteractiveRectButtonState();
}

class _InteractiveRectButtonState extends State<_InteractiveRectButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color bg = !_hover ? widget.baseColor : widget.hoverColor;
    final Color bgDisabled = widget.baseColor.withValues(alpha: 0.6);
    final Color fg = Colors.white;

    final boxShadow =
        const <BoxShadow>[]; // Sin sombreado para bloques delgados

    final child = Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: widget.enabled,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: widget.width,
              decoration: BoxDecoration(
                color: widget.enabled ? bg : bgDisabled,
                borderRadius: BorderRadius.circular(widget.radius),
                boxShadow: boxShadow,
                border: Border.all(color: const Color(0xFF98C98D), width: 1),
              ),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: Center(
                  child: Padding(
                    padding: widget.contentPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: fg, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Builder(
                          builder: (context) {
                            final scaler = MediaQuery.of(context).textScaler;
                            final base = 16.0;
                            final fs = scaler.scale(base).clamp(12.0, 18.0);
                            return Text(
                              widget.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: fs,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return child;
  }
}
