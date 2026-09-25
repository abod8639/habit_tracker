import 'package:flutter/material.dart';

/// Reusable Neumorphic AI coach avatar with soft lighting, dual shadows,
/// and smooth rounded corners.
class AiAvatar extends StatelessWidget {
  final double size;
  final bool useHero;

  const AiAvatar({
    super.key,
    this.size = 40,
    this.useHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    final avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.alphaBlend(Colors.white.withValues(alpha: 0.15), primary),
            secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.4),
          width: 1.2,
        ),
        boxShadow: [
          // Top-left light highlight
          BoxShadow(
            color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.45),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          // Bottom-right soft depth glow
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.45 : 0.35),
            offset: const Offset(2, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          color: theme.colorScheme.onPrimary,
          size: size * 0.5,
        ),
      ),
    );

    if (useHero) {
      return Hero(
        tag: 'ai_coach_avatar',
        child: avatarContent,
      );
    }

    return avatarContent;
  }
}
