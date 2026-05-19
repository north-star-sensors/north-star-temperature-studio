import 'package:flutter/material.dart';

class OutputMetricCard extends StatelessWidget {
  const OutputMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.normalized,
    this.color,
  });

  final String title;
  final String value;
  final String? subtitle;
  final double? normalized;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: theme.textTheme.bodySmall),
            ],
            if (normalized != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: normalized!.clamp(0.0, 1.0),
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
