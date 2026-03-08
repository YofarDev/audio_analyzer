import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_analyzer/audio_analyzer_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAudioAnalyzer platform = MethodChannelAudioAnalyzer();
  const MethodChannel channel = MethodChannel('audio_analyzer');
  MethodCall? lastMethodCall;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        lastMethodCall = methodCall;
        if (methodCall.method == 'getAmplitudes') {
          return <double>[0.1, 0.25, 0.89];
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getAmplitudes maps payload and normalizes doubles', () async {
    expect(
      await platform.getAmplitudes('/tmp/a.mp3', 10),
      <int>[10, 25, 89],
    );
    expect(lastMethodCall?.arguments, <String, dynamic>{
      'filePath': '/tmp/a.mp3',
      'samplesPerSecond': 10,
    });
  });

  test('clearCache invokes method channel', () async {
    await platform.clearCache();
    expect(lastMethodCall?.method, 'clearCache');
  });
}
