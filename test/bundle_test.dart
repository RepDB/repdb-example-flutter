import 'package:flutter_test/flutter_test.dart';
import 'package:repdb_example_flutter/data/bundle.dart';

// Exercises the data layer behind the free-tier detail screen: bundle size,
// taxonomy parsing, MET, flat image paths (start/peak, single-pose "main",
// aliased variations), the derived Standard-tier sample sets, and localized
// labels + icon paths.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundle loads 400 exercises, taxonomy, met and localized labels', () async {
    final b = await Bundle.load();
    expect(b.exercises.length, 400);
    expect(b.muscles, isNotEmpty);
    expect(b.equipment, isNotEmpty);

    final ex = b.findById('arnold-press');
    expect(ex, isNotNull);
    expect(ex!.met, 6.0);

    // Free tier ships flat stills only — no classic style.
    expect(ex.imagePath('peak'), 'assets/images/flat/arnold-press-peak.webp');
    expect(ex.imagePath('start'), 'assets/images/flat/arnold-press-start.webp');

    // Localized muscle label (German) differs from the raw key.
    expect(b.muscleLabel('anterior_deltoid', 'de'), isNotEmpty);
    expect(b.muscleLabel('anterior_deltoid', 'de'),
        isNot(equals('Anterior Deltoid')));
    expect(b.muscleIcon('anterior_deltoid'), contains('anterior-deltoid.webp'));
    expect(b.equipmentIcon('ez_bar'), contains('ez-bar.webp'));
  });

  test('single-pose exercises expose a lone "main" frame', () async {
    final b = await Bundle.load();
    final single = b.exercises.firstWhere((e) => e.isSinglePose);
    expect(single.flatVariants, ['main']);
    expect(single.imagePath('main'),
        'assets/images/flat/${single.imageBaseId}-main.webp');
    // The catalog card / hero falls back to the lone pose.
    expect(single.heroImagePath, single.imagePath('main'));
    // start/peak simply aren't shipped — no empty-box crash path.
    expect(single.imagePath('peak'), isNull);
    expect(single.imagePath('start'), isNull);
  });

  test('aliased variations resolve image paths to their base slug', () async {
    final b = await Bundle.load();
    final alias = b.findById('pause-deadlift');
    expect(alias, isNotNull);
    expect(alias!.imageAlias, 'deadlift');
    expect(alias.imageBaseId, 'deadlift');
    expect(alias.imagePath('peak'), 'assets/images/flat/deadlift-peak.webp');
  });

  test('Standard-tier animation samples are derived from bundled assets', () async {
    final b = await Bundle.load();
    expect(
      b.sampleAnimationSlugs,
      containsAll(<String>{'bent-over-db-row'}),
    );
    // Each derived slug resolves to a bundled animation asset path.
    for (final slug in b.sampleAnimationSlugs) {
      expect(
        b.findById(slug)?.sampleAnimationPath ?? 'assets/images/samples/$slug.webp',
        'assets/images/samples/$slug.webp',
      );
    }
  });
}
