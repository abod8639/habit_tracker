import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/core/services/fcm_service.dart';
import 'package:habit_tracker/core/functions/get_smart_notification_content.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_habits_usecase.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../../domain/usecases/is_notification_enabled_usecase.dart';
import '../../domain/usecases/set_notification_enabled_usecase.dart';
import '../../domain/usecases/get_notification_time_usecase.dart';
import '../../domain/usecases/set_notification_time_usecase.dart';

class NotificationController extends GetxController {
  final IsNotificationEnabledUseCase _isNotificationEnabledUseCase = Get.find();
  final SetNotificationEnabledUseCase _setNotificationEnabledUseCase =
      Get.find();
  final GetNotificationTimeUseCase _getNotificationTimeUseCase = Get.find();
  final SetNotificationTimeUseCase _setNotificationTimeUseCase = Get.find();

  GetHabitsUseCase? get _getHabitsUseCase =>
      Get.isRegistered<GetHabitsUseCase>() ? Get.find<GetHabitsUseCase>() : null;

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
      (failure) =>
          debugPrint('Error loading notification status: ${failure.message}'),
      (enabled) => isNotificationEnabled.value = enabled,
    );

    final timeResult = await _getNotificationTimeUseCase();
    timeResult.fold(
      (failure) =>
          debugPrint('Error loading notification time: ${failure.message}'),
      (time) => notificationTime.value = time,
    );

    if (isNotificationEnabled.value && notificationTime.value != null) {
      await _scheduleNotification(notificationTime.value!);
    }
  }

  Future<void> sendTestNotification() async {
    await _notificationService.requestPermissions();
    final counts = await _getHabitCounts();
    final content = getSmartNotificationContent(
      remainingCount: counts.remaining,
      totalCount: counts.total,
    );

    await _notificationService.showNotification(
      id: 777,
      title: content.title,
      body: content.body,
    );
    Get.snackbar(
      S.current.notificationTestTitle,
      S.current.notificationTestSent,
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
      (failure) =>
          debugPrint('Error saving notification status: ${failure.message}'),
      (_) async {
        if (enabled) {
          if (notificationTime.value != null) {
            await _scheduleNotification(notificationTime.value!);
          } else {
            const defaultTime = TimeOfDay(hour: 9, minute: 0);
            await _notificationService.showNotification(
              id: 999,
              title: S.current.remindersEnabledTitle,
              body: S.current.remindersEnabledBody,
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
      (failure) =>
          debugPrint('Error saving notification time: ${failure.message}'),
      (_) async {
        if (isNotificationEnabled.value) {
          await _scheduleNotification(time);
        }
      },
    );
  }

  Future<({int total, int remaining})> _getHabitCounts() async {
    if (Get.isRegistered<HabitController>()) {
      final habits = Get.find<HabitController>().habits;
      final total = habits.length;
      final remaining = habits.where((h) => !h.isCompleted).length;
      return (total: total, remaining: remaining);
    }

    if (_getHabitsUseCase != null) {
      final result = await _getHabitsUseCase!();
      return result.fold(
        (_) => (total: 0, remaining: 0),
        (habits) {
          final total = habits.length;
          final remaining = habits.where((h) => !h.isCompleted).length;
          return (total: total, remaining: remaining);
        },
      );
    }

    return (total: 0, remaining: 0);
  }

  Future<void> _scheduleNotification(TimeOfDay time) async {
    final counts = await _getHabitCounts();
    final content = getSmartNotificationContent(
      remainingCount: counts.remaining,
      totalCount: counts.total,
    );

    await _notificationService.cancelAllNotifications();
    await _notificationService.scheduleDailyNotification(
      id: 100,
      title: content.title,
      body: content.body,
      time: time,
    );
  }

  Future<void> updateDailyReminder() async {
    if (!isNotificationEnabled.value || notificationTime.value == null) {
      return;
    }
    await _scheduleNotification(notificationTime.value!);
  }
}
