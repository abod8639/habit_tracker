import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Tests', () {
    test('NotificationService is a singleton instance', () {
      final service1 = NotificationService();
      final service2 = NotificationService();
      expect(identical(service1, service2), true);
    });

    test('NotificationService initializes without crashing', () {
      final service = NotificationService();
      expect(service.flutterLocalNotificationsPlugin, isNotNull);
    });

    test('Timezone inspection', () {
      tz.initializeTimeZones();
      final location = tz.getLocation('Africa/Cairo');
      tz.setLocalLocation(location);
      expect(tz.local.name, equals('Africa/Cairo'));
      final nowTz = tz.TZDateTime.now(tz.local);
      expect(nowTz.timeZoneOffset.inHours, equals(3));
    });
  });
}
