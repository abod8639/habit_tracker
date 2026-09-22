import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/services/notification_service.dart';

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
  });
}
