import 'package:audio_analyzer/audio_analyzer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getAmplitudes returns platform error for missing file',
      (WidgetTester tester) async {
    final AudioAnalyzer plugin = AudioAnalyzer();
    expect(
      plugin.getAmplitudes('/definitely/missing/audio_file.wav'),
      throwsA(isA<PlatformException>()),
    );
  });
}
