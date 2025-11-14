import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_detail_screen.dart';
import '../models/image_data.dart';
import '../widgets/bottom_navigation_widget.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  List<ImageData> images = [];
  bool isLoading = false;
  String? esp32Ip;
  // Filtros
  int? selectedDay;
  int? selectedMonth;
  int? selectedYear;
  int? startHour;
  int? endHour;

  // Paleta del Main Menu (aplicada solo en esta pantalla)
  static const Color _darkGreen = Color(0xFF004C3F);      // Títulos, íconos
  static const Color _mintBg = Color(0xFFE6FFF5);          // Fondos suaves
  static const Color _cryptoA = Color(0xFF00E0A6);         // Acento principal
  static const Color _cryptoB = Color(0xFF00B7B0);         // Acento secundario

  @override
  void initState() {
    super.initState();
    _loadEsp32Ip();
    _loadImages();
  }

  Future<void> _loadEsp32Ip() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      esp32Ip = prefs.getString('esp32_ip');
    });
  }

  Future<void> _loadImages() async {
    setState(() {
      isLoading = true;
    });

    // Simulación de carga de imágenes (aquí iría la lógica real)
    await Future.delayed(const Duration(seconds: 1));
    
    // Imágenes de ejemplo
    setState(() {
      images = [
        ImageData(
          id: '1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          size: '1.2 MB',
        ),
        ImageData(
          id: '2',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          size: '980 KB',
        ),
        ImageData(
          id: '3',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          size: '1.5 MB',
        ),
      ];
      isLoading = false;
    });
  }

  // Funcionalidad de captura eliminada según requerimiento

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Galería de Imágenes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _darkGreen,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _darkGreen),
            onPressed: _loadImages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x4D00E0A6)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A00E0A6),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, color: _cryptoA, size: 18),
                      const SizedBox(width: 8),
                      _buildDayDropdown(),
                      _buildMonthDropdown(),
                      _buildYearDropdown(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(Icons.access_time, color: _cryptoA, size: 18),
                      const SizedBox(width: 8),
                      _buildHourDropdown(true),
                      _buildHourDropdown(false),
                      _buildTotalImagesPill(),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _cryptoA),
                          foregroundColor: _cryptoA,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: _resetFilters,
                        child: const Text('Restablecer filtros'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Card grande de estadísticas eliminada por requerimiento
          
          // Grid de imágenes
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: _cryptoA,
                    ),
                  )
                : _filteredImages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay imágenes disponibles',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Conecta tu dispositivo para obtener imágenes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            // Volver al aspecto original para mantener estilo visual
                            childAspectRatio: 0.95,
                          ),
                          itemCount: _filteredImages.length,
                          itemBuilder: (context, index) {
                            final image = _filteredImages[index];
                            return _buildImageCard(image);
                          },
                        ),
                      ),
          ),
        ],
      ),
      // Botón de captura eliminado según requerimiento
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0), // Índice 0 para "Home"
    );
  }

  Widget _buildImageCard(ImageData image) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageDetailScreen(image: image),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen placeholder
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            
            // Información de la imagen
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${_formatShortDate(image.timestamp)} ${_formatLocalHM(image.timestamp)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tooltip(
                      message: 'Descargar',
                      child: IconButton(
                        icon: Icon(Icons.download_rounded, color: _cryptoA, size: 20),
                        onPressed: () => _downloadImage(image),
                        splashRadius: 16,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                      ),
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

  List<ImageData> get _filteredImages {
    return images.where((img) {
      final ts = img.timestamp;
      final dayOk = selectedDay == null || ts.day == selectedDay;
      final monthOk = selectedMonth == null || ts.month == selectedMonth;
      final yearOk = selectedYear == null || ts.year == selectedYear;
      final hourOk = (startHour == null || endHour == null)
          ? true
          : ts.hour >= (startHour ?? 0) && ts.hour <= (endHour ?? 23);
      return dayOk && monthOk && yearOk && hourOk;
    }).toList();
  }

  Widget _buildDayDropdown() {
    final days = List<int>.generate(31, (i) => i + 1);
    return SizedBox(
      width: 80,
      child: DropdownButton<int>(
        isExpanded: true,
        hint: const Text('Día'),
        value: selectedDay,
        items: days
            .map((d) => DropdownMenuItem<int>(value: d, child: Text('$d')))
            .toList(),
        onChanged: (v) => setState(() => selectedDay = v),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    const labels = {
      1: 'Ene', 2: 'Feb', 3: 'Mar', 4: 'Abr', 5: 'May', 6: 'Jun',
      7: 'Jul', 8: 'Ago', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dic',
    };
    return SizedBox(
      width: 90,
      child: DropdownButton<int>(
        isExpanded: true,
        hint: const Text('Mes'),
        value: selectedMonth,
        items: labels.entries
            .map((e) => DropdownMenuItem<int>(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) => setState(() => selectedMonth = v),
      ),
    );
  }

  Widget _buildYearDropdown() {
    final current = DateTime.now().year;
    final years = [current - 1, current, current + 1, current + 2];
    return SizedBox(
      width: 90,
      child: DropdownButton<int>(
        isExpanded: true,
        hint: const Text('Año'),
        value: selectedYear,
        items: years
            .map((y) => DropdownMenuItem<int>(value: y, child: Text('$y')))
            .toList(),
        onChanged: (v) => setState(() => selectedYear = v),
      ),
    );
  }

  Widget _buildHourDropdown(bool isStart) {
    final hours = List<int>.generate(24, (i) => i);
    return SizedBox(
      width: 100,
      child: DropdownButton<int>(
        isExpanded: true,
        hint: Text(isStart ? 'Inicio' : 'Fin'),
        value: isStart ? startHour : endHour,
        items: hours
            .map((h) => DropdownMenuItem<int>(
                  value: h,
                  child: Text('${h.toString().padLeft(2, '0')}:00'),
                ))
            .toList(),
        onChanged: (v) => setState(() {
          if (isStart) {
            startHour = v;
          } else {
            endHour = v;
          }
        }),
      ),
    );
  }

  Widget _buildTotalImagesPill() {
    return SizedBox(
      width: 220,
      height: 44,
      child: Container(
        decoration: BoxDecoration(
          color: _mintBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _cryptoA, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A00E0A6),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.photo_library_outlined, color: _cryptoA, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Total de imágenes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _darkGreen,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _cryptoA),
              ),
              child: Text(
                '${_filteredImages.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _cryptoA,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedDay = null;
      selectedMonth = null;
      selectedYear = null;
      startHour = null;
      endHour = null;
    });
  }

  void _downloadImage(ImageData image) {
    // UI de descarga: en esta fase mostramos confirmación
    _showSnackBar('Imagen descargada con éxito', _cryptoA);
  }

  String _formatExactDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y - $h:$min';
  }

  String _formatShortDate(DateTime dt) {
    final yy = (dt.year % 100).toString().padLeft(2, '0');
    // Día y mes sin ceros a la izquierda para coincidir con "2/11/25"
    return '${dt.day}/${dt.month}/$yy';
  }

  String _formatLocalHM(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Ahora';
    }
  }
}