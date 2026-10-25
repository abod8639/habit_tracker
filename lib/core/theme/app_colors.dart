import 'package:flutter/material.dart';

/// Centralized color palette and constant design tokens.
/// Holds specific fixed semantic accents and Neumorphic reference tones.
abstract final class AppColors {
  // ── Drawer & Navigation Specific Accents ──────────────────────────────────
  static const Color drawerScan = Color(0xFF03A9F4); // Colors.lightBlue
  static const Color drawerStats = Color(0xFF448AFF); // Colors.blueAccent
  static const Color drawerAiCoach = Color(0xFFE040FB); // Colors.purpleAccent
  static const Color drawerSettings = Color(0xFF607D8B); // Colors.blueGrey

  // ── Neumorphic Tone References ───────────────────────────────────────────
  /// Reference tone for light theme neumorphic depth shadows.
  static const Color neumorphicDepthLight = Color(0xFFA3B1C6);

  /// Reference tone for light theme debossed inner recessed wells.
  static const Color neumorphicDebossedLight = Color(0xFFDCE2EC);

  /// Reference tone for light theme recessed inputs and track backgrounds.
  static const Color neumorphicWellLight = Color(0xFFEFF2F8);

  /// Reference tone for light theme disabled / neutral surfaces.
  static const Color neumorphicDisabledLight = Color(0xFFE2E8F0);

  /// Reference tone for light theme pressed button surfaces.
  static const Color neumorphicPressedLight = Color(0xFFD3DCE8);

  /// Unified disabled container surface color adapted for light/dark theme.
  static Color disabledSurface(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.05)
        : neumorphicDisabledLight;
  }
}
