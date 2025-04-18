// ignore: file_names
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'AlarmModel.g.dart';

@HiveType(typeId: 0)
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
    required Duration fadeDuration,
    required this.volumeEnforced,
    required this.title,
    required this.body,
    required this.stopButton,
    this.isActivated = false,
  }) : fadeDurationMillis = fadeDuration.inMilliseconds;

  @HiveField(0)
  final int id;

  // final DateTime dateTime;
  @HiveField(1)
  final int alarmTime;

  @HiveField(2)
  final int alarmMinute;

  @HiveField(3)
  final String assetAudioPath;

  @HiveField(4)
  final bool loopAudio;

  @HiveField(5)
  final bool vibrate;

  @HiveField(6)
  final bool warningNotificationOnKill;

  @HiveField(7)
  final bool androidFullScreenIntent;

  @HiveField(8)
  final double volume;

  // Duration을 직접 사용하지 않고 밀리초로 변환하여 저장
  @HiveField(9)
  final int fadeDurationMillis;

  @HiveField(10)
  final bool volumeEnforced;

  @HiveField(11)
  final String title;

  @HiveField(12)
  final String body;

  @HiveField(13)
  final String stopButton;

  @HiveField(14)
  bool isActivated;

  // 밀리초를 Duration으로 변환
  Duration get fadeDuration => Duration(milliseconds: fadeDurationMillis);

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
        fadeDuration: fadeDuration, // getter를 통해 얻은 Duration 사용
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
