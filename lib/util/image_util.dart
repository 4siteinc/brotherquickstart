import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import "dart:ui" as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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

  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData img = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(img.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  static Future<Uint8List> globalKeyToImage(GlobalKey key) async {
    Uint8List pngBytes = Uint8List.fromList(List.empty());
    if (key.currentContext!.findRenderObject() != null) {
      final RenderRepaintBoundary? boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      if (boundary!.debugNeedsPaint) {
        while (boundary.debugNeedsPaint) {
          await Future.delayed(const Duration(seconds: 1));
          // debugPrint("CampaignScreen: saveWidgetCameraRoll: Waiting for boundary to be painted.");
        }
      }
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      pngBytes = byteData!.buffer.asUint8List();
    }
    return pngBytes;
  }

  Future<File> writeBytesToPngFile(Uint8List pngBytes) async {
    final dDayLocal = DateTime.now();
    final Directory directory = await getTemporaryDirectory();
    String fileName = "${dDayLocal.year}${dDayLocal.month}${dDayLocal.day}${dDayLocal.hour}${dDayLocal.minute}${dDayLocal.second}${dDayLocal.millisecond}.png";
    return await File("${directory.path}/$fileName").writeAsBytes(pngBytes);
  }

  Future<bool?> saveImageToGallery(File file) async {
    return await GallerySaver.saveImage(file.path);
  }
}
