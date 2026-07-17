import 'package:flutter/material.dart';
import '../data/bundle.dart';
import '../models/exercise.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.exercise, required this.locale});

  final Exercise exercise;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final tax = Bundle.instance;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = exercise.name(locale);
    final instructions = exercise.instructions(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Tags row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (exercise.bodyPart != null)
                _Tag(prettyEnum(exercise.bodyPart)),
              if (exercise.equipment != null)
                _Tag(
                  tax.equipmentLabel(exercise.equipment!, locale),
                  iconAsset: tax.equipmentIcon(exercise.equipment!),
                ),
              if (exercise.difficulty != null)
                _Tag(prettyEnum(exercise.difficulty)),
              _Tag(prettyEnum(exercise.category)),
              if (exercise.met != null)
                _Tag('MET · ${_fmtMet(exercise.met!)}'),
            ],
          ),
          const SizedBox(height: 16),
          // Flat (white-background) still frames: start + peak, or a lone
          // "main" pose for single-pose exercises. The free tier ships flat
          // stills only — animations are a paid extra, previewed in the
          // catalog screen's "Standard tier preview" gallery.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _frames(exercise, name),
          ),
          if (instructions.isNotEmpty) ...[
            const SizedBox(height: 24),
            _Card(
              title: 'INSTRUCTIONS',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < instructions.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 22,
                            child: Text(
                              '${i + 1}.',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              instructions[i],
                              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (exercise.primaryMuscles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Card(
              title: 'PRIMARY MUSCLES',
              child: _MuscleWrap(
                muscles: exercise.primaryMuscles,
                locale: locale,
                emphasis: true,
              ),
            ),
          ],
          if (exercise.secondaryMuscles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Card(
              title: 'SECONDARY MUSCLES',
              child: _MuscleWrap(
                muscles: exercise.secondaryMuscles,
                locale: locale,
                emphasis: false,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the flat still-frame children for the image row.
  ///
  /// - Single-pose free exercise (`{"flat": ["main"]}`) → one lone frame,
  ///   so the start/peak path never renders an empty box.
  /// - Otherwise → flat start + peak.
  ///
  /// The peak (or the single main) frame carries the shared hero tag — that's
  /// the image the catalog card animates into.
  List<Widget> _frames(Exercise exercise, String name) {
    if (exercise.isSinglePose) {
      return [
        Expanded(
          child: _Frame(
            label: 'Pose',
            assetPath: exercise.imagePath('main'),
            alt: name,
            heroTag: 'exercise-${exercise.id}',
          ),
        ),
      ];
    }
    return [
      Expanded(
        child: _Frame(
          label: 'Start',
          assetPath: exercise.imagePath('start'),
          alt: '$name — start',
          heroTag: null,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _Frame(
          label: 'Peak',
          assetPath: exercise.imagePath('peak'),
          alt: '$name — peak',
          heroTag: 'exercise-${exercise.id}',
        ),
      ),
    ];
  }
}

class _Frame extends StatelessWidget {
  const _Frame({
    required this.label,
    required this.assetPath,
    required this.alt,
    required this.heroTag,
  });

  final String label;
  final String? assetPath;
  final String alt;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final image = AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        color: scheme.primaryContainer.withValues(alpha: 0.30),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: assetPath != null
            ? Image.asset(assetPath!, fit: BoxFit.contain, semanticLabel: alt)
            : Icon(Icons.image_not_supported, color: scheme.outline),
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (heroTag != null) Hero(tag: heroTag!, child: image) else image,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.0,
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {this.iconAsset});
  final String label;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(iconAsset != null ? 5 : 8, 4, 8, 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconAsset != null) ...[
            Image.asset(iconAsset!, width: 16, height: 16, fit: BoxFit.contain),
            const SizedBox(width: 5),
          ],
          Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurface)),
        ],
      ),
    );
  }
}

/// Whole-number METs render without a trailing ".0".
String _fmtMet(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

class _MuscleWrap extends StatelessWidget {
  const _MuscleWrap({
    required this.muscles,
    required this.locale,
    required this.emphasis,
  });
  final List<String> muscles;
  final String locale;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tax = Bundle.instance;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: muscles.map((m) {
        final icon = tax.muscleIcon(m);
        return Container(
          padding: EdgeInsets.fromLTRB(icon != null ? 6 : 10, 5, 10, 5),
          decoration: BoxDecoration(
            color: emphasis
                ? scheme.primary.withValues(alpha: 0.13)
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: emphasis
                  ? scheme.primary.withValues(alpha: 0.35)
                  : scheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Image.asset(icon, width: 16, height: 16, fit: BoxFit.contain),
                const SizedBox(width: 5),
              ],
              Text(
                tax.muscleLabel(m, locale),
                style: TextStyle(
                  fontSize: 12,
                  color: emphasis ? scheme.primary : scheme.onSurface,
                  fontWeight: emphasis ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
