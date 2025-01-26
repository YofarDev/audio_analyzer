# Audio Analyzer

A Flutter plugin for getting a list of amplitudes for an audio file. On Android's side, this plugin utilizes the [Amplituda](https://github.com/lincollincol/Amplituda) library.

## Features

- Get amplitude data from audio files

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

On iOS it should just work.

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

Results from iOS and Android are slightly different.
Example with an audio file of 2 seconds (same file for both platforms) :

- Android output :

```
amplitudes = [0, 0, 0, 0, 0, 3, 7, 10, 11, 8, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 10, 13, 14, 11, 5, 1, 1, 0, 0, 0, 2, 11, 11, 11, 12, 12, 12, 10, 12, 10, 6, 1, 0, 1, 9, 9, 4, 0, 1, 2, 5, 11, 11, 9, 7, 2, 0, 0, 1, 0, 5, 10, 9, 2, 0, 0, 1, 9, 12, 8, 2, 1, 2, 1, 0, 0, 7, 17, 14, 12, 11, 10, 8, 7, 5, 3, 2, 1, 1, 0, 0, 0]
```

```
amplitudes.length = 92
```

- iOS output :

```
amplitudes = [0, 0, 0, 0, 0, 3, 8, 10, 10, 6, 0, 0, 0, 1, 1, 0, 0, 1, 1, 8, 13, 14, 11, 6, 1, 1, 0, 0, 0, 4, 11, 11, 11, 12, 13, 11, 12, 12, 8, 3, 0, 1, 7, 10, 5, 0, 1, 2, 4, 11, 11, 9, 7, 2, 0, 1, 1, 1, 7, 10, 7, 1, 0, 0, 6, 12, 10, 3, 1, 2, 1, 0, 0, 7, 16, 14, 12, 11, 10, 8, 7, 5, 3, 2, 1, 1, 0, 0, 0, 0, 0]
```

```
amplitudes.length = 91
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```

This README provides an overview of your plugin, installation instructions, usage examples, and other relevant information. You may want to adjust the content based on your specific implementation details, version numbers, and any additional features or limitations of your plugin.

Remember to create a LICENSE file in your repository if you haven't already, and choose an appropriate license for your project.

Would you like me to explain or elaborate on any part of this README?
```
