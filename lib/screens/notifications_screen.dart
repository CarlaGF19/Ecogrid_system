import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_NotificationItem> items = [
      _NotificationItem(
        title: 'Conexión establecida',
        message: 'El ESP32 se conectó correctamente a la red.',
        time: 'Hace 2 min',
        icon: Icons.check_circle_outline,
        color: const Color(0xFF00B7B0),
      ),
      _NotificationItem(
        title: 'Nuevo dato de sensor',
        message: 'Se actualizó la lectura de temperatura.',
        time: 'Hace 10 min',
        icon: Icons.thermostat,
        color: const Color(0xFF00E0A6),
      ),
      _NotificationItem(
        title: 'Aviso de batería',
        message: 'Batería del dispositivo al 20%.',
        time: 'Hace 30 min',
        icon: Icons.battery_alert,
        color: const Color(0xFF3C8D2F),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Color(0xFF004C3F),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF004C3F)),
          onPressed: () {
            if (context.mounted) {
              context.go('/main-menu');
            }
          },
        ),
        iconTheme: const IconThemeData(color: Color(0xFF004C3F)),
      ),
      body: items.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _NotificationCard(item: item);
              },
            ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_none, size: 48, color: Color(0xFF004C3F)),
          SizedBox(height: 12),
          Text(
            'No hay notificaciones',
            style: TextStyle(
              color: Color(0xFF004C3F),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;

  _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Notificación: ${item.title}',
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6FFF5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2600A078),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF004C3F),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.message,
                      style: const TextStyle(
                        color: Color(0xFF2E5F3D),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.time,
                style: const TextStyle(
                  color: Color(0xFF2E5F3D),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}