import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm_from_hell/data/model/AlarmModel.dart';
import 'package:flutter/material.dart';

class AlarmService {
  // 싱글톤 패턴 구현
  static final AlarmService _instance = AlarmService._internal();

  factory AlarmService() {
    return _instance;
  }

  AlarmService._internal();

  // 전역 내비게이터 키 (main.dart에서 설정한 것을 받아옴)
  GlobalKey<NavigatorState>? _navigatorKey;

  // 이미 처리된 알람 ID 추적
  final Set<int> _processedAlarmIds = {};

  // 알람 비활성화 콜백 (HomePage에서 설정)
  Function(int)? onAlarmDeactivated;

  // 구독 객체 (언제든지 취소할 수 있게)
  StreamSubscription? _subscription;

  // 서비스 초기화 (알람 초기화 + 알람 리스너 초기화)
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    await init();
    _setupAlarmHandlers();
  }

  // 알람 초기화
  Future<void> init() async {
    await Alarm.init();
  }

  // 알람 핸들러 설정
  void _setupAlarmHandlers() {
    // 기존 구독이 있으면 취소
    if (_subscription != null) {
      // 구독 취소
      _subscription!.cancel();
      _subscription = null;
    }

    // 알람이 울릴 때 호출되는 콜백
    _subscription = alarmStream.listen((alarmSet) {
      if (alarmSet.alarms.isEmpty) {
        print('알람이 울렸지만 알람 목록이 비어 있습니다.');
        return;
      }

      final alarmId = alarmSet.alarms.first.id;

      // 이미 처리된 알람인지 확인
      if (_processedAlarmIds.contains(alarmId)) {
        print('알람 ID: $alarmId는 이미 처리되었습니다. 중복 처리 방지.');
        return;
      }

      // 처리된 알람 목록에 추가
      _processedAlarmIds.add(alarmId);

      print('알람이 울립니다! ID: ${alarmSet.alarms.first.id}');

      // 알람이 울리면 특정 페이지로 이동
      // 메인 스레드에서 실행해야 UI 업데이트가 가능합니다
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_navigatorKey?.currentState != null) {
          // 홈페이지가 있는 경우, 알람 목록에서 해당 알람 관리는 HomePage 내부에서 처리됩니다
          // 여기서는 알람 페이지로의 라우팅만 담당합니다

          // 알람 해제 페이지로 이동
          _navigatorKey!.currentState!.pushNamed(
            '/alarm_exit_page',
            arguments: alarmSet.alarms.first,
          );
        }
      });
    });
  }

  // 알람 설정
  Future<bool> setAlarm(AlarmSettings alarmSettings) async {
    try {
      return await Alarm.set(alarmSettings: alarmSettings);
    } catch (e) {
      print('알람 설정 중 오류 발생: $e');
      return false;
    }
  }

  // 알람 모델로부터 알람 설정
  Future<bool> setAlarmFromModel(AlarmModel alarmModel) async {
    try {
      final alarmSettings = alarmModel.toAlarmSettings();
      return await Alarm.set(alarmSettings: alarmSettings);
    } catch (e) {
      print('알람 설정 중 오류 발생: $e');
      return false;
    }
  }

  // 알람 중지
  Future<bool> stopAlarm(int alarmId) async {
    try {
      await Alarm.stop(alarmId);
      return true;
    } catch (e) {
      print('알람 중지 중 오류 발생: $e');
      return false;
    }
  }

  // 모든 알람 중지
  Future<bool> stopAllAlarms() async {
    try {
      await Alarm.stopAll();
      return true;
    } catch (e) {
      print('모든 알람 중지 중 오류 발생: $e');
      return false;
    }
  }

  // 알람 스트림 얻기
  Stream get alarmStream => Alarm.ringing;

  // 알람이 활성화되어 있는지 확인
  Future<bool> hasAlarm(int alarmId) async {
    try {
      final alarms = await Alarm.getAlarms();
      return alarms.any((alarm) => alarm.id == alarmId);
    } catch (e) {
      print('알람 확인 중 오류 발생: $e');
      return false;
    }
  }

  // 모든 알람 가져오기
  Future<List<AlarmSettings>> getAllAlarms() async {
    try {
      return await Alarm.getAlarms();
    } catch (e) {
      print('알람 목록 가져오기 중 오류 발생: $e');
      return [];
    }
  }

  // 알람 ID를 수동으로 처리됨으로 표시하고 비활성화 콜백 호출
  void markAlarmAsProcessed(int alarmId, {AlarmModel? alarmModel}) {
    _processedAlarmIds.add(alarmId);

    // 알람 비활성화 콜백 호출 (설정된 경우)
    if (onAlarmDeactivated != null) {
      onAlarmDeactivated!(alarmId);
      print('알람 비활성화 콜백 호출: ID $alarmId');

      // 반복 알람인 경우 다음 알람 설정
      if (alarmModel != null && alarmModel.isRepeating) {
        // 알람 모델에서 onAlarmComplete 호출하여 활성화 상태 유지
        alarmModel.onAlarmComplete();

        // 다음 알람 시간으로 알람 재설정
        setAlarmFromModel(alarmModel).then((success) {
          if (success) {
            print('반복 알람 재설정 성공: ID $alarmId');
          } else {
            print('반복 알람 재설정 실패: ID $alarmId');
          }
        });
      }
    }
  }

  // 처리된 알람 ID 목록 초기화
  void clearProcessedAlarms() {
    _processedAlarmIds.clear();
  }

  // 서비스 정리
  void dispose() {
    if (_subscription != null) {
      // 구독 취소
      _subscription!.cancel();
      _subscription = null;
    }
  }
}
