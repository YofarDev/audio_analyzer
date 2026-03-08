import 'dart:async';

import 'package:audio_analyzer/audio_analyzer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sample_audio_path.dart';

const String _bundledAssetPathDefault = 'assets/sample.mp3';
const String _bundledAssetPathLinux = 'assets/sample.wav';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AudioAnalyzer _audioAnalyzerPlugin = AudioAnalyzer();

  String _status = 'Loading bundled sample...';
  String _sourceLabel = 'Bundled sample';
  List<int> _amplitudes = <int>[];
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_analyzeBundledSample());
  }

  Future<void> _analyzeBundledSample() async {
    final String assetPath =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.linux
            ? _bundledAssetPathLinux
            : _bundledAssetPathDefault;
    final String assetName = assetPath.split('/').last;

    await _runAnalysis(
      sourceLabel: 'Bundled sample ($assetPath)',
      resolvePath: () async {
        if (kIsWeb) {
          return assetPath;
        }
        final ByteData bytes = await rootBundle.load(assetPath);
        return materializeBundledSample('audio_analyzer_$assetName', bytes);
      },
    );
  }

  Future<void> _pickAndAnalyzeFile() async {
    await _runAnalysis(
      sourceLabel: 'Picked file',
      resolvePath: () async {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: false,
        );
        if (result == null || result.files.isEmpty) {
          return null;
        }
        return result.files.single.path;
      },
    );
  }

  Future<void> _runAnalysis({
    required String sourceLabel,
    required Future<String?> Function() resolvePath,
  }) async {
    setState(() {
      _isBusy = true;
      _status = 'Analyzing...';
    });

    try {
      final String? filePath = await resolvePath();
      if (filePath == null || filePath.isEmpty) {
        setState(() {
          _isBusy = false;
          _status = 'No file selected';
        });
        return;
      }

      final List<int> amplitudes = await _audioAnalyzerPlugin.getAmplitudes(
        filePath,
      );

      setState(() {
        _isBusy = false;
        _sourceLabel = sourceLabel;
        _amplitudes = amplitudes;
        _status =
            'Done: ${amplitudes.length} points (min ${_min(amplitudes)}, max ${_max(amplitudes)})';
      });
    } on Exception catch (e) {
      setState(() {
        _isBusy = false;
        _status = 'Error: $e';
      });
    }
  }

  int _min(List<int> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b);

  int _max(List<int> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Audio Analyzer Example')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_status),
              const SizedBox(height: 8),
              Text('Source: $_sourceLabel'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  FilledButton(
                    onPressed: _isBusy ? null : _analyzeBundledSample,
                    child: const Text('Analyze Bundled Sample'),
                  ),
                  OutlinedButton(
                    onPressed: _isBusy ? null : _pickAndAnalyzeFile,
                    child: const Text('Pick Audio File'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('First 80 amplitudes:'),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(_amplitudes.take(80).join(', ')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
