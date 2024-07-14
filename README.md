# Audio Analyzer

A Flutter plugin for analyzing audio files using native Android code. This plugin utilizes the [Amplituda](https://github.com/lincollincol/Amplituda) library to process audio files and extract amplitude data.

## Features

- Get amplitude data from audio files
- Clear processing cache

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  audio_analyzer: ^0.0.1
```

And for Android, in your `build.gradle` (project level):

```groovy
allprojects {
    repositories {
         maven { url 'https://jitpack.io' }
    }
}
```

## Usage

First, import the package:

```dart
import 'package:audio_analyzer/audio_analyzer.dart';
```

### Get Amplitudes

To get the amplitudes from an audio file:

```dart
try {
  List<int> amplitudes = await AudioAnalyzer.getAmplitudes('path/to/your/audio/file.mp3');
  // Process the amplitudes
} catch (e) {
  print('Error: $e');
}
```

### Clear Cache

To clear the processing cache:

```dart
await AudioAnalyzer.clearCache();
```

## Example

```dart
import 'package:flutter/material.dart';
import 'package:audio_analyzer/audio_analyzer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Audio Analyzer Example')),
        body: Center(
          child: ElevatedButton(
            child: Text('Analyze Audio'),
            onPressed: () async {
              try {
                List<int> amplitudes = await AudioAnalyzer.getAmplitudes('path/to/your/audio/file.mp3');
                print('Amplitudes: $amplitudes');
              } catch (e) {
                print('Error: $e');
              }
            },
          ),
        ),
      ),
    );
  }
}
```

## Requirements

- Android SDK 21+
- Flutter 2.0.0+

## Limitations

- Currently only supports Android.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

This README provides an overview of your plugin, installation instructions, usage examples, and other relevant information. You may want to adjust the content based on your specific implementation details, version numbers, and any additional features or limitations of your plugin.

Remember to create a LICENSE file in your repository if you haven't already, and choose an appropriate license for your project.

Would you like me to explain or elaborate on any part of this README?