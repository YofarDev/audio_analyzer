import 'audio_analyzer_platform_interface.dart';

class AudioAnalyzer {
  Future<List<int>> getAmplitudes(String filePath,
      {int samplesPerSecond = 40}) {
    return AudioAnalyzerPlatform.instance
        .getAmplitudes(filePath, samplesPerSecond);
  }

  Future<void> clearCache() async {
    await AudioAnalyzerPlatform.instance.clearCache();
  }
}
