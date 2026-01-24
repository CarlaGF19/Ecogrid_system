import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/connection_manager.dart';
import '../services/lifecycle_manager.dart';
import '../components/connection_status.dart';
import '../styles/app_styles.dart';

class SensorDetailPage extends StatefulWidget {
  final String? esp32Ip;
  final String tipo;
  final String titulo;

  const SensorDetailPage({
    super.key,
    this.esp32Ip,
    required this.tipo,
    required this.titulo,
  });

  @override
  State<SensorDetailPage> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage>
    with WidgetsBindingObserver {
  // --- VARIABLES DE ESTADO ---
  List<double> valores = []; // Para el gráfico
  Timer? timer;
  String? apiBaseUrl;

  // Nuevas variables de estado
  bool _isRefreshing = false; // Para el botón de actualizar

  // Variables para la "Última Lectura"
  double _ultimoValor = 0.0;
  String _ultimaFecha = "";
  String _ultimaHora = "";

  // Connection Manager for automatic updates
  late ConnectionManager _connectionManager;
  DateTime? _lastAutoUpdate;

  final String _defaultApiUrl =
      "https://script.google.com/macros/s/AKfycbygUivdTGdLb_2p7f80TAJiwm_elb7FfXvyIJn_ID-BYhedUWjOQs1Sqk2rmubtn80N/exec";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeConnectionManager();
    _loadApiBaseUrl().then(
      (_) => _actualizarDatos(),
    ); // Llama a la nueva función
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionManager.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadApiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('api_base_url');
    apiBaseUrl = (saved != null && saved.isNotEmpty) ? saved : _defaultApiUrl;
  }

