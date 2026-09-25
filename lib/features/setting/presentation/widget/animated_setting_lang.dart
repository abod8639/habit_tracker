import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final primaryColor = textColor ?? theme.primaryColor;

  final Animation<double> animation = CurvedAnimation(
    parent: animationController,
    curve: Interval(
      0.05 * (index % 10),
      math.min(0.05 * (index % 10) + 0.5, 1.0),
      curve: Curves.easeOut,
    ),
  );

  // Dual ambient Neumorphic shadows
  final List<BoxShadow> outerShadows = [
    BoxShadow(
      color: isDark
          ? Colors.white.withValues(alpha: 0.045)
          : Colors.white.withValues(alpha: 0.90),
      offset: const Offset(-3.5, -3.5),
      blurRadius: 7,
    ),
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.45)
          : const Color(0xFFA3B1C6).withValues(alpha: 0.38),
      offset: const Offset(3.5, 3.5),
      blurRadius: 7,
    ),
  ];

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
            borderRadius: BorderRadius.circular(20),
            gradient: gradient,
            boxShadow: outerShadows,
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
                      primaryColor.withValues(alpha: isDark ? 0.14 : 0.09),
                      baseSurface,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.035)
                            : Colors.white.withValues(alpha: 0.85),
                        offset: const Offset(-2, -2),
                        blurRadius: 3,
                      ),
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.35)
                            : const Color(0xFFA3B1C6).withValues(alpha: 0.30),
                        offset: const Offset(2, 2),
                        blurRadius: 3,
                      ),
                    ],
                    border: Border.all(
                      color: primaryColor.withValues(alpha: isDark ? 0.20 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: currentValue,
                    decoration: const InputDecoration(
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
                    borderRadius: BorderRadius.circular(16),
                    icon: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.alphaBlend(
                          colorScheme.onSurface.withValues(alpha: isDark ? 0.04 : 0.02),
                          baseSurface,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.03)
                                : Colors.white.withValues(alpha: 0.75),
                            offset: const Offset(-1.5, -1.5),
                            blurRadius: 2.5,
                          ),
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : const Color(0xFFA3B1C6).withValues(alpha: 0.25),
                            offset: const Offset(1.5, 1.5),
                            blurRadius: 2.5,
                          ),
                        ],
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
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                    onChanged: (value) {
                      Get.showOverlay(
                        asyncFunction: () async {
                          await Future.delayed(const Duration(milliseconds: 100));
                          onChanged(value);
                        },
                        loadingWidget: const SizedBox(),
                        opacityColor: Colors.transparent,
                        opacity: 0,
                      );
                    },
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
