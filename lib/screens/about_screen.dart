import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../constants/strings.dart';

// Tipografías se tomarán del Theme para mantener consistencia

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _visible = false;

  // Paleta corporativa EcoGrid
  static const Color ecoPrimary = Color(0xFF00E0A6); // Verde principal
  static const Color ecoSecondary = Color(0xFF6AD48A); // Verde secundario
  static const Color ecoCyan = Color(0xFF00FFCC); // Cian brillante
  static const Color ecoDark = Color(0xFF004C3F); // Verde oscuro base
  static const Color ecoWhite = Color(0xFFF7FFF9); // Blanco perlado

  // Versión del Flutter SDK utilizada (capturada del entorno de desarrollo)
  static const String flutterSdkVersion = '3.35.7';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        backgroundColor: const Color.fromRGBO(247, 255, 249, 1),
        foregroundColor: const Color.fromARGB(255, 5, 145, 40),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: ecoDark,
          statusBarIconBrightness: Brightness.light,
        ),
        elevation: 0,
      ),
      backgroundColor: ecoWhite,
      body: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final horizontalPadding = isWide ? 24.0 : 16.0;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildProjectDescription(),
                      const SizedBox(height: 16),
                      _buildTechnicalSpecs(),
                      const SizedBox(height: 16),
                      _buildFeatures(theme),
                      const SizedBox(height: 16),
                      _buildVersionInfo(),
                      const SizedBox(height: 16),
                      _buildCopyrightLicense(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      key: const Key('about_header'),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: ecoWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ecoPrimary.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 72,
            child: Image.asset(
              'assets/icons/ecogrid_g.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          // Nombre correcto de la aplicación
          const Text(
            'EcoGrid',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ecoDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            Strings.headerTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: ecoPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDescription() {
    final theme = Theme.of(context);
    return Card(
      key: const Key('about_description'),
      color: const Color.fromRGBO(247, 255, 249, 1),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: ecoCyan),
                const SizedBox(width: 8),
                Text(
                  Strings.projectDescriptionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ecoDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              Strings.projectDescriptionBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ecoDark,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalSpecs() {
    final theme = Theme.of(context);
    final specs = [
      (
        icon: Icons.developer_board,
        title: Strings.microcontrollerLabel,
        subtitle: Strings.microcontrollerValue,
      ),
      (
        icon: Icons.wifi,
        title: Strings.connectivityLabel,
        subtitle: Strings.connectivityValue,
      ),
      (
        icon: Icons.sensors,
        title: Strings.sensorsLabel,
        subtitle: Strings.sensorsValue,
      ),
      (
        icon: Icons.http,
        title: Strings.protocolLabel,
        subtitle: Strings.protocolValue,
      ),
      (
        icon: Icons.phone_android,
        title: Strings.mobilePlatformLabel,
        subtitle: Strings.mobilePlatformValue,
      ),
      (
        icon: Icons.alt_route,
        title: Strings.architectureLabel,
        subtitle: Strings.architectureValue,
      ),
    ];

    return Card(
      key: const Key('about_specs'),
      color: ecoWhite,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: specs.length,
          itemBuilder: (context, index) {
            final item = specs[index];
            return ListTile(
              leading: Icon(item.icon, color: ecoSecondary),
              title: Text(
                item.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: ecoDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                item.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: ecoDark),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatures(ThemeData theme) {
    // Usa paleta corporativa
    return Card(
      key: const Key('about_features'),
      color: ecoWhite,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: ecoCyan),
                const SizedBox(width: 8),
                Text(
                  'Funcionalidades',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ecoDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFunctionalityItem(
              Icons.dashboard,
              'Dashboard Principal',
              'Visualización general de los sensores con datos en tiempo real',
              Theme.of(context).colorScheme,
              theme,
            ),
            _buildFunctionalityItem(
              Icons.analytics,
              'Procesamiento y visualización',
              'Análisis gráfico e interpretación de los valores obtenidos',
              Theme.of(context).colorScheme,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final now = DateTime.now();
    final dateFormatted = localizations.formatFullDate(now);

    return Card(
      key: const Key('about_version'),
      color: ecoWhite,
      elevation: 1,
      child: ExpansionTile(
        title: Text(
          Strings.versionInfoTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: ecoDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.app_settings_alt, color: ecoSecondary),
            title: Text(Strings.appVersionLabel),
            subtitle: Text(
              Strings.appVersionValue,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: ecoSecondary),
            title: Text(Strings.buildDateLabel),
            subtitle: Text(dateFormatted, style: theme.textTheme.bodyMedium),
          ),
          ListTile(
            leading: const Icon(Icons.flutter_dash, color: ecoSecondary),
            title: Text(Strings.flutterSdkLabel),
            subtitle: Text(
              'Flutter $flutterSdkVersion',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.devices, color: ecoSecondary),
            title: Text(Strings.platformLabel),
            subtitle: Text(
              Strings.platformValue,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionalityItem(
    IconData icon,
    String title,
    String description,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ecoCyan, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: ecoDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(color: ecoDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyrightLicense() {
    return Card(
      key: const Key('about_copyright'),
      color: ecoWhite,
      elevation: 1,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Copyright',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ecoDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '© 2025 EcoGrid. Todos los derechos reservados.',
              style: TextStyle(color: ecoDark),
            ),
            SizedBox(height: 4),
            Text('', style: TextStyle(color: ecoDark)),
          ],
        ),
      ),
    );
  }
}
