/// A single exercise from the RepDB preview bundle.
///
/// We deliberately keep this typed-but-thin: the bundle's JSON is loaded
/// once at app start and read directly. No code generation, no codegen
/// runner — easy to fork.
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
  final Map<String, List<String>> images;
  final bool animation;
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
    required this.animation,
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
      animation: j['animation'] == true,
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

  /// Asset path for a start/peak frame in the given style ('flat' = white
  /// background, 'classic' = transparent matte-clay), or null if unavailable.
  String? imagePath(String variant, {String style = 'flat'}) {
    final list = images[style];
    if (list == null || !list.contains(variant)) return null;
    return 'assets/images/$style/$id-$variant.webp';
  }

  /// True when both flat and classic stills exist (style toggle is meaningful).
  bool get hasBothStyles =>
      (images['flat']?.isNotEmpty ?? false) && (images['classic']?.isNotEmpty ?? false);

  /// Asset path for the looping animated WebP, or null if this exercise
  /// has none. Flutter's Image widget auto-plays multi-frame WebP natively.
  String? get animationPath =>
      animation ? 'assets/images/animations/$id.webp' : null;

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
