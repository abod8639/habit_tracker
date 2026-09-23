import 'package:flutter/material.dart';

class SettingEntity {
  final String languageCode;
  final bool isNotificationEnabled;
  final TimeOfDay? notificationTime;

  const SettingEntity({
    required this.languageCode,
    required this.isNotificationEnabled,
    this.notificationTime,
  });

  SettingEntity copyWith({
    String? languageCode,
    bool? isNotificationEnabled,
    TimeOfDay? notificationTime,
  }) {
    return SettingEntity(
      languageCode: languageCode ?? this.languageCode,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }
}
