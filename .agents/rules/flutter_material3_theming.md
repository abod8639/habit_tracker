# Flutter Material 3 & Semantic Theming Standards

## Guidelines for Flutter UI
* **Design Pattern (Material 3):**
  - Strictly adhere to Material 3 design patterns: use rounded surfaces (`BorderRadius.circular(16)`), subtle borders (`outlineVariant`), and tonal containers over harsh drop shadows.
  - Rely exclusively on semantic `Theme.of(context).colorScheme` tokens (`surfaceContainer`, `surfaceContainerHighest`, `onSurface`, `onSurfaceVariant`) instead of inverted or hardcoded colors (e.g., never use `onSecondary` as container background).
  - Extract UI elements into standalone `StatelessWidget` components rather than helper methods returning widgets to optimize rebuilds and adhere to Clean Architecture.
