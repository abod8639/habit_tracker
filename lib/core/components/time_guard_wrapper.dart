import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/invalid_time_screen.dart';
import 'package:habit_tracker/core/providers/time_validation_provider.dart';

/// Wraps the application root to monitor and guard against date & time tampering.
/// If tampering is detected, blocks interaction and displays [InvalidTimeScreen].
/// Automatically re-validates when the application resumes from the background
/// (e.g. after the user fixes the clock in device settings).
class TimeGuardWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const TimeGuardWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<TimeGuardWrapper> createState() => _TimeGuardWrapperState();
}

class _TimeGuardWrapperState extends ConsumerState<TimeGuardWrapper>
    with WidgetsBindingObserver {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    // Register lifecycle listener to re-validate when user returns to app
    _lifecycleListener = AppLifecycleListener(
      onResume: _handleAppResume,
    );
  }

  void _handleAppResume() {
    // Whenever the app is resumed from background, re-validate date & time
    ref.read(timeValidationNotifierProvider.notifier).validate();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validationState = ref.watch(timeValidationNotifierProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: validationState.isTampered
          ? KeyedSubtree(
              key: const ValueKey('InvalidTimeScreenKey'),
              child: InvalidTimeScreen(
                deviceTime: validationState.deviceTime,
              ),
            )
          : KeyedSubtree(
              key: const ValueKey('NormalAppContentKey'),
              child: widget.child,
            ),
    );
  }
}
