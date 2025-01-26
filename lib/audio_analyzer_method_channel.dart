import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_analyzer_platform_interface.dart';

/// An implementation of [AudioAnalyzerPlatform] that uses method channels.
class MethodChannelAudioAnalyzer extends AudioAnalyzerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audio_analyzer');

  @override
  Future<List<int>?> getAmplitudes(String audioPath, int sampleRate) async {
    final List<int>? amplitudes = await methodChannel.invokeMethod<List<int>>('getAmplitudes', {
      'audioPath': audioPath,
      'sampleRate': sampleRate,
    });
    return amplitudes;
  }
}
