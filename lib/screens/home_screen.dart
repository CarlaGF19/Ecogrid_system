import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'sensor_dashboard_screen.dart';
import 'main_menu_screen.dart'; // For PDFPage

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Colors (keeping original palette)
  static const Color _mintProtagonist = Color(0xFF00E0A6);
  static const Color _mintHighlight = Color(0xFF00FFC2);
  static const Color _cyanSupport = Color(0xFF00B7B0);
  static const Color _forestGreenText = Color(0xFF004C3F);
  static const Color _softGrey = Color(0xFF8BA29F);
  static const Color _borders = Color(0xFFE6FFF5);
  static const Color _shadowGlass = Color(
    0x1A004C3F,
  ); // ~10% opacity of dark forest

  // State
  final List<IconData> _anchoredSensors = [
    Icons.water_drop_outlined,
    Icons.device_thermostat_outlined,
  ];

  final List<IconData> _availableSensors = [
    Icons.wb_sunny_outlined,
    Icons.air_rounded,
    Icons.eco_outlined,
    Icons.water_damage_outlined,
    Icons.thermostat_auto_outlined,
    Icons.wind_power_outlined,
    Icons.solar_power_outlined,
    Icons.grass_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF1FBF9)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTopAccessCard(),
                const SizedBox(height: 32),
                const Text(
                  'Sensores Anclados',
                  style: TextStyle(
                    color: _forestGreenText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSensorGrid(),
                const SizedBox(height: 32),
                _buildSecondaryAction(),
                const SizedBox(height: 32),
                _buildFavoritesSection(),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Panel de control',
          style: TextStyle(
            color: _forestGreenText,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _shadowGlass,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: _borders),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: _forestGreenText,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTopAccessCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _borders),
            boxShadow: [
              BoxShadow(
                color: _shadowGlass,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                context.push('/main-menu');
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _mintProtagonist.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: _mintProtagonist,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Módulos',
                            style: TextStyle(
                              color: _forestGreenText,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Acceso al menú principal',
                            style: TextStyle(
                              color: _softGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.settings_suggest_outlined,
                      color: _softGrey,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorGrid() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          ..._anchoredSensors.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _buildSensorCard(entry.value, entry.key),
            ),
          ),
          _buildAddSensorButton(),
        ],
      ),
    );
  }

  Widget _buildSensorCard(IconData icon, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onLongPress: () {
          _showRemoveConfirmation(index);
          HapticFeedback.mediumImpact();
        },
        borderRadius: BorderRadius.circular(26),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: _borders),
                boxShadow: [
                  BoxShadow(
                    color: _shadowGlass,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: _forestGreenText, size: 42),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddSensorButton() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_mintHighlight, _mintProtagonist],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _mintProtagonist.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () {
            _showAddSensorModal();
          },
          child: const Center(
            child: Icon(Icons.add_rounded, color: Colors.white, size: 48),
          ),
        ),
      ),
    );
  }

  void _showAddSensorModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Añadir Sensor',
              style: TextStyle(
                color: _forestGreenText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              itemCount: _availableSensors.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final icon = _availableSensors[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _anchoredSensors.add(icon);
                    });
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _mintProtagonist.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _borders),
                    ),
                    child: Icon(icon, color: _forestGreenText),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _borders),
                boxShadow: [
                  BoxShadow(
                    color: _shadowGlass,
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Eliminar sensor anclado',
                    style: TextStyle(
                      color: _forestGreenText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '¿Deseas eliminar este sensor de tus accesos anclados?',
                    style: TextStyle(
                      color: _softGrey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _softGrey,
                            side: const BorderSide(color: _softGrey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _anchoredSensors.removeAt(index);
                            });
                            Navigator.pop(context);
                            HapticFeedback.mediumImpact();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _mintProtagonist,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryAction() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_mintProtagonist, _cyanSupport],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: _cyanSupport.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PDFPage(
                  apiBaseUrl:
                      "https://script.google.com/macros/s/AKfycbygUivdTGdLb_2p7f80TAJiwm_elb7FfXvyIJn_ID-BYhedUWjOQs1Sqk2rmubtn80N/exec",
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descarga de Data',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Exporta reportes por fecha',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Imágenes Favoritas',
              style: TextStyle(
                color: _forestGreenText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'ver todas',
                style: TextStyle(
                  color: _mintProtagonist,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _buildImageCard(),
              const SizedBox(width: 16),
              _buildImageCard(),
              const SizedBox(width: 16),
              _buildImageCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _shadowGlass,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(color: _borders), // Placeholder for image
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: _mintProtagonist,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _borders, width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: _mintProtagonist,
        unselectedItemColor: _softGrey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'SENSORES'),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'GALERÍA',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'AJUSTES'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          // Navigation logic placeholder
        },
      ),
    );
  }
}
