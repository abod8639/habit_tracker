import 'package:flutter/material.dart';

class LoginPageIcon extends StatelessWidget {
  final ThemeData theme;
  const LoginPageIcon({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.05) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.50) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.18) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.12) ?? baseColor);

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [surfaceGradientStart, surfaceGradientEnd],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.90),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.95),
                offset: const Offset(-5, -5),
                blurRadius: 10,
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.65)
                    : const Color(0xFFA3B1C6).withValues(alpha: 0.45),
                offset: const Offset(6, 6),
                blurRadius: 12,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.task_alt_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Habit Tracker',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Text(
        //   S.current.login,
        //   style: theme.textTheme.bodyLarge?.copyWith(
        //     color: theme.colorScheme.onSurfaceVariant,
        //     letterSpacing: 0.5,
        //   ),
        //   textAlign: TextAlign.center,
        // ),
      ],
    );
  }
}
