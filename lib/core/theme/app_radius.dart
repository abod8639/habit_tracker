import 'package:flutter/material.dart';

/// Centralized border radius & corner curvature design tokens for the application.
/// Provides consistent radii scales and pre-instantiated [BorderRadius] objects.
abstract final class AppRadius {
  // ── Scale Values ───────────────────────────────────────────────────────────
  /// Extra small: 4.0 (subtle badges, tiny tags)
  static const double xs = 4.0;

  /// Small: 8.0 (inputs, small chips, buttons)
  static const double sm = 8.0;

  /// Medium: 12.0 (cards, inner containers, popups)
  static const double md = 12.0;

  /// Large: 16.0 (standard card padding/inner corners)
  static const double lg = 16.0;

  /// Well: 18.0 (recessed wells, sunken containers, HeatMap wells)
  static const double well = 18.0;

  /// Badge: 20.0 (status badges, stat pills)
  static const double badge = 20.0;

  /// Button: 22.0 (segmented toggles, circular pill buttons)
  static const double button = 22.0;

  /// Card: 24.0 (standard outer card radius, SoftCard, ThemeCard)
  static const double card = 24.0;

  /// Dialog: 28.0 (modal popups, confirmation dialogs)
  static const double dialog = 28.0;

  /// Circular/Pill: 999.0 (capsule pills, fully rounded shapes)
  static const double pill = 999.0;

  // ── Pre-instantiated BorderRadius Objects ──────────────────────────────────
  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius wellRadius = BorderRadius.all(Radius.circular(well));
  static const BorderRadius badgeRadius = BorderRadius.all(Radius.circular(badge));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(button));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius dialogRadius = BorderRadius.all(Radius.circular(dialog));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(pill));

  // ── Helper Constructors ───────────────────────────────────────────────────
  static BorderRadius circular(double radius) => BorderRadius.circular(radius);

  static BorderRadius top(double radius) => BorderRadius.vertical(top: Radius.circular(radius));

  static BorderRadius bottom(double radius) => BorderRadius.vertical(bottom: Radius.circular(radius));

  static BorderRadius left(double radius) => BorderRadius.horizontal(left: Radius.circular(radius));

  static BorderRadius right(double radius) => BorderRadius.horizontal(right: Radius.circular(radius));
}
