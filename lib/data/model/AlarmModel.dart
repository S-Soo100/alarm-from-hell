// ignore: file_names
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:flutter/material.dart';

class AlarmModel {
  AlarmModel({
    required this.id,
    // required this.dateTime,
    required this.alarmTime,
    required this.alarmMinute,
    required this.assetAudioPath,
    required this.loopAudio,
    required this.vibrate,
    required this.warningNotificationOnKill,
    required this.androidFullScreenIntent,
    required this.volume,
    required this.fadeDuration,
    required this.volumeEnforced,
    required this.title,
    required this.body,
    required this.stopButton,
    this.isActivated = false,
  });
  final int id;
  // final DateTime dateTime;
  final int alarmTime;
  final int alarmMinute;
  final String assetAudioPath;
  final bool loopAudio;
  final bool vibrate;
  final bool warningNotificationOnKill;
  final bool androidFullScreenIntent;
  final double volume;
  final Duration fadeDuration;
  final bool volumeEnforced;
  final String title;
  final String body;
  final String stopButton;
  bool isActivated;

  // 알람 모델 복사 메소드
  AlarmModel copyWith({
    int? id,
    int? alarmTime,
    int? alarmMinute,
    String? assetAudioPath,
    bool? loopAudio,
    bool? vibrate,
    bool? warningNotificationOnKill,
    bool? androidFullScreenIntent,
    double? volume,
    Duration? fadeDuration,
    bool? volumeEnforced,
    String? title,
    String? body,
    String? stopButton,
    bool? isActivated,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      alarmTime: alarmTime ?? this.alarmTime,
      alarmMinute: alarmMinute ?? this.alarmMinute,
      assetAudioPath: assetAudioPath ?? this.assetAudioPath,
      loopAudio: loopAudio ?? this.loopAudio,
      vibrate: vibrate ?? this.vibrate,
      warningNotificationOnKill:
          warningNotificationOnKill ?? this.warningNotificationOnKill,
      androidFullScreenIntent:
          androidFullScreenIntent ?? this.androidFullScreenIntent,
      volume: volume ?? this.volume,
      fadeDuration: fadeDuration ?? this.fadeDuration,
      volumeEnforced: volumeEnforced ?? this.volumeEnforced,
      title: title ?? this.title,
      body: body ?? this.body,
      stopButton: stopButton ?? this.stopButton,
      isActivated: isActivated ?? this.isActivated,
    );
  }

  DateTime get myDateTime {
    DateTime now = DateTime.now();
    DateTime alarmDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarmTime,
      alarmMinute,
    );

    // 알람 시간이 현재 시간보다 이전이면 다음 날로 설정
    if (alarmDateTime.isBefore(now)) {
      alarmDateTime = alarmDateTime.add(Duration(days: 1));
    }

    return alarmDateTime;
  }

  AlarmSettings toAlarmSettings() {
    return AlarmSettings(
      id: id,
      dateTime: myDateTime,
      assetAudioPath: assetAudioPath,
      loopAudio: loopAudio,
      vibrate: vibrate,
      warningNotificationOnKill: warningNotificationOnKill,
      androidFullScreenIntent: androidFullScreenIntent,
      volumeSettings: VolumeSettings.fade(
        volume: volume,
        fadeDuration: fadeDuration,
        volumeEnforced: volumeEnforced,
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: stopButton,
        icon: 'notification_icon',
        iconColor: Color.fromARGB(255, 36, 33, 33),
      ),
    );
  }
}
