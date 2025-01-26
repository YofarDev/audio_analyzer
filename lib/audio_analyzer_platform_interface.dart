import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'audio_analyzer_method_channel.dart';

abstract class AudioAnalyzerPlatform extends PlatformInterface {
  /// Constructs a AudioAnalyzerPlatform.
  AudioAnalyzerPlatform() : super(token: _token);

  static final Object _token = Object();

  static AudioAnalyzerPlatform _instance = MethodChannelAudioAnalyzer();

  /// The default instance of [AudioAnalyzerPlatform] to use.
  ///
  /// Defaults to [MethodChannelAudioAnalyzer].
  static AudioAnalyzerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AudioAnalyzerPlatform] when
  /// they register themselves.
  static set instance(AudioAnalyzerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<int>?> getAmplitudes(String audioPath, int sampleRate);
}
