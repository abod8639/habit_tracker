import 'dart:async';
import 'package:flutter/foundation.dart';


class ClickThrottler {
  final Duration duration;
  bool _isProcessing = false;
  Timer? _timer;

  ClickThrottler({this.duration = const Duration(milliseconds: 600)});

  bool get isProcessing => _isProcessing;

  void run(VoidCallback action) {
    if (_isProcessing) return;

    _isProcessing = true;
    try {
      action();
    } finally {
      _startCooldown();
    }
  }


  Future<void> runAsync(Future<void> Function() asyncAction) async {
    if (_isProcessing) return;

    _isProcessing = true;
    try {
      await asyncAction();
    } finally {
      _startCooldown();
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    _timer = Timer(duration, () {
      _isProcessing = false;
    });
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _isProcessing = false;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

extension ClickThrottlerExtension on VoidCallback {
  VoidCallback throttle([Duration duration = const Duration(milliseconds: 600)]) {
    final throttler = ClickThrottler(duration: duration);
    return () => throttler.run(this);
  }
}

extension AsyncClickThrottlerExtension on Future<void> Function() {
  Future<void> Function() throttleAsync([
    Duration duration = const Duration(milliseconds: 600),
  ]) {
    final throttler = ClickThrottler(duration: duration);
    return () => throttler.runAsync(this);
  }
}
