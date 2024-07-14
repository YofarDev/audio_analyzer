import 'package:flutter_test/flutter_test.dart';
import 'package:audio_analyzer/audio_analyzer.dart';
import 'package:audio_analyzer/audio_analyzer_platform_interface.dart';
import 'package:audio_analyzer/audio_analyzer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioAnalyzerPlatform
    with MockPlatformInterfaceMixin
    implements AudioAnalyzerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AudioAnalyzerPlatform initialPlatform = AudioAnalyzerPlatform.instance;

  test('$MethodChannelAudioAnalyzer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAudioAnalyzer>());
  });

  test('getPlatformVersion', () async {
    AudioAnalyzer audioAnalyzerPlugin = AudioAnalyzer();
    MockAudioAnalyzerPlatform fakePlatform = MockAudioAnalyzerPlatform();
    AudioAnalyzerPlatform.instance = fakePlatform;

    expect(await audioAnalyzerPlugin.getPlatformVersion(), '42');
  });
}
