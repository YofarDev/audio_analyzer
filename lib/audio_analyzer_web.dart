// @JS()
// library audio_analyzer_web;

// import 'dart:async';
// import 'dart:js_interop';
// import 'dart:js_util' as jsu;
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// import 'audio_analyzer_platform_interface.dart';

// @JS('audioAnalyzer')
// external JSObject get audioAnalyzer;

// @JS('audioAnalyzer.getAmplitudes')
// external JSPromise _getAmplitudes(String audioUrl, int samplesPerSecond);

import 'package:audio_analyzer/audio_analyzer_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class AudioAnalyzerWeb extends AudioAnalyzerPlatform {
  static void registerWith(Registrar registrar) {
    AudioAnalyzerPlatform.instance = AudioAnalyzerWeb();
  }


  @override
  Future<List<int>> getAmplitudes(String audioPath, int sampleRate) async {
    // try {
    //   final result = await jsu.promiseToFuture(_getAmplitudes(filePath, samplesPerSecond));
    //   return List<int>.from(result);
    // } catch (e) {
    //   throw Exception('Failed to get amplitudes: $e');
    // }
    return List<int>.filled(100, 0);
  }

}