import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? accentColor;
  final List<BoxShadow>? customShadows;
  final Color? color;

  const SoftCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppRadius.card,
    this.onTap,
    this.isSelected = false,
    this.accentColor,
    this.customShadows,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = color ?? theme.cardColor;

    final Color surfaceGradientStart =
        ThemeUtils.surfaceGradientStart(baseColor, isDark);

    final Color surfaceGradientEnd =
        ThemeUtils.surfaceGradientEnd(baseColor, isDark);

    final effectiveAccent = accentColor ?? theme.colorScheme.primary;

    final Color borderColor = isSelected
        ? effectiveAccent.withValues(alpha: isDark ? 0.60 : 0.45)
        : ThemeUtils.subtleBorderColor(isDark);

    final effectiveShadows =
        customShadows ??
        (isSelected
            ? AppShadows.selectedCard(primary: effectiveAccent, isDark: isDark)
            : AppShadows.softCard(isDark: isDark));

    Widget card = Container(
      margin:
          margin ?? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isSelected
                ? Color.alphaBlend(
                    effectiveAccent.withValues(alpha: isDark ? 0.12 : 0.08),
                    surfaceGradientStart,
                  )
                : surfaceGradientStart,
            isSelected
                ? Color.alphaBlend(
                    effectiveAccent.withValues(alpha: isDark ? 0.18 : 0.10),
                    surfaceGradientEnd,
                  )
                : surfaceGradientEnd,
          ],
        ),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 1.6 : 1.2,
        ),
        boxShadow: effectiveShadows,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(18.0),
        child: child,
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
