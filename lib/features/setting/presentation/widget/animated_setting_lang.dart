import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

Widget buildAnimatedSettingLang(
  BuildContext context, {
  required AnimationController animationController,
  required int index,
  required IconData icon,
  required String currentValue,
  required List<DropdownMenuEntry<String>> entries,
  required Function(String?) onChanged,
  Color? textColor,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  final baseSurface = theme.cardColor;
  // final primaryColosr = textColor ?? theme.primaryColor;

  final Animation<double> animation = CurvedAnimation(
    parent: animationController,
    curve: Interval(
      0.05 * (index % 10),
      math.min(0.05 * (index % 10) + 0.5, 1.0),
      curve: Curves.easeOut,
    ),
  );

  // Subtle convex gradient
  final Gradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      baseSurface,
      Color.alphaBlend(
        isDark
            ? Colors.black.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.03),
        baseSurface,
      ),
    ],
  );

  final Border border = Border.all(
    color: isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.70),
    width: 1.0,
  );

  return FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.25, 0),
        end: Offset.zero,
      ).animate(animation),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            color: baseSurface,
            borderRadius: AppRadius.badgeRadius,
            gradient: gradient,
            boxShadow: AppShadows.badge(isDark: isDark),
            border: border,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Neumorphic Icon Badge
                Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          theme.primaryColor.withValues(alpha: isDark ? 0.14 : 0.09),
          baseSurface,
        ),
        borderRadius: AppRadius.mdRadius,
        boxShadow: AppShadows.dotIndicator(isDark: isDark),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: isDark ? 0.20 : 0.15),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          shadows: AppShadows.buttonPressed(isDark: isDark),
          icon,
          color: theme.primaryColor,
          size: 22,
        ),
      ),
    ),
                // Container(
                //   width: 44,
                //   height: 44,
                //   decoration: BoxDecoration(
                //     color: Color.alphaBlend(
                //       primaryColor.withValues(alpha: isDark ? 0.14 : 0.09),
                //       baseSurface,
                //     ),
                //     borderRadius: AppRadius.mdRadius,
                //     boxShadow: AppShadows.dotIndicator(isDark: isDark),
                //     border: Border.all(
                //       color: theme.primaryColor,
                //       width: 0.5,
                //     ),
                //   ),
                //   child: Center(
                //     child: Icon(
                //       icon,
                //       color: theme.primaryColor,
                //       size: 22,
                //     ),
                //   ),
                // ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(

                    initialValue: currentValue,
                    iconEnabledColor: Colors.transparent,
                    iconDisabledColor: Colors.transparent ,
                    focusColor: Colors.transparent,
                    decoration:  InputDecoration(

                      // iconColor: theme.primaryColor,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.5,
                      letterSpacing: 0.2,
                      color: textColor ?? colorScheme.onSurface,
                    ),
                    dropdownColor: baseSurface,
                    borderRadius: AppRadius.lgRadius,
                    icon: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.alphaBlend(
                          colorScheme.onSurface.withValues(alpha: isDark ? 0.04 : 0.02),
                          baseSurface,
                        ),
                        boxShadow: AppShadows.dotIndicator(isDark: isDark),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.white.withValues(alpha: 0.6),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    items: entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.value,
                            child: Text(entry.label),
                          ),
                        )
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
