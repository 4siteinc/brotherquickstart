import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;

class ImageUtil {
  Future<File> rotate(String imagePath, num angle) async {
    debugPrint("ImageUtil: rotate: $imagePath");

    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);

    if (originalImage != null) {
      // I.E.  rotatedImage = img.copyRotate(originalImage, 90);
      // I.E.  rotatedImage = img.copyRotate(originalImage, -90);
      late img.Image rotatedImage = img.copyRotate(originalImage, angle);
      // Here you can select whether you'd like to save it as png or jpg with some compression
      File f = await originalFile.writeAsBytes(img.encodePng(rotatedImage));
      return f;
    }
    return File(imagePath);
  }
}
