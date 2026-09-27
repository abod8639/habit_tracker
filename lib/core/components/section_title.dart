import 'package:flutter/material.dart';

/// A reusable generic section title widget for dividing screens and settings panels.
class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;
  final TextStyle? style;

  const SectionTitle({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Text(
        title,
        style: style ??
            theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ) ??
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
