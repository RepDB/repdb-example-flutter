/// A single exercise from the RepDB free bundle.
///
/// We deliberately keep this typed-but-thin: the bundle's JSON is loaded
/// once at app start and read directly. No code generation, no codegen
/// runner — easy to fork.
///
/// The free tier ships **flat** (white-background) stills only. Two visual
/// styles, transparent backgrounds and animations are Standard-tier extras;
/// this demo previews them for a handful of `Bundle.sampleSlugs` exercises
/// via `assets/images/samples/` (see the detail screen's "Standard tier
/// preview" block).
class Exercise {
  final String id;
  final String nameEn;
  final String? nameDe;
  final String? nameEs;
  final String category;
  final String? difficulty;
  final String? equipment;
  final String? bodyPart;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructionsEn;
  final List<String> instructionsDe;
  final List<String> instructionsEs;

  /// Available image variants per style, e.g. `{"flat": ["start", "peak"]}`.
  /// A single-pose exercise ships `{"flat": ["main"]}`.
  final Map<String, List<String>> images;

  /// Some variations (e.g. `pause-deadlift`) reuse a base exercise's images
  /// instead of shipping duplicates. When set, image asset paths resolve
  /// against this base slug rather than [id].
  final String? imageAlias;

  final double? met;

  Exercise._({
    required this.id,
    required this.nameEn,
    this.nameDe,
    this.nameEs,
    required this.category,
    this.difficulty,
    this.equipment,
    this.bodyPart,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructionsEn,
    required this.instructionsDe,
    required this.instructionsEs,
    required this.images,
    this.imageAlias,
    this.met,
  });

  factory Exercise.fromJson(Map<String, dynamic> j) {
    List<String> strList(dynamic v) =>
        v is List ? List<String>.from(v.whereType<String>()) : const [];

    final imagesRaw = j['images'];
    final images = <String, List<String>>{};
    if (imagesRaw is Map) {
      imagesRaw.forEach((k, v) {
        if (v is List) {
          images[k.toString()] = List<String>.from(v.whereType<String>());
        }
      });
    }

    return Exercise._(
      id: j['id'] as String,
      nameEn: j['name_en'] as String,
      nameDe: j['name_de'] as String?,
      nameEs: j['name_es'] as String?,
      category: (j['category'] as String?) ?? 'strength',
      difficulty: j['difficulty'] as String?,
      equipment: j['equipment'] as String?,
      bodyPart: j['body_part'] as String?,
      primaryMuscles: strList(j['primary_muscles']),
      secondaryMuscles: strList(j['secondary_muscles']),
      instructionsEn: strList(j['instructions_en']),
      instructionsDe: strList(j['instructions_de']),
      instructionsEs: strList(j['instructions_es']),
      images: images,
      imageAlias: j['image_alias'] as String?,
      met: (j['met'] as num?)?.toDouble(),
    );
  }

  /// Localised name with English fallback.
  String name(String locale) {
    switch (locale) {
      case 'de':
        return (nameDe?.isNotEmpty ?? false) ? nameDe! : nameEn;
      case 'es':
        return (nameEs?.isNotEmpty ?? false) ? nameEs! : nameEn;
      default:
        return nameEn;
    }
  }

  /// Localised instructions with English fallback.
  List<String> instructions(String locale) {
    switch (locale) {
      case 'de':
        return instructionsDe.isNotEmpty ? instructionsDe : instructionsEn;
      case 'es':
        return instructionsEs.isNotEmpty ? instructionsEs : instructionsEn;
      default:
        return instructionsEn;
    }
  }

  /// Slug the flat image assets are actually named after (resolves
  /// [imageAlias] so aliased variations point at their base exercise's files).
  String get imageBaseId => imageAlias ?? id;

  /// The flat variants this exercise ships: `['start', 'peak']`, or `['main']`
  /// for a single-pose exercise.
  List<String> get flatVariants => images['flat'] ?? const [];

  /// Asset path for a flat (white-background) frame, or null if that variant
  /// isn't shipped for this exercise.
  String? imagePath(String variant) {
    if (!flatVariants.contains(variant)) return null;
    return 'assets/images/flat/$imageBaseId-$variant.webp';
  }

  /// A single representative flat frame — peak, else the lone `main`, else
  /// start. Used for the catalog card and hero. Null only if no flat art.
  String? get heroImagePath =>
      imagePath('peak') ?? imagePath('main') ?? imagePath('start');

  /// True when this exercise ships a single `main` pose rather than
  /// start + peak (47 of the 400 free exercises).
  bool get isSinglePose => flatVariants.length == 1 && flatVariants.first == 'main';

  /// Asset path for a Standard-tier sample frame (transparent matte-clay
  /// preview). Only valid for [Bundle.sampleSlugs]; those are never aliased.
  String samplePath(String variant) => 'assets/images/samples/$id-$variant.webp';

  /// Asset path for a Standard-tier looping animation preview. Only valid for
  /// [Bundle.sampleAnimationSlugs]. Flutter decodes animated WebP natively.
  String get sampleAnimationPath => 'assets/images/samples/$id.webp';

  /// Substring match used by the catalog search bar.
  bool matchesQuery(String q) {
    final needle = q.trim().toLowerCase();
    if (needle.isEmpty) return true;
    if (nameEn.toLowerCase().contains(needle)) return true;
    if ((nameDe ?? '').toLowerCase().contains(needle)) return true;
    if ((nameEs ?? '').toLowerCase().contains(needle)) return true;
    if ((bodyPart ?? '').toLowerCase().contains(needle)) return true;
    if ((equipment ?? '').toLowerCase().contains(needle)) return true;
    return false;
  }
}

/// Render `upper_arms` as `Upper Arms`, etc.
String prettyEnum(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  return raw
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
