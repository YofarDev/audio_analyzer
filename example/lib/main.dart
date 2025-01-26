import 'dart:async';

import 'package:audio_analyzer/audio_analyzer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        amplitudeResult = 'No file selected';
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        amplitudeResult = 'Invalid file path';
        return;
      }

      List<int> amplitudes =
          await _audioAnalyzerPlugin.getAmplitudes(result.files.single.path!);
      amplitudeResult = 'Amplitude: $amplitudes';
    } on Exception catch (e) {
      amplitudeResult = 'Error: $e';
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
              SelectableText(_amplitudeResult),
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
