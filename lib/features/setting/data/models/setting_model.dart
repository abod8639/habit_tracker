import 'package:flutter/material.dart';
import '../../domain/entities/setting_entity.dart';

class SettingModel extends SettingEntity {
  const SettingModel({
    required super.languageCode,
    required super.isNotificationEnabled,
    super.notificationTime,
  });

  factory SettingModel.fromEntity(SettingEntity entity) {
    return SettingModel(
      languageCode: entity.languageCode,
      isNotificationEnabled: entity.isNotificationEnabled,
      notificationTime: entity.notificationTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'isNotificationEnabled': isNotificationEnabled,
      'notificationTime': notificationTime != null
          ? '${notificationTime!.hour}:${notificationTime!.minute}'
          : null,
    };
  }

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay? time;
    if (json['notificationTime'] != null) {
      final parts = (json['notificationTime'] as String).split(':');
      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return SettingModel(
      languageCode: json['languageCode'] as String,
      isNotificationEnabled: json['isNotificationEnabled'] as bool,
      notificationTime: time,
    );
  }
}
