import 'package:alarm_from_hell/data/model/AlarmModel.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// HiveDB를 사용하여 알람 데이터를 관리하는 서비스
class AlarmDBService {
  static const String _boxName = 'alarms_box';
  static final AlarmDBService _instance = AlarmDBService._internal();

  late Box<AlarmModel> _alarmsBox;
  ValueListenable<Box<AlarmModel>> get alarmsListenable =>
      _alarmsBox.listenable();

  // 싱글톤 패턴
  factory AlarmDBService() {
    return _instance;
  }

  AlarmDBService._internal();

  /// DB 초기화
  Future<void> init() async {
    // 어댑터 등록은 main.dart에서 이미 수행됨
    print('AlarmDBService: Hive Box 열기 시작');

    try {
      // 알람 데이터 박스 열기
      _alarmsBox = await Hive.openBox<AlarmModel>(_boxName);
      print('AlarmDBService: Hive Box 열기 성공: $_boxName');
    } catch (e) {
      print('AlarmDBService: Hive Box 열기 실패: $e');
      // 박스 열기 실패 시 재시도
      // await Hive.deleteBoxFromDisk(_boxName);
      _alarmsBox = await Hive.openBox<AlarmModel>(_boxName);
      print('AlarmDBService: Hive Box 재생성 성공');
    }
  }

  /// 모든 알람 가져오기
  List<AlarmModel> getAllAlarms() {
    return _alarmsBox.values.toList();
  }

  /// 알람 추가
  Future<void> addAlarm(AlarmModel alarm) async {
    await _alarmsBox.put(alarm.id, alarm);
  }

  /// 알람 삭제
  Future<void> deleteAlarm(int id) async {
    await _alarmsBox.delete(id);
  }

  /// 알람 업데이트
  Future<void> updateAlarm(AlarmModel alarm) async {
    await _alarmsBox.put(alarm.id, alarm);
  }

  /// 알람 활성화 상태 변경
  Future<void> updateAlarmActivation(int id, bool isActivated) async {
    final alarm = _alarmsBox.get(id);
    if (alarm != null) {
      alarm.isActivated = isActivated;
      await _alarmsBox.put(id, alarm);
    }
  }

  /// 모든 알람 삭제
  Future<void> clearAllAlarms() async {
    await _alarmsBox.clear();
  }

  /// 특정 알람 가져오기
  AlarmModel? getAlarm(int id) {
    return _alarmsBox.get(id);
  }
}
