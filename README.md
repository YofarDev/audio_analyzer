# audio_analyzer

A Flutter plugin that extracts waveform amplitudes from an audio file.

## Supported platforms

- Android
- iOS
- macOS
- Linux
- Web (placeholder implementation)

## Installation

Add the dependency:

```yaml
dependencies:
  audio_analyzer: ^0.1.0
```

For Android, add JitPack to your top-level `build.gradle` repositories:

```groovy
allprojects {
  repositories {
    maven { url 'https://jitpack.io' }
  }
}
```

## Usage

```dart
import 'package:audio_analyzer/audio_analyzer.dart';

final analyzer = AudioAnalyzer();
final amplitudes = await analyzer.getAmplitudes(
  '/path/to/audio.wav',
  samplesPerSecond: 40,
);
```

To clear cached native data when supported:

```dart
await analyzer.clearCache();
```

## API

- `Future<List<int>> getAmplitudes(String filePath, {int samplesPerSecond = 40})`
- `Future<void> clearCache()`

## Linux notes

- Linux currently supports WAV (`RIFF/WAVE`) files.
- Supported WAV encodings: PCM 8/16/24/32-bit and float 32-bit.

## Amplitude format

Returned amplitudes are normalized integer RMS values from `0` to `100`.

## License

MIT. See [LICENSE](LICENSE).
