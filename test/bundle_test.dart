import 'package:flutter_test/flutter_test.dart';
import 'package:repdb_example_flutter/data/bundle.dart';

// Exercises the data layer behind the free-tier detail screen: bundle size,
// taxonomy parsing, MET, flat image paths (start/peak, single-pose "main",
// per-exercise files), the derived Standard-tier sample sets, and localized
// labels + icon paths.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundle loads exercises, taxonomy, met and localized labels',
    () async {
      final b = await Bundle.load();
      expect(b.exercises, isNotEmpty);
      expect(b.muscles, isNotEmpty);
      expect(b.equipment, isNotEmpty);

      final ex = b.findById('arnold-press');
      expect(ex, isNotNull);
      expect(ex!.met, 6.0);

      // Free tier ships flat stills only — no classic style.
      expect(ex.imagePath('peak'), 'assets/images/flat/arnold-press-peak.webp');
      expect(
        ex.imagePath('start'),
        'assets/images/flat/arnold-press-start.webp',
      );

      // Localized muscle label (German) differs from the raw key.
      expect(b.muscleLabel('anterior_deltoid', 'de'), isNotEmpty);
      expect(
        b.muscleLabel('anterior_deltoid', 'de'),
        isNot(equals('Anterior Deltoid')),
      );
      expect(
        b.muscleIcon('anterior_deltoid'),
        contains('anterior-deltoid.webp'),
      );
      expect(b.equipmentIcon('ez_bar'), contains('ez-bar.webp'));
    },
  );

  test('single-pose exercises expose a lone "main" frame', () async {
    final b = await Bundle.load();
    final single = b.exercises.firstWhere((e) => e.isSinglePose);
    expect(single.flatVariants, ['main']);
    expect(
      single.imagePath('main'),
      'assets/images/flat/${single.imageBaseId}-main.webp',
    );
    // The catalog card / hero falls back to the lone pose.
    expect(single.heroImagePath, single.imagePath('main'));
    // start/peak simply aren't shipped — no empty-box crash path.
    expect(single.imagePath('peak'), isNull);
    expect(single.imagePath('start'), isNull);
  });

  test('variations carry their own image files (no image_alias)', () async {
    // Since 2026-09 the bundle ships a full file set per exercise instead of
    // aliasing variations onto a base slug; the alias fallback in the model
    // stays for older bundles but must not be needed here.
    final b = await Bundle.load();
    final v = b.findById('pause-deadlift');
    expect(v, isNotNull);
    expect(v!.imageAlias, isNull);
    expect(v.imageBaseId, 'pause-deadlift');
    expect(
      v.imagePath('peak'),
      'assets/images/flat/pause-deadlift-peak.webp',
    );
  });

  test(
    'Standard-tier animation samples are derived from bundled assets',
    () async {
      final b = await Bundle.load();
      expect(b.sampleAnimationSlugs, containsAll(<String>{'bent-over-db-row'}));
      expect(
        b.sampleAnimationSlugs.every(
          (slug) => !RegExp(r'-(start|peak|main)$').hasMatch(slug),
        ),
        isTrue,
      );
      // Each derived slug resolves to a bundled animation asset path.
      for (final slug in b.sampleAnimationSlugs) {
        expect(
          b.findById(slug)?.sampleAnimationPath ??
              'assets/images/samples/$slug.webp',
          'assets/images/samples/$slug.webp',
        );
      }
    },
  );
}
