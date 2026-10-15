import 'package:flutter/material.dart';

/// Centralized shadow controller and Neumorphic lighting engine.
/// Unifies lighting angles, depth, blur radii, and responsive contrast
/// across both Dark and Light themes with sharp, crisp, tactile definitions.
abstract final class AppShadows {
  // ── Unified Shadow Color Tokens ───────────────────────────────────────────

  /// Top-left ambient highlight color that mimics natural light reflection.
  static Color lightShadowColor(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.70);
  }

  /// Bottom-right depth shadow color that creates tactile physical depth.
  static Color darkShadowColor(bool isDark) {
    return isDark
        ? Colors.black.withValues(alpha: 0.70)
        : const Color(0xFFA3B1C6).withValues(alpha: 0.22);
  }

  // ── Unified Shadow Presets ────────────────────────────────────────────────

  /// Raised Soft Card dual shadows with smooth feathered depth.
  static List<BoxShadow> softCard({required bool isDark}) {
    return [
      BoxShadow(
        color: lightShadowColor(isDark),
        offset: isDark ? const Offset(-1, -1) : const Offset(-2.5, -2.5),
        blurRadius: isDark ? 3.0 : 6.0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: darkShadowColor(isDark),
        offset: isDark ? const Offset(2, 2) : const Offset(3.0, 3.0),
        blurRadius: isDark ? 3.0 : 6.5,
        spreadRadius: 0,
      ),
    ];
  }

  /// Subtle card dual shadows with crisp, clean definition for resting state.
  static List<BoxShadow> subtleCard({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.65),
        offset: isDark ? const Offset(-2, -2) : const Offset(-2.5, -2.5),
        blurRadius: isDark ? 4.5 : 7.0,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.55)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.20),
        offset: isDark ? const Offset(3, 3) : const Offset(3.5, 3.5),
        blurRadius: isDark ? 5.0 : 7.5,
      ),
    ];
  }

  /// Recessed / debossed well shadow for inner containers, HeatMap wells, and chips.
  static List<BoxShadow> insetWell({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.18),
        offset: isDark ? const Offset(1.2, 1.2) : const Offset(1.5, 1.5),
        blurRadius: isDark ? 2.2 : 3.5,
      ),
    ];
  }

  /// Dual lighting shadows for recessed wells with smooth, diffused definition.
  static List<BoxShadow> wellDual({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.65),
        offset: isDark ? const Offset(-1.5, -1.5) : const Offset(-2.0, -2.0),
        blurRadius: isDark ? 3.0 : 4.5,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.50)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.20),
        offset: const Offset(2.0, 2.0),
        blurRadius: isDark ? 3.5 : 4.5,
      ),
    ];
  }

  /// Radiant accent bloom for highlighted, active, or selected elements.
  static List<BoxShadow> bloom({
    required Color color,
    required bool isDark,
    double blur = 7.0,
    double spread = 0.5,
    Offset offset = const Offset(0, 2.0),
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: isDark ? 0.48 : 0.20),
        blurRadius: isDark ? blur : blur + 2.0,
        offset: offset,
        spreadRadius: spread,
      ),
    ];
  }

  /// Triple shadow set for selected cards (Soft radiant bloom + ambient highlight + depth).
  static List<BoxShadow> selectedCard({
    required Color primary,
    required bool isDark,
  }) {
    return [
      // Soft radiant Neumorphic primary bloom
      BoxShadow(
        color: primary.withValues(alpha: isDark ? 0.48 : 0.22),
        blurRadius: isDark ? 8 : 10,
        offset: const Offset(0, 2.5),
        spreadRadius: isDark ? 0.5 : 0.0,
      ),
      // Ambient highlight
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.70),
        offset: isDark ? const Offset(-2, -2) : const Offset(-2.5, -2.5),
        blurRadius: isDark ? 4.5 : 6.5,
      ),
      // Ambient depth
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.50)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.20),
        offset: isDark ? const Offset(2.5, 2.5) : const Offset(3.0, 3.0),
        blurRadius: isDark ? 4.5 : 6.5,
      ),
    ];
  }

  /// Pill/Badge dual lighting shadow with soft, eye-friendly radii.
  static List<BoxShadow> badge({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.65),
        offset: isDark ? const Offset(-1.2, -1.2) : const Offset(-1.5, -1.5),
        blurRadius: isDark ? 2.5 : 3.5,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.45)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.18),
        offset: isDark ? const Offset(1.6, 1.6) : const Offset(1.8, 1.8),
        blurRadius: isDark ? 2.5 : 3.5,
      ),
    ];
  }

  /// Resting tactile button shadows with smooth, eye-friendly depth.
  static List<BoxShadow> buttonResting({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.70),
        offset: isDark ? const Offset(-1.5, -1.5) : const Offset(-2.0, -2.0),
        blurRadius: isDark ? 3.5 : 5.0,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.55)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.22),
        offset: isDark ? const Offset(2.0, 2.0) : const Offset(2.5, 2.5),
        blurRadius: isDark ? 3.5 : 5.5,
      ),
    ];
  }

  /// Pressed button inset shadow with gentle indented feel.
  static List<BoxShadow> buttonPressed({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.45)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.18),
        offset: isDark ? const Offset(1.2, 1.2) : const Offset(1.5, 1.5),
        blurRadius: isDark ? 2.0 : 3.0,
      ),
    ];
  }

  /// Raised soft tactile button dual shadows with smooth feathered depth (matching AppBar squircle buttons).
  static List<BoxShadow> softButton({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.045)
            : Colors.white.withValues(alpha: 0.72),
        offset: isDark ? const Offset(-2.5, -2.5) : const Offset(-3.0, -3.0),
        blurRadius: isDark ? 5.5 : 7.5,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.60)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.24),
        offset: const Offset(3.5, 3.5),
        blurRadius: isDark ? 7.5 : 9.0,
        spreadRadius: 0,
      ),
    ];
  }

  /// Pressed tactile button inset shadow for soft squircle buttons.
  static List<BoxShadow> softButtonPressed({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.50)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.20),
        offset: isDark ? const Offset(1.5, 1.5) : const Offset(1.8, 1.8),
        blurRadius: isDark ? 2.5 : 3.5,
      ),
    ];
  }

  /// Dual micro shadows for dot indicators and tiny circular markers.
  static List<BoxShadow> dotIndicator({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.50)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.20),
        offset: const Offset(1.0, 1.0),
        blurRadius: isDark ? 1.5 : 2.5,
      ),
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.09)
            : Colors.white.withValues(alpha: 0.65),
        offset: const Offset(-0.8, -0.8),
        blurRadius: isDark ? 1.2 : 2.0,
      ),
    ];
  }

  /// Active dot badge glow with vivid luminescence.
  static List<BoxShadow> activeDot({required Color color}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.45),
        blurRadius: 3.0,
        spreadRadius: 0.5,
      ),
    ];
  }

  /// Dual lighting shadows for interactive Neumorphic tiles (choice options, list items).
  static List<BoxShadow> tileResting({required bool isDark}) {
    return [
      BoxShadow(
        color: lightShadowColor(isDark),
        offset: isDark ? const Offset(-2, -2) : const Offset(-2.5, -2.5),
        blurRadius: isDark ? 4.0 : 6.5,
      ),
      BoxShadow(
        color: darkShadowColor(isDark),
        offset: isDark ? const Offset(2.5, 2.5) : const Offset(3.0, 3.0),
        blurRadius: isDark ? 5.0 : 7.0,
      ),
    ];
  }

  /// Recessed inset shadow specifically tuned for text inputs, number inputs, and search fields.
  static List<BoxShadow> insetInput({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.45)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.18),
        offset: isDark ? const Offset(1.5, 1.5) : const Offset(1.8, 1.8),
        blurRadius: isDark ? 3.0 : 4.5,
      ),
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.60),
        offset: const Offset(-1.0, -1.0),
        blurRadius: isDark ? 2.0 : 3.0,
      ),
    ];
  }

  /// HeatMap / calendar day tile shadows for completed progress.
  /// Combines a dynamic radiant bloom scaled by completion strength with a tactile inset depth shadow.
  static List<BoxShadow> heatMapTile({
    required Color primary,
    required bool isDark,
    double progress = 1.0,
  }) {
    final double glowAlpha =
        (isDark ? 0.12 : 0.06) + (progress * (isDark ? 0.15 : 0.08));
    final double glowRadius = 1.5 + (progress * 6.5);
    final double spread = progress >= 0.7 ? 1.0 : 0.0;

    return [
      BoxShadow(
        color: primary.withValues(alpha: glowAlpha),
        blurRadius: glowRadius,
        spreadRadius: spread,
        offset: const Offset(0, 1.0),
      ),
      ...insetWell(isDark: isDark),
    ];
  }

  /// HeatMap / calendar day tile shadow for today's active focus ring.
  static List<BoxShadow> heatMapTodayHighlight({
    required Color primary,
    required bool isDark,
  }) {
    return bloom(
      color: primary,
      isDark: isDark,
      blur: 6.0,
      spread: 0.5,
      offset: Offset.zero,
    );
  }
}
