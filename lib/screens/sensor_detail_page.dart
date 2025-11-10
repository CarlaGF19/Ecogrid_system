import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_ieee/constants/app_config.dart';

class SensorDetailPage extends StatefulWidget {
  final String esp32Ip;
  final String tipo;
  final String titulo;

  const SensorDetailPage({
    super.key,
    required this.esp32Ip,
    required this.tipo,
    required this.titulo,
  });

  @override
  State<SensorDetailPage> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage> {
  List<double> valores = [];
  double valorActual = 0;
  Timer? timer;
  String? apiBaseUrl;

  @override
  void initState() {
    super.initState();
    _loadApiBaseUrl().then((_) => _leerSensor());
    timer = Timer.periodic(const Duration(seconds: 5), (_) => _leerSensor());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadApiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('api_base_url');
    apiBaseUrl = (saved != null && saved.isNotEmpty)
        ? saved
        : AppConfig.DEFAULT_API_BASE_URL;
  }

  Future<void> _leerSensor() async {
    try {
      if (apiBaseUrl != null && apiBaseUrl!.isNotEmpty) {
        // Modo API (Sheets): consume series para el gráfico (endpoint=history)
        final uri = Uri.parse('$apiBaseUrl?endpoint=history&type=${widget.tipo}&limit=15');
        final response = await http.get(uri).timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> points = (data['points'] ?? []) as List<dynamic>;
          final List<double> serie = points
              .map((p) => ((p['value'] ?? 0) as num).toDouble())
              .toList();

          setState(() {
            valores = serie.length > 15 ? serie.sublist(serie.length - 15) : serie;
            valorActual = valores.isNotEmpty ? valores.last : 0;
          });
        }
      } else {
        // Modo ESP32: consulta por tipo simple
        final response = await http.get(Uri.parse("${widget.esp32Ip}/${widget.tipo}"));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          double valor = 0;

          switch (widget.tipo) {
            case "temperatura":
              valor = (data["temperatura"] ?? 0).toDouble();
              break;
            case "humedad":
              valor = (data["humedad"] ?? 0).toDouble();
              break;
            case "ph":
              valor = (data["ph"] ?? 0).toDouble();
              break;
            case "tds":
              valor = (data["tds"] ?? 0).toDouble();
              break;
          }

          setState(() {
            valorActual = valor;
            valores.add(valor);
            if (valores.length > 15) valores.removeAt(0);
          });
        }
      }
    } catch (e) {
      debugPrint("Error de conexión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Valor actual: ${valorActual.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: valores.isEmpty
                  ? const Center(child: Text("Sin datos aún..."))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 35),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.2),
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
            ),
          ],
        ),
      ),
    );
  }
}
