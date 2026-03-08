import 'dart:typed_data';

import 'sample_audio_path_stub.dart'
    if (dart.library.io) 'sample_audio_path_io.dart' as impl;

Future<String?> materializeBundledSample(
  String fileName,
  ByteData bytes,
) {
  return impl.materializeBundledSample(fileName, bytes);
}
