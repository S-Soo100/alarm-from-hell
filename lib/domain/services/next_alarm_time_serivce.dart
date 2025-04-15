import 'package:alarm_from_hell/data/model/AlarmModel.dart';

class NextAlarmTimeSerivce {
  static final NextAlarmTimeSerivce _instance =
      NextAlarmTimeSerivce._internal();
  // 싱글톤 패턴
  factory NextAlarmTimeSerivce() {
    return _instance;
  }

  NextAlarmTimeSerivce._internal();

  String getNextAlarmTimeService() {
    return "00시간 00분 후에 깨우겠습니다, 휴먼.";
  }

  String getNextAlarmTimeWithAlarms(List<AlarmModel> alarms) {
    if (alarms.isEmpty) {
      return "다음 알람이 없습니다";
    }

    // 현재 시간 이후의 알람만 필터링
    final now = DateTime.now();
    final futureAlarms =
        alarms.where((alarm) => alarm.myDateTime.isAfter(now)).toList();

    if (futureAlarms.isEmpty) {
      return "다음 알람이 없습니다";
    }

    // 가장 빠른 알람 찾기
    futureAlarms.sort((a, b) => a.myDateTime.compareTo(b.myDateTime));
    final nextAlarm = futureAlarms.first;

    // 다음 알람까지 남은 시간 계산
    final difference = nextAlarm.myDateTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    return "$hours시간 $minutes분 후에 알람이 울립니다.";
  }
}
