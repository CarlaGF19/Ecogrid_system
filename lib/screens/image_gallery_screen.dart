import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_detail_screen.dart';
import '../models/image_data.dart';
import '../styles/app_styles.dart';
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
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  // Paleta Eco-Corporate (MANDATORY)
  static const Color _bgTop = Color(0xFFFFFFFF);
  static const Color _bgBottom = Color(0xFFF1FBF9);
  static const Color _textHeader = Color(0xFF004C3F);
  static const Color _primaryMint = Color(0xFF00E0A6);
  static const Color _textLabel = Color(
    0xFF004C3F,
  ); // 60% opacity applied in usage
  static const Color _shadowEco = Color(0x2600A078); // Eco Shadow (Mint-ish)

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
      _startDate = null;
      _endDate = null;
      _startTime = const TimeOfDay(hour: 18, minute: 0);
      _endTime = const TimeOfDay(hour: 22, minute: 0);
    });
  }

  List<ImageData> get _filteredImages {
    return images.where((img) {
      final ts = img.timestamp;

      // Date Range Filter
      bool dateOk = true;
      if (_startDate != null) {
        dateOk =
            dateOk &&
            (ts.isAfter(_startDate!) ||
                ts.year == _startDate!.year &&
                    ts.month == _startDate!.month &&
                    ts.day == _startDate!.day);
      }
      if (_endDate != null) {
        // Set end date to end of day
        final endOfDay = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
          59,
        );
        dateOk = dateOk && ts.isBefore(endOfDay);
      }

      // Time Range Filter
      final imgMinutes = ts.hour * 60 + ts.minute;
      final startMinutes = _startTime.hour * 60 + _startTime.minute;
      final endMinutes = _endTime.hour * 60 + _endTime.minute;
      final hourOk = imgMinutes >= startMinutes && imgMinutes <= endMinutes;

      return dateOk && hourOk;
    }).toList();
  }

  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());
    final firstDate = isStart ? DateTime(2020) : (_startDate ?? DateTime(2020));
    final lastDate = isStart ? (_endDate ?? DateTime.now()) : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
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
        if (isStart) {
          _startDate = picked;
          // Validate logic: if start > end, reset end
          if (_endDate != null && _startDate!.isAfter(_endDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // For glassmorphism bottom nav if needed
      body: Container(
        decoration: AppStyles.internalScreenBackground,
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
                  'Galería de\nRegistros',
                  style: TextStyle(
                    fontFamily: 'Inter', // Fallback to system if not avail
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: _textHeader,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔍 FILTER SECTION (Single Glass Card)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'FILTROS DE BÚSQUEDA',
                  style: AppStyles.sectionSubtitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.35,
                        ), // 35% opacity
                        borderRadius: BorderRadius.circular(26),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. FECHA DE CAPTURA (Range)
                          Row(
                            children: [
                              Expanded(
                                child: _buildCapsuleInput(
                                  icon: Icons.calendar_today_rounded,
                                  label: _startDate == null
                                      ? 'Inicio'
                                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                  onTap: () => _pickDate(true),
                                  isActive: _startDate != null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCapsuleInput(
                                  icon: Icons.event_rounded,
                                  label: _endDate == null
                                      ? 'Fin'
                                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                  onTap: () => _pickDate(false),
                                  isActive: _endDate != null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 2. HORARIO (Range)
                          Row(
                            children: [
                              Expanded(
                                child: _TimeInputCapsule(
                                  initialValue: _startTime,
                                  onChanged: (v) =>
                                      setState(() => _startTime = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _TimeInputCapsule(
                                  initialValue: _endTime,
                                  onChanged: (v) =>
                                      setState(() => _endTime = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 3. FILTER ACTIONS (Badge + Clear)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _filteredImages.isNotEmpty
                                      ? _primaryMint
                                      : Colors.grey.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'Total: ${_filteredImages.length} registros',
                                  style: TextStyle(
                                    color: _filteredImages.isNotEmpty
                                        ? Colors.white
                                        : _textHeader.withValues(alpha: 0.6),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              // Clear Filters
                              _buildResetButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                              Icons.search_off_rounded,
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
                            const SizedBox(height: 8),
                            Text(
                              'Ajusta el rango de fechas para ver registros',
                              style: TextStyle(
                                color: _textHeader.withValues(alpha: 0.4),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: _groupImagesByDate(_filteredImages).length,
                        itemBuilder: (context, index) {
                          final group = _groupImagesByDate(
                            _filteredImages,
                          )[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      group.date,
                                      style: const TextStyle(
                                        color: _textHeader,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: _textHeader.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Images Grid
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.85,
                                    ),
                                itemCount: group.images.length,
                                itemBuilder: (context, imgIndex) {
                                  return _buildImageCard(
                                    group.images[imgIndex],
                                  );
                                },
                              ),
                            ],
                          );
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

  List<_DateGroup> _groupImagesByDate(List<ImageData> images) {
    final groups = <String, List<ImageData>>{};
    for (var img in images) {
      final dateKey =
          '${img.timestamp.day.toString().padLeft(2, '0')}/${img.timestamp.month.toString().padLeft(2, '0')}/${img.timestamp.year}';
      if (!groups.containsKey(dateKey)) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(img);
    }

    return groups.entries
        .map((e) => _DateGroup(date: e.key, images: e.value))
        .toList();
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

  Widget _buildResetButton() {
    final isDefaultTime =
        _startTime.hour == 18 &&
        _startTime.minute == 0 &&
        _endTime.hour == 22 &&
        _endTime.minute == 0;
    final hasFilters = _startDate != null || _endDate != null || !isDefaultTime;

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
              width: 40,
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
              child: Icon(
                Icons.cleaning_services_rounded,
                color: hasFilters
                    ? _primaryMint
                    : _textHeader.withValues(alpha: 0.5),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(ImageData image) {
    final String timeStr =
        '${image.timestamp.hour > 12 ? image.timestamp.hour - 12 : (image.timestamp.hour == 0 ? 12 : image.timestamp.hour)}:${image.timestamp.minute.toString().padLeft(2, '0')} ${image.timestamp.hour >= 12 ? 'PM' : 'AM'}';

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
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
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
                    timeStr,
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

class _DateGroup {
  final String date;
  final List<ImageData> images;

  _DateGroup({required this.date, required this.images});
}

class _TimeInputCapsule extends StatefulWidget {
  final TimeOfDay initialValue;
  final ValueChanged<TimeOfDay> onChanged;
  final double? width;

  const _TimeInputCapsule({
    required this.initialValue,
    required this.onChanged,
    this.width,
  });

  @override
  State<_TimeInputCapsule> createState() => _TimeInputCapsuleState();
}

class _TimeInputCapsuleState extends State<_TimeInputCapsule> {
  late TextEditingController _controller;
  String? _errorText;
  late TimeOfDay _lastValidTime;
  final FocusNode _focusNode = FocusNode();

  // Eco-Corporate Palette (Hardcoded for self-containment)
  static const Color _primaryMint = Color(0xFF00E0A6);
  static const Color _textLabel = Color(0xFF004C3F);

  @override
  void initState() {
    super.initState();
    _lastValidTime = widget.initialValue;
    _controller = TextEditingController(
      text: _formatTimeOfDay(widget.initialValue),
    );
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(_TimeInputCapsule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _lastValidTime) {
      _lastValidTime = widget.initialValue;
      _controller.text = _formatTimeOfDay(widget.initialValue);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateAndSubmit(_controller.text);
      if (_errorText == null) {
        _controller.text = _formatTimeOfDay(_lastValidTime);
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _validateAndSubmit(String value) {
    if (value.isEmpty) {
      setState(() => _errorText = 'Requerido');
      return;
    }

    final time = _parseTimeInput(value);
    if (time == null) {
      setState(() => _errorText = 'Inválido');
      return;
    }

    setState(() {
      _errorText = null;
      _lastValidTime = time;
    });
    widget.onChanged(time);
  }

  TimeOfDay? _parseTimeInput(String input) {
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');
    final timeMatch = timeRegex.firstMatch(input);
    if (timeMatch != null) {
      final hour = int.parse(timeMatch.group(1)!);
      final minute = int.parse(timeMatch.group(2)!);
      return TimeOfDay(hour: hour, minute: minute);
    }

    final numericRegex = RegExp(r'^\d+$');
    if (numericRegex.hasMatch(input)) {
      final totalMinutes = int.parse(input);
      if (totalMinutes >= 0 && totalMinutes < 1440) {
        final hour = totalMinutes ~/ 60;
        final minute = totalMinutes % 60;
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: widget.width,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: _errorText != null
                  ? Colors.red.withValues(alpha: 0.5)
                  : (_focusNode.hasFocus ? _primaryMint : Colors.transparent),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: _primaryMint,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Min (90) o HH:MM',
                    hintStyle: TextStyle(
                      color: _textLabel.withValues(alpha: 0.4),
                      fontSize: 10,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(bottom: 2),
                  ),
                  style: GoogleFonts.inter(
                    color: _textLabel,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  keyboardType: TextInputType.datetime,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (val) {
                    _validateAndSubmit(val);
                    if (_errorText == null) {
                      _controller.text = _formatTimeOfDay(_lastValidTime);
                    }
                  },
                  onChanged: (val) {
                    if (_parseTimeInput(val) != null && _errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 2),
            child: Text(
              _errorText!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
