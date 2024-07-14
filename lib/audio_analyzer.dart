import 'dart:async';
import 'package:flutter/services.dart';

class AudioAnalyzer {
  static const MethodChannel _channel = MethodChannel('audio_analyzer');

  Future<List<int>> getAmplitudes(String filePath) async {
    final List<dynamic> amplitudes = await _channel.invokeMethod('getAmplitudes', {'filePath': filePath});
    return amplitudes.cast<int>();
  }

  Future<void> clearCache() async {
    await _channel.invokeMethod('clearCache');
  }
}