import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() async {
  final audioFiles = {
    'bgm_workshop.wav': 2.0, // 2 seconds loop
    'sfx_merge.wav': 0.5,
    'sfx_meow.wav': 0.5,
  };

  final dir = Directory('assets/audio');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  for (final entry in audioFiles.entries) {
    final fileName = entry.key;
    final duration = entry.value;
    final file = File('assets/audio/$fileName');

    // Create a simple WAV file
    final sampleRate = 44100;
    final numSamples = (sampleRate * duration).toInt();
    final numChannels = 1;
    final byteRate = sampleRate * numChannels * 2; // 16-bit
    final blockAlign = numChannels * 2;

    final fileSize = 36 + numSamples * 2;

    final buffer = BytesBuilder();

    // RIFF header
    buffer.add('RIFF'.codeUnits);
    buffer.add(_int32(fileSize - 8));
    buffer.add('WAVE'.codeUnits);

    // fmt subchunk
    buffer.add('fmt '.codeUnits);
    buffer.add(_int32(16)); // Subchunk1Size
    buffer.add(_int16(1)); // AudioFormat (PCM)
    buffer.add(_int16(numChannels));
    buffer.add(_int32(sampleRate));
    buffer.add(_int32(byteRate));
    buffer.add(_int16(blockAlign));
    buffer.add(_int16(16)); // BitsPerSample

    // data subchunk
    buffer.add('data'.codeUnits);
    buffer.add(_int32(numSamples * 2));

    final random = Random();

    // Generate samples
    for (var i = 0; i < numSamples; i++) {
      double value = 0;

      if (fileName.startsWith('bgm')) {
        // Simple ambient hum
        value = sin(2 * pi * 220 * i / sampleRate) * 0.1;
      } else if (fileName.contains('meow')) {
        // Sawtooth for meow
        value = ((i % 200) / 200.0) * 2 - 1;
        value *= (1 - i / numSamples); // Decay
      } else {
        // Noise for generic sfx
        value = (random.nextDouble() * 2 - 1) * 0.5;
        value *= (1 - i / numSamples); // Decay
      }

      final intSample = (value * 32767).toInt().clamp(-32768, 32767);
      buffer.add(_int16(intSample));
    }

    await file.writeAsBytes(buffer.toBytes());
    print('Generated $fileName');
  }
}

List<int> _int32(int value) {
  final b = ByteData(4);
  b.setInt32(0, value, Endian.little);
  return b.buffer.asUint8List().toList();
}

List<int> _int16(int value) {
  final b = ByteData(2);
  b.setInt16(0, value, Endian.little);
  return b.buffer.asUint8List().toList();
}
