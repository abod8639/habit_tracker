import 'package:flutter/material.dart';

/// Centralized shadow controller and Neumorphic lighting engine.
/// Unifies lighting angles, depth, blur radii, and responsive contrast
/// across both Dark and Light themes.
abstract final class AppShadows {
  // ── Unified Shadow Color Tokens ───────────────────────────────────────────

  /// Top-left ambient highlight color that mimics natural light reflection.
  static Color lightShadowColor(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.90);
  }

  /// Bottom-right depth shadow color that creates tactile physical depth.
  static Color darkShadowColor(bool isDark) {
    return isDark
        ? Colors.black.withValues(alpha: 0.65)
        : const Color(0xFFA3B1C6).withValues(alpha: 0.35);
  }

  // ── Unified Shadow Presets ────────────────────────────────────────────────

  /// Raised Soft Card dual shadows (used by [SoftCard], stats cards, etc.).
  static List<BoxShadow> softCard({required bool isDark}) {
    return [
      BoxShadow(
        color: lightShadowColor(isDark),
        offset: const Offset(-5, -5),
        blurRadius: 12,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: darkShadowColor(isDark),
        offset: const Offset(6, 6),
        blurRadius: 14,
        spreadRadius: 1,
      ),
    ];
  }

  /// Subtle card dual shadows for resting/unselected state.
  static List<BoxShadow> subtleCard({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.90),
        offset: const Offset(-4, -4),
        blurRadius: 10,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.50)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.32),
        offset: const Offset(4, 4),
        blurRadius: 10,
      ),
    ];
  }

  /// Recessed / debossed well shadow for inner containers, HeatMap wells, and chips.
  static List<BoxShadow> insetWell({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.30)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.20),
        offset: const Offset(1.5, 1.5),
        blurRadius: 3,
      ),
    ];
  }

  /// Dual lighting shadows for recessed wells with subtle top highlight.
  static List<BoxShadow> wellDual({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.85),
        offset: const Offset(-2, -2),
        blurRadius: 5,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.45)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.30),
        offset: const Offset(2.5, 2.5),
        blurRadius: 5,
      ),
    ];
  }

  /// Radiant accent bloom for highlighted, active, or selected elements.
  static List<BoxShadow> bloom({
    required Color color,
    required bool isDark,
    double blur = 18.0,
    double spread = 1.0,
    Offset offset = const Offset(0, 6),
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: isDark ? 0.35 : 0.25),
        blurRadius: blur,
        offset: offset,
        spreadRadius: spread,
      ),
    ];
  }

  /// Triple shadow set for selected cards (Radiant bloom + ambient highlight + depth).
  static List<BoxShadow> selectedCard({
    required Color primary,
    required bool isDark,
  }) {
    return [
      // Radiant Neumorphic primary bloom
      BoxShadow(
        color: primary.withValues(alpha: isDark ? 0.35 : 0.25),
        blurRadius: 18,
        offset: const Offset(0, 6),
        spreadRadius: 1,
      ),
      // Ambient highlight
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.90),
        offset: const Offset(-3, -3),
        blurRadius: 8,
      ),
      // Ambient depth
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.45)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.30),
        offset: const Offset(3, 3),
        blurRadius: 8,
      ),
    ];
  }

  /// Pill/Badge dual lighting shadow.
  static List<BoxShadow> badge({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.85),
        offset: const Offset(-1.5, -1.5),
        blurRadius: 3.5,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.40)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.28),
        offset: const Offset(2.0, 2.0),
        blurRadius: 4.0,
      ),
    ];
  }

  /// Resting tactile button shadows.
  static List<BoxShadow> buttonResting({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.white.withValues(alpha: 0.70),
        offset: const Offset(-2.5, -2.5),
        blurRadius: 6,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.50)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.32),
        offset: const Offset(3, 3),
        blurRadius: 6,
      ),
    ];
  }

  /// Pressed button inset shadow.
  static List<BoxShadow> buttonPressed({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.40)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.30),
        offset: const Offset(1.5, 1.5),
        blurRadius: 3,
      ),
    ];
  }

  /// Dual micro shadows for dot indicators and tiny circular markers.
  static List<BoxShadow> dotIndicator({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.45)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.35),
        offset: const Offset(1, 1),
        blurRadius: 2,
      ),
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.80),
        offset: const Offset(-0.8, -0.8),
        blurRadius: 1.5,
      ),
    ];
  }

  /// Active dot badge glow.
  static List<BoxShadow> activeDot({required Color color}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.40),
        blurRadius: 4,
        spreadRadius: 1,
      ),
    ];
  }
}
