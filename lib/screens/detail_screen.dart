import 'package:flutter/material.dart';
import '../models/exercise.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.exercise, required this.locale});

  final Exercise exercise;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = exercise.name(locale);
    final instructions = exercise.instructions(locale);
    final start = exercise.imagePath('start');
    final peak = exercise.imagePath('peak');
    final animation = exercise.animationPath;

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
            children: [
              if (exercise.bodyPart != null)
                _Tag(prettyEnum(exercise.bodyPart)),
              if (exercise.equipment != null)
                _Tag(prettyEnum(exercise.equipment)),
              if (exercise.difficulty != null)
                _Tag(prettyEnum(exercise.difficulty)),
              _Tag(prettyEnum(exercise.category)),
            ],
          ),
          const SizedBox(height: 16),
          // Looping animation (auto-plays — Flutter decodes animated WebP natively)
          if (animation != null) ...[
            _Frame(
              label: 'Animation · looping',
              assetPath: animation,
              alt: '$name — animation',
              heroTag: null,
            ),
            const SizedBox(height: 12),
          ],
          // Hero start/peak frames
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Frame(
                  label: 'Start',
                  assetPath: start,
                  alt: '$name — start',
                  heroTag: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Frame(
                  label: 'Peak',
                  assetPath: peak,
                  alt: '$name — peak',
                  heroTag: 'exercise-${exercise.id}',
                ),
              ),
            ],
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
                emphasis: false,
              ),
            ),
          ],
        ],
      ),
    );
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
  const _Tag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: scheme.onSurface),
      ),
    );
  }
}

class _MuscleWrap extends StatelessWidget {
  const _MuscleWrap({required this.muscles, required this.emphasis});
  final List<String> muscles;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: muscles.map((m) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          child: Text(
            prettyEnum(m),
            style: TextStyle(
              fontSize: 12,
              color: emphasis ? scheme.primary : scheme.onSurface,
              fontWeight: emphasis ? FontWeight.w600 : FontWeight.w400,
            ),
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
