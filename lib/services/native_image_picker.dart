import 'package:flutter/services.dart';

class NativeImagePicker {
  static const _channel = MethodChannel('native_image_picker');

  static Future<String?> pickFromGallery() async {
    final path = await _channel.invokeMethod<String>('pickFromGallery');
    return path;
  }

  static Future<String?> pickFromCamera() async {
    final path = await _channel.invokeMethod<String>('pickFromCamera');
    return path;
  }
}
