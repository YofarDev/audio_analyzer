import 'package:flutter_test/flutter_test.dart';

import 'package:audio_analyzer_example/main.dart';

void main() {
  testWidgets('renders example controls', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Audio Analyzer Example'), findsOneWidget);
    expect(find.text('Analyze Bundled Sample'), findsOneWidget);
    expect(find.text('Pick Audio File'), findsOneWidget);
  });
}
