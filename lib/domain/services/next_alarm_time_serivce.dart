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
}
