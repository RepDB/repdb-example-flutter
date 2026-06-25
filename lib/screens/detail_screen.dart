import 'package:flutter/material.dart';
import '../data/bundle.dart';
import '../models/exercise.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.exercise, required this.locale});

  final Exercise exercise;
  final String locale;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String _style = 'flat';

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final locale = widget.locale;
    final tax = Bundle.instance;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = exercise.name(locale);
    final instructions = exercise.instructions(locale);
    final start = exercise.imagePath('start', style: _style);
    final peak = exercise.imagePath('peak', style: _style);
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
          if (exercise.hasBothStyles) ...[
            _StyleToggle(value: _style, onChanged: (s) => setState(() => _style = s)),
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

class _StyleToggle extends StatelessWidget {
  const _StyleToggle({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          'STYLE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.0,
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(width: 10),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'flat', label: Text('Flat')),
            ButtonSegment(value: 'classic', label: Text('Classic')),
          ],
          selected: {value},
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    );
  }
}

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
