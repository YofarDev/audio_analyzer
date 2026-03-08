import 'dart:js_interop';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audio_analyzer/audio_analyzer_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

class AudioAnalyzerWeb extends AudioAnalyzerPlatform {
  static void registerWith(Registrar registrar) {
    AudioAnalyzerPlatform.instance = AudioAnalyzerWeb();
  }

  @override
  Future<List<int>> getAmplitudes(String filePath, int samplesPerSecond) async {
    if (samplesPerSecond <= 0) {
      throw ArgumentError.value(
        samplesPerSecond,
        'samplesPerSecond',
        'must be greater than 0',
      );
    }

    final web.Response response = await web.window.fetch(filePath.toJS).toDart;
    if (!response.ok) {
      throw Exception(
        'Failed to fetch "$filePath" (HTTP ${response.status}).',
      );
    }
    final JSArrayBuffer encoded = await response.arrayBuffer().toDart;

    final web.AudioContext context = web.AudioContext();
    try {
      final web.AudioBuffer decoded =
          await context.decodeAudioData(encoded).toDart;
      final Float32List channelData = decoded.getChannelData(0).toDart;
      final int windowSize =
          math.max(1, (decoded.sampleRate / samplesPerSecond).floor());
      final List<int> amplitudes = <int>[];

      for (int i = 0; i < channelData.length; i += windowSize) {
        final int end = math.min(i + windowSize, channelData.length);
        double sumSquares = 0;
        for (int j = i; j < end; j++) {
          final double sample = channelData[j].toDouble();
          sumSquares += sample * sample;
        }

        final double rms = math.sqrt(sumSquares / (end - i));
        final int normalized = (rms * 100).round().clamp(0, 100);
        amplitudes.add(normalized);
      }

      return amplitudes;
    } finally {
      await context.close().toDart;
    }
  }

  @override
  Future<void> clearCache() async {}
}
