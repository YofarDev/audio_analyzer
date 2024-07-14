import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_analyzer_platform_interface.dart';

/// An implementation of [AudioAnalyzerPlatform] that uses method channels.
class MethodChannelAudioAnalyzer extends AudioAnalyzerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audio_analyzer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
