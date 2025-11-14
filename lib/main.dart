import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/welcome_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/device_config_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/sensor_dashboard_screen.dart';
import 'screens/sensor_detail_page.dart';
import 'screens/image_gallery_screen.dart';
import 'screens/image_detail_screen.dart';
import 'screens/device_connection_screen.dart';
import 'screens/about_screen.dart';
import 'screens/notifications_screen.dart';
import 'models/image_data.dart';

void main() {
  runApp(const MainApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/ip',
      builder: (context, state) => const DeviceConfigScreen(),
    ),
    GoRoute(
      path: '/main-menu',
      builder: (context, state) => const MainMenuScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final ip = state.extra as String?;
        return SensorDashboardScreen(ip: ip ?? '');
      },
    ),
    GoRoute(
      path: '/sensor-detail',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return SensorDetailPage(
          esp32Ip: args?['ip'] ?? '',
          tipo: args?['sensorType'] ?? '',
          titulo: args?['titulo'] ?? 'Detalle del Sensor',
        );
      },
    ),
    GoRoute(
      path: '/image-gallery',
      builder: (context, state) => const ImageGalleryScreen(),
    ),
    GoRoute(
      path: '/image-detail',
      builder: (context, state) {
        final image = state.extra as ImageData;
        return ImageDetailScreen(image: image);
      },
    ),
    GoRoute(
      path: '/device-connection',
      builder: (context, state) => const DeviceConnectionScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