  // Initialize connection manager for automatic updates
  Future<void> _initializeConnectionManager() async {
    await _loadApiBaseUrl();

    _connectionManager = ConnectionManager();

    // Listen to connection status changes
    _connectionManager.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          // Update UI based on connection status if needed
        });
      }
    });

    // Listen to data updates
    _connectionManager.dataStream.listen((data) {
      _handleAutomaticDataUpdate(data);
    });

    // Initialize connection
    await _connectionManager.initialize(
      apiBaseUrl: apiBaseUrl,
      esp32Ip: widget.esp32Ip,
      sensorType: widget.tipo,
      updateInterval: const Duration(seconds: 58),
      respectLifecycle: true, // Enable battery optimization
    );
  }

  // Handle automatic data updates from connection manager
  void _handleAutomaticDataUpdate(Map<String, dynamic> data) {
    debugPrint('=== AUTOMATIC DATA UPDATE RECEIVED ===');
    debugPrint('Data: $data');

    setState(() {
      _lastAutoUpdate = DateTime.now();

      // Update sensor values based on data source
      if (data['source'] == 'esp32') {
        // ESP32 direct data
        double valor = (data['value'] ?? 0).toDouble();
        _ultimoValor = valor;
        _ultimaFecha = "";
        _ultimaHora = "";

        // Update chart data
        valores.add(valor);
        if (valores.length > 15) valores.removeAt(0);
      } else {
        // API data (Google Sheets)
        _updateSensorValuesFromApi(data);
      }
    });
  }

  // App lifecycle handling for battery optimization
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('App resumed - restarting automatic updates');
        // Notify lifecycle manager
        LifecycleManager().onAppResumed();
        // Refresh connection
        _connectionManager.refresh();
        break;
      case AppLifecycleState.paused:
        debugPrint('App paused - reducing update frequency');
        // Notify lifecycle manager
        LifecycleManager().onAppPaused();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Handle other states if needed
        break;
    }
  }

  // --- LÓGICA DE ACTUALIZACIÓN DE DATOS ---

  // Nueva función que se encarga de actualizar todo
  Future<void> _actualizarDatos({bool isManualRefresh = false}) async {
    // Use connection manager for automatic updates, fallback to manual for compatibility
    if (!isManualRefresh && _connectionManager.isConnected) {
      // Automatic updates are handled by connection manager
      return;
    }

    // Manual refresh or fallback logic
    // Si ya está actualizando, no hace nada
    if (_isRefreshing) return;

    // Solo muestra el indicador si es refrescado manual
    if (isManualRefresh) {
      setState(() => _isRefreshing = true);
    }

    try {
      debugPrint("=== INICIANDO ACTUALIZACIÓN DE DATOS ===");
      debugPrint("API Base URL: $apiBaseUrl");
      debugPrint("ESP32 IP: ${widget.esp32Ip}");
      debugPrint("Tipo sensor: ${widget.tipo}");

      if (apiBaseUrl != null && apiBaseUrl!.isNotEmpty) {
        debugPrint("MODO: API Google Sheets");
        await Future.wait([_fetchApiHistory(), _fetchApiLastReading()]);
      } else {
        if (widget.esp32Ip != null && widget.esp32Ip!.isNotEmpty) {
          debugPrint("MODO: ESP32 Directo");
          await _fetchEsp32Reading();
        } else {
          debugPrint("ERROR: No hay configuración de conexión");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No hay conexión configurada. Configure IP o API URL.',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error actualizando datos: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
      }
    }

    if (isManualRefresh && mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  // Obtiene el historial para el GRÁFICO (endpoint=history)
  Future<void> _fetchApiHistory() async {
    try {
      debugPrint("=== FETCH API HISTORY ===");
      final List<String> tipos = widget.tipo == 'humedad'
          ? <String>['humedadAmbiente', 'humedad']
          : <String>[widget.tipo];

      List<double> serie = [];
      for (final t in tipos) {
        final uri = Uri.parse('$apiBaseUrl?endpoint=history&type=$t&limit=15');
        debugPrint('Solicitando historial: $uri');

        try {
          final response = await http
              .get(uri)
              .timeout(const Duration(seconds: 10));

          debugPrint('Respuesta historial: Status ${response.statusCode}');
          debugPrint(
            'Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            debugPrint('Datos decodificados: $data');

            final List<dynamic> points =
                (data['points'] ?? []) as List<dynamic>;
            debugPrint('Puntos encontrados: ${points.length}');

            if (points.isNotEmpty) {
              serie = points
                  .map((p) => ((p['value'] ?? 0) as num).toDouble())
                  .where((v) => v.isFinite)
                  .toList();
              debugPrint('Serie generada: $serie');
              break;
            } else {
              debugPrint('ADVERTENCIA: No hay puntos de datos para $t');
            }
          } else {
            debugPrint('ERROR: Historial $t respondió ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('ERROR en solicitud $t: $e');
        }
      }

      debugPrint('Valores finales del gráfico: $serie');

      if (mounted) {
        setState(() {
          valores = serie;
        });
      }
    } catch (e) {
      debugPrint("Error en _fetchApiHistory: $e");
    }
  }

  // Obtiene la ÚLTIMA LECTURA con fecha y hora (endpoint=last1min)
  Future<void> _fetchApiLastReading() async {
    try {
      final uri = Uri.parse('$apiBaseUrl?endpoint=last1min');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['fecha'] == null) return; // Respuesta inválida

        double tempValor = 0.0;
        // El script devuelve TODOS los sensores, usamos widget.tipo para elegir
        switch (widget.tipo) {
          case "temperatura":
            tempValor = (data["temperatura"] ?? 0).toDouble();
            break;
          case "humedad": // Mapea al nombre de tu script
            tempValor = (data["humedadAmbiente"] ?? 0).toDouble();
            break;
          case "humedadSuelo":
            tempValor = (data["humedadSuelo"] ?? 0).toDouble();
            break;
          case "ph":
            tempValor = (data["ph"] ?? 0).toDouble();
            break;
          case "tds":
            tempValor = (data["tds"] ?? 0).toDouble();
            break;
          case "uv":
            tempValor = (data["uv"] ?? 0).toDouble();
            break;
        }

        if (mounted) {
          setState(() {
            _ultimoValor = tempValor;
            _ultimaFecha = data['fecha'];
            _ultimaHora = data['hora'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error en _fetchApiLastReading: $e");
    }
  }

  // Update sensor values from API data
  void _updateSensorValuesFromApi(Map<String, dynamic> data) {
    if (data['fecha'] == null) return;

    double tempValor = 0.0;
    switch (widget.tipo) {
      case "temperatura":
        tempValor = (data["temperatura"] ?? 0).toDouble();
        break;
      case "humedad":
        tempValor = (data["humedadAmbiente"] ?? 0).toDouble();
        break;
      case "humedadSuelo":
        tempValor = (data["humedadSuelo"] ?? 0).toDouble();
        break;
      case "ph":
        tempValor = (data["ph"] ?? 0).toDouble();
        break;
      case "tds":
        tempValor = (data["tds"] ?? 0).toDouble();
        break;
      case "uv":
        tempValor = (data["uv"] ?? 0).toDouble();
        break;
    }

    _ultimoValor = tempValor;
    _ultimaFecha = data['fecha'] ?? "";
    _ultimaHora = data['hora'] ?? "";
  }

  // Lógica original para MODO ESP32
  Future<void> _fetchEsp32Reading() async {
    try {
      debugPrint("=== FETCH ESP32 DIRECTO ===");
      final url = "${widget.esp32Ip}/${widget.tipo}";
      debugPrint('Solicitando a ESP32: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      debugPrint('Respuesta ESP32: Status ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Datos ESP32 decodificados: $data');

        double valor = 0;
        switch (widget.tipo) {
          case "temperatura":
            valor = (data["temperatura"] ?? 0).toDouble();
            break;
          case "humedad":
            valor = (data["humedad"] ?? data["humedadAmbiente"] ?? 0)
                .toDouble();
            break;
          case "ph":
            valor = (data["ph"] ?? 0).toDouble();
            break;
          case "tds":
            valor = (data["tds"] ?? 0).toDouble();
            break;
          case "uv":
            valor = (data["uv"] ?? 0).toDouble();
            break;
        }

        debugPrint('Valor extraído: $valor');

        if (mounted) {
          setState(() {
            _ultimoValor = valor; // Actualiza el valor
            _ultimaFecha = ""; // Modo ESP no da fecha/hora
            _ultimaHora = "";
            valores.add(valor); // Actualiza el gráfico
            if (valores.length > 15) valores.removeAt(0);
          });

          debugPrint('Estado actualizado - valores: $valores');
        }
      } else {
        debugPrint('ERROR: ESP32 respondió con status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error en _fetchEsp32Reading: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error conectando a ESP32: $e')));
      }
    }
  }

  // Devuelve las unidades correctas para cada sensor
  String _getUnits() {
    switch (widget.tipo) {
      case "temperatura":
        return "°C";
      case "humedad":
      case "humedadSuelo":
        return "%";
      case "ph":
        return " pH";
      case "tds":
        return " ppm";
      default:
        return "";
    }
  }

  // Formatea el tiempo transcurrido para mostrar en la UI
  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ${difference.inSeconds % 60}s';
    } else {
      return '${difference.inSeconds}s';
    }
  }

  // --- CONSTRUCCIÓN DE LA INTERFAZ (WIDGETS) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.titulo),
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ConnectionStatusIndicator(
              connectionManager: _connectionManager,
              onRefresh: () => _actualizarDatos(isManualRefresh: true),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: AppStyles.internalScreenBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. NUEVA SECCIÓN DE ÚLTIMA LECTURA
                _buildLastReadingDisplay(),

                const SizedBox(height: 20),

                // 2. GRÁFICO EN TAMAÑO FIJO (1/4 de pantalla aprox)
                _buildChartDisplay(),

                // Empuja el botón al fondo
                const Spacer(),

                // 3. BOTÓN DE ACTUALIZAR
                _buildRefreshButton(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para la tarjeta de última lectura
  Widget _buildLastReadingDisplay() {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ÚLTIMA LECTURA", style: AppStyles.sectionSubtitle),
            const SizedBox(height: 10),
            // Valor grande
            Text(
              "${_ultimoValor.toStringAsFixed(2)}${_getUnits()}",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            // Muestra fecha y hora con estado de actualización automática
            if (_ultimaFecha.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Fecha: $_ultimaFecha"),
                  Text("Hora: $_ultimaHora"),
                ],
              )
            else if (_isRefreshing)
              Text("Buscando datos...")
            else if (_lastAutoUpdate != null)
              Text("Auto-actualizado: ${_formatTimeAgo(_lastAutoUpdate!)}")
            else
              Text("Actualizado en tiempo real"),
          ],
        ),
      ),
    );
  }

  // Widget para el gráfico
  Widget _buildChartDisplay() {
    return SizedBox(
      height: 200, // Altura fija (aprox 1/4 de pantalla)
      child: valores.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.show_chart, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text("Sin datos para mostrar"),
                  const SizedBox(height: 4),
                  Text(
                    "Esperando conexión...",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                minY: widget.tipo == 'humedad' ? 0 : null,
                maxY: widget.tipo == 'humedad' ? 100 : null,
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withValues(alpha: 0.2),
                    ),
                    dotData: const FlDotData(show: true),
                    spots: [
                      for (int i = 0; i < valores.length; i++)
                        FlSpot(i.toDouble(), valores[i]),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // Widget para el botón de actualizar
  Widget _buildRefreshButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: _isRefreshing
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(Icons.refresh),
        label: const Text("ACTUALIZAR"),
        onPressed: _isRefreshing
            ? null
            : () async {
                setState(() => _isRefreshing = true);
                await _connectionManager.refresh();
                await _actualizarDatos(isManualRefresh: true);
                if (mounted) {
                  setState(() => _isRefreshing = false);
                }
              },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
