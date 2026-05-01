import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.locale,
    required this.onTap,
  });

  final Exercise exercise;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final peakPath = exercise.imagePath('peak');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Hero(
                tag: 'exercise-${exercise.id}',
                child: Container(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.30),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  child: peakPath != null
                      ? Image.asset(peakPath, fit: BoxFit.contain)
                      : Icon(
                          Icons.fitness_center,
                          size: 36,
                          color: theme.colorScheme.outline,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name(locale),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (exercise.bodyPart != null)
                        _Chip(label: prettyEnum(exercise.bodyPart)),
                      if (exercise.equipment != null)
                        _Chip(label: prettyEnum(exercise.equipment)),
                      if (exercise.difficulty != null)
                        _Chip(label: prettyEnum(exercise.difficulty)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          color: scheme.onSurfaceVariant,
          height: 1.2,
        ),
      ),
    );
  }
}
