import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';

// The free tier ships flat stills only; the Standard-tier previews under
// assets/images/samples/ are looping animations. Verify Flutter's built-in
// codec decodes one as multi-frame — if frameCount > 1, the stock Image
// widget auto-plays it (the catalog "Standard tier preview" gallery relies
// on this).
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
