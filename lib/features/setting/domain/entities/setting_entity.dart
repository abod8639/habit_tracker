import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingEntity extends Equatable {
  static const String defaultLanguage = 'sys';

  final String languageCode;
  final bool isNotificationEnabled;
  final TimeOfDay? notificationTime;

  const SettingEntity({
    required this.languageCode,
    required this.isNotificationEnabled,
    this.notificationTime,
  });

  factory SettingEntity.empty() {
    return const SettingEntity(
      languageCode: defaultLanguage,
      isNotificationEnabled: false,
      notificationTime: null,
    );
  }

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

  @override
  List<Object?> get props => [
    languageCode,
    isNotificationEnabled,
    notificationTime,
  ];
}
