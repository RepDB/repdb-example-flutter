import 'dart:convert';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import '../models/exercise.dart';

/// A muscle or equipment entry from the bundle taxonomy.
class TaxonomyEntry {
  TaxonomyEntry({required this.nameEn, this.nameDe, this.nameEs, this.image});

  final String nameEn;
  final String? nameDe;
  final String? nameEs;
  final String? image;

  factory TaxonomyEntry.fromJson(Map<String, dynamic> j) => TaxonomyEntry(
        nameEn: (j['name_en'] as String?) ?? '',
        nameDe: j['name_de'] as String?,
        nameEs: j['name_es'] as String?,
        image: j['image'] as String?,
      );

  String label(String locale) {
    switch (locale) {
      case 'de':
        return (nameDe?.isNotEmpty ?? false) ? nameDe! : nameEn;
      case 'es':
        return (nameEs?.isNotEmpty ?? false) ? nameEs! : nameEn;
      default:
        return nameEn;
    }
  }
}

/// Loads `assets/exercises.json` at app start (exercises + taxonomy).
class Bundle {
  Bundle._({
    required this.exercises,
    required this.muscles,
    required this.equipment,
    required this.sampleSlugs,
    required this.sampleAnimationSlugs,
  });

  final List<Exercise> exercises;
  final Map<String, TaxonomyEntry> muscles;
  final Map<String, TaxonomyEntry> equipment;

  /// Slugs that ship Standard-tier still previews under
  /// `assets/images/samples/` (`<slug>-start.webp` / `<slug>-peak.webp`).
  /// Derived from the bundled assets — the single source of truth, so the
  /// detail screen's premium block never hardcodes the list.
  final Set<String> sampleSlugs;

  /// Subset of [sampleSlugs] that also ship a looping animation preview
  /// (`<slug>.webp` with no `-start`/`-peak` suffix).
  final Set<String> sampleAnimationSlugs;

  static Bundle? _cached;

  /// The loaded bundle. Safe to read from any screen — `load()` runs and
  /// completes before the first screen builds (see main.dart's FutureBuilder).
  static Bundle get instance => _cached!;

  static Map<String, TaxonomyEntry> _taxonomy(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map((k, v) =>
        MapEntry(k.toString(), TaxonomyEntry.fromJson(v as Map<String, dynamic>)));
  }

  /// Scans the bundled `assets/images/samples/` directory once so the set of
  /// "Standard tier preview" exercises is derived, never duplicated in code.
  static Future<(Set<String>, Set<String>)> _sampleSets() async {
    const dir = 'assets/images/samples/';
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final stills = <String>{};
    final animations = <String>{};
    for (final key in manifest.listAssets()) {
      if (!key.startsWith(dir) || !key.endsWith('.webp')) continue;
      final name = key.substring(dir.length, key.length - '.webp'.length);
      if (name.endsWith('-start')) {
        stills.add(name.substring(0, name.length - '-start'.length));
      } else if (name.endsWith('-peak')) {
        stills.add(name.substring(0, name.length - '-peak'.length));
      } else {
        animations.add(name); // bare "<slug>.webp" → looping animation
      }
    }
    return (stills, animations);
  }

  static Future<Bundle> load() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('assets/exercises.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = (json['exercises'] as List)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
    final (stills, animations) = await _sampleSets();
    _cached = Bundle._(
      exercises: list,
      muscles: _taxonomy(json['muscles']),
      equipment: _taxonomy(json['equipment']),
      sampleSlugs: stills,
      sampleAnimationSlugs: animations,
    );
    return _cached!;
  }

  Exercise? findById(String id) {
    for (final e in exercises) {
      if (e.id == id) return e;
    }
    return null;
  }

  // --- Taxonomy lookups (used by the detail screen). Fall back gracefully
  // when an entry is missing so the UI never crashes on unknown keys. ---

  String muscleLabel(String key, String locale) =>
      muscles[key]?.label(locale) ?? _pretty(key);

  String? muscleIcon(String key) {
    final img = muscles[key]?.image;
    return img == null ? null : 'assets/images/muscles/$img';
  }

  String equipmentLabel(String key, String locale) =>
      equipment[key]?.label(locale) ?? _pretty(key);

  String? equipmentIcon(String key) {
    final img = equipment[key]?.image;
    return img == null ? null : 'assets/images/equipment/$img';
  }

  static String _pretty(String v) => v
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
