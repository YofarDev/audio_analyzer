import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioAnalyzer {
  static const MethodChannel _channel = MethodChannel('audio_analyzer');

  Future<List<int>> getAmplitudes(String filePath,
      {int samplesPerSecond = 40}) async {
    final List<dynamic> amplitudes =
        await _channel.invokeMethod('getAmplitudes', {
      'filePath': filePath,
      'samplesPerSecond': samplesPerSecond, // doesnt work for android
    });
    if (kIsWeb) {
      return amplitudes.cast<int>();
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return amplitudes
          .cast<double>()
          .map((amp) => (amp * 100).toInt())
          .toList();
    }
    return amplitudes.cast<int>();
  }

  Future<void> clearCache() async {
    await _channel.invokeMethod('clearCache');
  }
}
