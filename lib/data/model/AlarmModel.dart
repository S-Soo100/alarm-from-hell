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
    this.isRepeating = false,
    this.repeatingDays = const [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
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

  // 반복 알람 여부
  @HiveField(15)
  bool isRepeating;

  // 요일별 반복 설정 (인덱스 0: 월요일, 1: 화요일, ..., 6: 일요일)
  @HiveField(16)
  List<bool> repeatingDays;

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
    bool? isRepeating,
    List<bool>? repeatingDays,
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
      isRepeating: isRepeating ?? this.isRepeating,
      repeatingDays: repeatingDays ?? List.from(this.repeatingDays),
    );
  }

  DateTime get myDateTime {
    final DateTime now = DateTime.now();
    DateTime alarmDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarmTime,
      alarmMinute,
    );

    // 반복 알람이 아닌 경우
    if (!isRepeating) {
      // 알람 시간이 현재 시간보다 이전이면 다음 날로 설정
      if (alarmDateTime.isBefore(now)) {
        alarmDateTime = alarmDateTime.add(Duration(days: 1));
      }
      return alarmDateTime;
    }

    // 반복 알람인 경우 해당 요일이 설정되어 있는지 확인
    int currentWeekday = now.weekday; // 1: 월요일, 7: 일요일

    // 현재 요일 인덱스 (0: 월요일, 6: 일요일)
    int currentDayIndex = currentWeekday - 1;

    // 오늘 요일에 알람이 설정되어 있고, 알람 시간이 현재 시간 이후인 경우
    if (repeatingDays[currentDayIndex] && alarmDateTime.isAfter(now)) {
      return alarmDateTime;
    }

    // 다음 알람 요일 찾기
    int daysToAdd = 1;
    int nextDayIndex = (currentDayIndex + 1) % 7;

    // 다음 요일부터 검색해서 알람이 설정된 요일 찾기
    while (daysToAdd <= 7) {
      if (repeatingDays[nextDayIndex]) {
        return alarmDateTime.add(Duration(days: daysToAdd));
      }
      daysToAdd++;
      nextDayIndex = (nextDayIndex + 1) % 7;
    }

    // 만약 어떤 요일도 설정되지 않았다면 다음 날로 설정
    return alarmDateTime.add(Duration(days: 1));
  }

  AlarmSettings toAlarmSettings() {
    return AlarmSettings(
      id: id,
      dateTime: myDateTime,
      assetAudioPath: assetAudioPath,
      loopAudio: loopAudio,
      vibrate: vibrate,
      warningNotificationOnKill: false,
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

  // 알람이 울린 후, 반복 알람인 경우 다시 활성화
  void onAlarmComplete() {
    if (isRepeating) {
      // 반복 알람인 경우 활성화 유지
      isActivated = true;
    } else {
      // 일회성 알람인 경우 비활성화
      isActivated = false;
    }
  }

  // 특정 요일 반복 설정
  void setDayRepeating(int dayIndex, bool value) {
    if (dayIndex >= 0 && dayIndex < 7) {
      repeatingDays[dayIndex] = value;

      // 하나라도 요일이 설정되어 있으면 반복 알람으로 설정
      isRepeating = repeatingDays.any((day) => day);
    }
  }

  // 모든 요일 반복 설정
  void setAllDaysRepeating(bool value) {
    for (int i = 0; i < 7; i++) {
      repeatingDays[i] = value;
    }
    isRepeating = value;
  }
}
