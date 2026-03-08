import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_analyzer_platform_interface.dart';

/// An implementation of [AudioAnalyzerPlatform] that uses method channels.
class MethodChannelAudioAnalyzer extends AudioAnalyzerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audio_analyzer');

  @override
  Future<List<int>> getAmplitudes(String filePath, int samplesPerSecond) async {
    final List<dynamic>? amplitudes =
        await methodChannel.invokeMethod<List<dynamic>>(
      'getAmplitudes',
      {
        'filePath': filePath,
        'samplesPerSecond': samplesPerSecond,
      },
    );
    if (amplitudes == null) {
      return <int>[];
    }
    return amplitudes.map<int>((dynamic amp) {
      if (amp is int) {
        return amp;
      }
      if (amp is double) {
        return (amp * 100).round().clamp(0, 100);
      }
      throw PlatformException(
        code: 'INVALID_RESULT',
        message: 'Unexpected amplitude value type: ${amp.runtimeType}',
      );
    }).toList();
  }

  @override
  Future<void> clearCache() async {
    await methodChannel.invokeMethod<void>('clearCache');
  }
}
