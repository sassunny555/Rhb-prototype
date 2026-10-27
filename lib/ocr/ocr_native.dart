import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

Future<Uint8List?> captureCameraFrame() async => null;
Future<String> recognizeText({Uint8List? bytes}) async {
  if (bytes == null) return '';
  final folder = await getTemporaryDirectory();
  final file = File(
    '${folder.path}/qr-ocr-${DateTime.now().microsecondsSinceEpoch}.jpg',
  );
  final reader = TextRecognizer();
  try {
    await file.writeAsBytes(bytes);
    return (await reader.processImage(InputImage.fromFilePath(file.path))).text;
  } finally {
    await reader.close();
    if (await file.exists()) await file.delete();
  }
}
