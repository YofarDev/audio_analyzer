import 'dart:io';
import 'dart:typed_data';

Future<String?> materializeBundledSample(
  String fileName,
  ByteData bytes,
) async {
  final Uint8List data = bytes.buffer.asUint8List();
  final Directory tempDir = Directory.systemTemp;
  final File output = File('${tempDir.path}/$fileName');
  await output.writeAsBytes(data, flush: true);
  return output.path;
}
