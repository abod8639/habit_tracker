import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/core/services/fcm_service.dart';
import '../../domain/usecases/is_notification_enabled_usecase.dart';
import '../../domain/usecases/set_notification_enabled_usecase.dart';
import '../../domain/usecases/get_notification_time_usecase.dart';
import '../../domain/usecases/set_notification_time_usecase.dart';

class NotificationController extends GetxController {
  final IsNotificationEnabledUseCase _isNotificationEnabledUseCase = Get.find();
  final SetNotificationEnabledUseCase _setNotificationEnabledUseCase = Get.find();
  final GetNotificationTimeUseCase _getNotificationTimeUseCase = Get.find();
  final SetNotificationTimeUseCase _setNotificationTimeUseCase = Get.find();
  
  NotificationService get _notificationService =>
      Get.isRegistered<NotificationService>()
          ? Get.find<NotificationService>()
          : NotificationService();

  var isNotificationEnabled = false.obs;
  var notificationTime = Rxn<TimeOfDay>();

  String? get fcmToken =>
      Get.isRegistered<FcmService>() ? FcmService.to.fcmToken.value : null;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabledResult = await _isNotificationEnabledUseCase();
    enabledResult.fold(
      (failure) => debugPrint('Error loading notification status: ${failure.message}'),
      (enabled) => isNotificationEnabled.value = enabled,
    );

    final timeResult = await _getNotificationTimeUseCase();
    timeResult.fold(
      (failure) => debugPrint('Error loading notification time: ${failure.message}'),
      (time) => notificationTime.value = time,
    );

    if (isNotificationEnabled.value && notificationTime.value != null) {
      await _scheduleNotification(notificationTime.value!);
    }
  }

  Future<void> sendTestNotification() async {
    await _notificationService.requestPermissions();
    await _notificationService.showTestNotification();
    Get.snackbar(
      'Notification Test',
      'Test notification sent! Check your notification bar.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> toggleNotification(bool enabled) async {
    if (enabled) {
      await _notificationService.requestPermissions();
    }
    
    isNotificationEnabled.value = enabled;
    final result = await _setNotificationEnabledUseCase(enabled);
    
    result.fold(
      (failure) => debugPrint('Error saving notification status: ${failure.message}'),
      (_) async {
        if (enabled) {
          if (notificationTime.value != null) {
            await _scheduleNotification(notificationTime.value!);
          } else {
            const defaultTime = TimeOfDay(hour: 9, minute: 0);
            await _notificationService.showNotification(
              id: 999,
              title: 'Reminders Enabled!',
              body: 'You will receive daily habit checks.',
            );
            await setNotificationTime(defaultTime);
          }
        } else {
          await _notificationService.cancelAllNotifications();
        }
      },
    );
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    notificationTime.value = time;
    final result = await _setNotificationTimeUseCase(time);

    result.fold(
      (failure) => debugPrint('Error saving notification time: ${failure.message}'),
      (_) async {
        if (isNotificationEnabled.value) {
          await _scheduleNotification(time);
        }
      },
    );
  }

  Future<void> _scheduleNotification(TimeOfDay time) async {
    await _notificationService.cancelAllNotifications();
    await _notificationService.scheduleDailyNotification(
      id: 100,
      title: 'Habit Tracker',
      body: 'Time to check your habits!',
      time: time,
    );
  }
}
