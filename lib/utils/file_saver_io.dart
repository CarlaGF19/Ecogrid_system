import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveFile(Uint8List bytes, String fileName, String mimeType) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  await Share.shareXFiles([XFile(file.path)], text: 'Descarga de archivo');
}
