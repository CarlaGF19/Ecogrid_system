class ImageData {
  final String id;
  final DateTime timestamp;
  final String size;
  final String imageUrl;

  ImageData({
    required this.id,
    required this.timestamp,
    required this.size,
    this.imageUrl = 'assets/images/img_main_menu_screen.jpg', // Default placeholder
  });
}