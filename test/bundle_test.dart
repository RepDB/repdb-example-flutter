import 'package:flutter_test/flutter_test.dart';
import 'package:repdb_example_flutter/data/bundle.dart';

// Exercises the data layer behind the Tier B detail screen: taxonomy parsing,
// MET, the classic/flat path switch, and localized labels + icon paths.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundle loads taxonomy, met, styles and localized labels', () async {
    final b = await Bundle.load();
    expect(b.muscles, isNotEmpty);
    expect(b.equipment, isNotEmpty);

    final ex = b.findById('arnold-press');
    expect(ex, isNotNull);
    expect(ex!.met, 6.0);
    expect(ex.hasBothStyles, isTrue);

    expect(ex.imagePath('peak'), 'assets/images/flat/arnold-press-peak.webp');
    expect(ex.imagePath('peak', style: 'classic'),
        'assets/images/classic/arnold-press-peak.webp');

    // Localized muscle label (German) differs from the raw key.
    expect(b.muscleLabel('anterior_deltoid', 'de'), isNotEmpty);
    expect(b.muscleLabel('anterior_deltoid', 'de'),
        isNot(equals('Anterior Deltoid')));
    expect(b.muscleIcon('anterior_deltoid'), contains('anterior-deltoid.webp'));
    expect(b.equipmentIcon('ez_bar'), contains('ez-bar.webp'));
  });
}
