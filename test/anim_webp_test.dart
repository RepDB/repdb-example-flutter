import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';

// The free tier ships flat stills only; the one animated WebP is a Standard-
// tier preview under assets/images/samples/. Verify Flutter's built-in codec
// decodes it as multi-frame — if frameCount > 1, the stock Image widget will
// auto-play it (the detail screen relies on this for mountain-climbers).
void main() {
  test('sample animated webp decodes to >1 frame', () async {
    final bytes = await File('assets/images/samples/mountain-climbers.webp')
        .readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    // ignore: avoid_print
    print('mountain-climbers.webp frameCount=${codec.frameCount}');
    expect(codec.frameCount, greaterThan(1));
  });
}
