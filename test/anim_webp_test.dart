import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';

// Verifies Flutter's built-in image codec decodes our animated WebP as
// multi-frame. If frameCount > 1, the stock Image widget will auto-play it.
void main() {
  test('animated webp decodes to >1 frame', () async {
    final bytes =
        await File('assets/images/animations/arnold-press.webp').readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    // ignore: avoid_print
    print('arnold-press.webp frameCount=${codec.frameCount}');
    expect(codec.frameCount, greaterThan(1));
  });
}
