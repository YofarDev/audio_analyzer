## 0.1.2

- Implemented real Web audio analysis using browser `fetch` + Web Audio decoding.
- Removed placeholder zero-filled amplitude output on Web.

## 0.1.1

- Republish release to unblock pub.dev upload after `0.1.0` was already taken.

## 0.1.0

- Added Linux support with native WAV amplitude extraction.
- Unified method channel argument names across Dart and native platforms (`filePath`, `samplesPerSecond`).
- Added `clearCache` handling for all platforms (no-op where not applicable).
- Updated tests to validate the method channel payload and response mapping.

## 0.0.1

- Initial release.
