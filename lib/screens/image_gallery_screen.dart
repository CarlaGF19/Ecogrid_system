import 'dart:ui';
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
  DateTime? _selectedDate;
  int? startHour;
  int? endHour;

  // Paleta Eco-Corporate (MANDATORY)
  static const Color _bgTop = Color(0xFFFFFFFF);
  static const Color _bgBottom = Color(0xFFF1FBF9);
  static const Color _textHeader = Color(0xFF004C3F);
  static const Color _primaryMint = Color(0xFF00E0A6);
  static const Color _textLabel = Color(
    0xFF004C3F,
  ); // 60% opacity applied in usage
  static const Color _shadowEco = Color(
    0x26004C3F,
  ); // #2600A078 aprox (using dark forest at low opacity)

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

    // Simulación de carga
    await Future.delayed(const Duration(seconds: 1));

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
        ImageData(
          id: '4',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          size: '2.1 MB',
        ),
        ImageData(
          id: '5',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          size: '1.8 MB',
        ),
      ];
      isLoading = false;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedDate = null;
      startHour = null;
      endHour = null;
    });
  }

  List<ImageData> get _filteredImages {
    return images.where((img) {
      final ts = img.timestamp;

      // Date Filter (Single Day)
      bool dateOk = true;
      if (_selectedDate != null) {
        dateOk =
            ts.year == _selectedDate!.year &&
            ts.month == _selectedDate!.month &&
            ts.day == _selectedDate!.day;
      }

      // Time Range Filter
      final hourOk = (startHour == null || endHour == null)
          ? true
          : ts.hour >= (startHour ?? 0) && ts.hour <= (endHour ?? 23);

      return dateOk && hourOk;
    }).toList();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _textHeader,
              onPrimary: Colors.white,
              onSurface: _textHeader,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // For glassmorphism bottom nav if needed
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 🧱 HEADER SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Panel de Datos\nAnalíticos',
                  style: TextStyle(
                    fontFamily: 'Inter', // Fallback to system if not avail
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _textHeader,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✨ FILTER PANEL (GLASSMORPHISM)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.35,
                        ), // 35% opacity
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: _shadowEco,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // 1. Date Picker
                            _buildCapsuleInput(
                              icon: Icons.calendar_today_rounded,
                              label: _selectedDate == null
                                  ? 'Fecha'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              onTap: _pickDate,
                              isActive: _selectedDate != null,
                              width: 130,
                            ),
                            const SizedBox(width: 8),

                            // 2. Start Time
                            _buildDropdownCapsule(
                              icon: Icons.access_time_rounded,
                              label: 'Inicio',
                              value: startHour,
                              onChanged: (v) => setState(() => startHour = v),
                              width: 100,
                            ),
                            const SizedBox(width: 8),

                            // 3. End Time
                            _buildDropdownCapsule(
                              icon: Icons.schedule_rounded,
                              label: 'Fin',
                              value: endHour,
                              onChanged: (v) => setState(() => endHour = v),
                              width: 100,
                            ),
                            const SizedBox(width: 8),

                            // 4. Reset Button (Compact)
                            _buildResetButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 📊 CENTRAL SECTION — SUMMARY BADGE
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryMint,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryMint.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Total: ${_filteredImages.length} imágenes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🖼️ CONTENT SECTION — IMAGE GRID
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _primaryMint),
                      )
                    : _filteredImages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: _textHeader.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron resultados',
                              style: TextStyle(
                                color: _textHeader.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          100,
                        ), // Bottom padding for nav bar
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: _filteredImages.length,
                        itemBuilder: (context, index) {
                          return _buildImageCard(_filteredImages[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 2),
    );
  }

  Widget _buildCapsuleInput({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    double? width,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: width,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isActive ? _primaryMint : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _primaryMint, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: _textLabel.withValues(alpha: isActive ? 1.0 : 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCapsule({
    required IconData icon,
    required String label,
    required int? value,
    required ValueChanged<int?> onChanged,
    double? width,
  }) {
    return Container(
      width: width,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: value != null ? _primaryMint : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _primaryMint, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                hint: Text(
                  label,
                  style: TextStyle(
                    color: _textLabel.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                icon: const SizedBox.shrink(), // Hide default icon
                isExpanded: true,
                style: TextStyle(
                  color: _textLabel,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
                items: List.generate(24, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text('${index.toString().padLeft(2, '0')}:00'),
                  );
                }),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    final hasFilters =
        _selectedDate != null || startHour != null || endHour != null;

    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: hasFilters ? 1.0 : 0.5,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasFilters ? _resetFilters : null,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: hasFilters
                    ? _primaryMint.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: hasFilters
                      ? _primaryMint
                      : _textHeader.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.filter_alt_off_rounded,
                    color: hasFilters
                        ? _primaryMint
                        : _textHeader.withValues(alpha: 0.5),
                    size: 18,
                  ),
                  if (hasFilters) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Limpiar',
                      style: TextStyle(
                        color: _primaryMint,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(ImageData image) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: _shadowEco, blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Placeholder
            Expanded(
              child: Container(
                color: Colors.grey.withValues(alpha: 0.1),
                child: Center(
                  child: Icon(
                    Icons.image_rounded,
                    size: 48,
                    color: _primaryMint.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${image.timestamp.hour}:${image.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: _textLabel.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: () => _downloadImage(image),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.file_download_outlined,
                        color: _primaryMint,
                        size: 20,
                      ),
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

  void _downloadImage(ImageData image) {
    _showSnackBar('Imagen descargada', _primaryMint);
  }
}
