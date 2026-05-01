import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/exercise.dart';

/// Loads `assets/exercises.json` at app start.
class Bundle {
  Bundle._({required this.exercises});

  final List<Exercise> exercises;

  static Bundle? _cached;

  static Future<Bundle> load() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('assets/exercises.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = (json['exercises'] as List)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
    _cached = Bundle._(exercises: list);
    return _cached!;
  }

  Exercise? findById(String id) {
    for (final e in exercises) {
      if (e.id == id) return e;
    }
    return null;
  }
}
