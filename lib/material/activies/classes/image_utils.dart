import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _localFile(String imageName) async {
    final path = await _localPath;
    return File('$path/$imageName');
  }

  static Future<File> saveImage(Uint8List imageData, String imageName) async {
    final file = await _localFile(imageName);
    return file.writeAsBytes(imageData);
  }

  static Future<Uint8List> loadImage(String imageName) async {
    final file = await _localFile(imageName);
    final imageData = await file.readAsBytes();
    return imageData;
  }
}