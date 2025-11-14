import 'package:flutter/material.dart';
import '../models/image_data.dart';

class ImageDetailScreen extends StatefulWidget {
  final ImageData image;

  const ImageDetailScreen({super.key, required this.image});

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  final TransformationController _transformationController =
      TransformationController();
  bool _showAppBar = true;
  bool _showBottomBar = true;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleBars() {
    setState(() {
      _showAppBar = !_showAppBar;
      _showBottomBar = !_showBottomBar;
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _shareImage() {
    // Implementar funcionalidad de compartir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de compartir próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar imagen'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar esta imagen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver a galería
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Imagen eliminada'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showImageInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.purple.shade600),
                  const SizedBox(width: 12),
                  const Text(
                    'Información de la imagen',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow('ID', widget.image.id),
              _buildInfoRow(
                'Fecha',
                _formatFullDateTime(widget.image.timestamp),
              ),
              _buildInfoRow('Tamaño', widget.image.size),
              _buildInfoRow('Formato', 'JPEG'),
              _buildInfoRow('Resolución', '1920x1080'),
              _buildInfoRow('Dispositivo', 'ESP32-CAM'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade800)),
          ),
        ],
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF498428),
                ), // Verde oscuro
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Imagen ${widget.image.id}',
                style: const TextStyle(
                  color: Color(0xFF498428), // Verde oscuro para el texto
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF498428),
                  ), // Verde oscuro
                  onPressed: _showImageInfo,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.zoom_out_map,
                    color: Color(0xFF498428),
                  ), // Verde oscuro
                  onPressed: _resetZoom,
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _toggleBars,
        child: Center(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade200),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 120, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Imagen ESP32',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatFullDateTime(widget.image.timestamp),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _showBottomBar
          ? Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomButton(
                        icon: Icons.share,
                        label: 'Compartir',
                        onPressed: _shareImage,
                      ),
                      _buildBottomButton(
                        icon: Icons.delete_outline,
                        label: 'Eliminar',
                        onPressed: _deleteImage,
                        color: Colors.red,
                      ),
                      _buildBottomButton(
                        icon: Icons.download,
                        label: 'Descargar',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Funcionalidad de descarga próximamente',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final buttonColor = color ?? Colors.white;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: buttonColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: buttonColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
