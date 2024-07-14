import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:audio_analyzer/audio_analyzer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _amplitudeResult = 'Unknown';
  final _audioAnalyzerPlugin = AudioAnalyzer();

  @override
  void initState() {
    super.initState();
  }

  Future<void> getAmplitude() async {
    String amplitudeResult;
    try {
    List<int> amplitudes = await _audioAnalyzerPlugin.getAmplitudes('/path/to/your/audio/file.mp3');
      amplitudeResult = 'Amplitude: $amplitudes';
    } on PlatformException {
      amplitudeResult = 'Failed to get amplitude.';
    }

    setState(() {
      _amplitudeResult = amplitudeResult;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Amplitude Analyzer Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_amplitudeResult),
              ElevatedButton(
                onPressed: getAmplitude,
                child: const Text('Get Amplitude'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}