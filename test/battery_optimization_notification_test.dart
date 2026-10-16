import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Battery Optimization Notification Tests', () {
    const channel = MethodChannel(
      'com.example.habit_tracker/battery_optimization',
    );
    final List<MethodCall> methodCalls = [];

    setUp(() {
      methodCalls.clear();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            methodCalls.add(call);
            switch (call.method) {
              case 'isIgnoringBatteryOptimizations':
                return false;
              case 'requestIgnoreBatteryOptimizations':
                return true;
              case 'openBatteryOptimizationSettings':
                return true;
              default:
                return null;
            }
          });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      'isIgnoringBatteryOptimizations returns false when battery saver is active',
      () async {
        final service = NotificationService();
        final isIgnoring = await service.isIgnoringBatteryOptimizations();

        expect(isIgnoring, false);
        expect(methodCalls.length, 1);
        expect(methodCalls.first.method, 'isIgnoringBatteryOptimizations');
      },
    );

    test(
      'isIgnoringBatteryOptimizations returns true when exempted',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async => true);

        final service = NotificationService();
        final isIgnoring = await service.isIgnoringBatteryOptimizations();

        expect(isIgnoring, true);
      },
    );

    test(
      'isIgnoringBatteryOptimizations handles channel error gracefully',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              throw PlatformException(code: 'ERROR', message: 'Failed');
            });

        final service = NotificationService();
        final isIgnoring = await service.isIgnoringBatteryOptimizations();

        expect(
          isIgnoring,
          true,
        ); // fallback is true to avoid false-positive blocking
      },
    );

    test(
      'requestIgnoreBatteryOptimizations invokes native request',
      () async {
        final service = NotificationService();
        final result = await service.requestIgnoreBatteryOptimizations();

        expect(result, true);
        expect(
          methodCalls.any(
            (c) => c.method == 'requestIgnoreBatteryOptimizations',
          ),
          true,
        );
      },
    );

    test(
      'openBatteryOptimizationSettings invokes native settings action',
      () async {
        final service = NotificationService();
        final result = await service.openBatteryOptimizationSettings();

        expect(result, true);
        expect(
          methodCalls.any((c) => c.method == 'openBatteryOptimizationSettings'),
          true,
        );
      },
    );

    test(
      'Non-android platform defaults to ignoring battery optimization',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final service = NotificationService();
        final isIgnoring = await service.isIgnoringBatteryOptimizations();
        expect(isIgnoring, true);
        expect(methodCalls.isEmpty, true);
      },
    );
  });
}
