import 'package:flutter/services.dart';
import 'package:habit_tracker/core/routes/app_router.dart';

/// Centralized keyboard shortcut handlers across screens.
class AppKeyboardShortcuts {
  AppKeyboardShortcuts._();

  /// Handles standard screen pop shortcuts (Escape / Backspace).
  static void handlePageKey(KeyEvent event) {
    if (event.physicalKey == PhysicalKeyboardKey.numLock) {
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (AppRouter.router.canPop()) {
        AppRouter.router.pop();
      }
    }
  }
}
