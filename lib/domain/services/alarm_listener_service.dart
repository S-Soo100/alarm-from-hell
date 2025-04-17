import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm_from_hell/domain/services/alarm_service.dart';
import 'package:flutter/material.dart';

class AlarmListenerService {
  // 싱글톤 패턴 구현
  static final AlarmListenerService _instance =
      AlarmListenerService._internal();

  factory AlarmListenerService() {
    return _instance;
  }

  AlarmListenerService._internal();

  // 전역 내비게이터 키 (main.dart에서 설정한 것을 받아옴)
  GlobalKey<NavigatorState>? _navigatorKey;

  // 이미 처리된 알람 ID 추적
  final Set<int> _processedAlarmIds = {};

  // 알람 비활성화 콜백 (HomePage에서 설정)
  Function(int)? onAlarmDeactivated;

  // 구독 객체 저장용
  Stream? _alarmStream;

  // 구독 객체 (언제든지 취소할 수 있게)
  StreamSubscription? _subscription;

  // 알람 서비스
  final AlarmService _alarmService = AlarmService();

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _setupAlarmHandlers();
  }

  void _setupAlarmHandlers() {
    // 기존 구독이 있으면 취소
    if (_subscription != null) {
      // 구독 취소
      _subscription!.cancel();
      _subscription = null;
    }

    // 알람이 울릴 때 호출되는 콜백
    _subscription = _alarmService.alarmStream.listen((alarmSet) {
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

  // 알람 ID를 수동으로 처리됨으로 표시하고 비활성화 콜백 호출
  void markAlarmAsProcessed(int alarmId) {
    _processedAlarmIds.add(alarmId);

    // 알람 비활성화 콜백 호출 (설정된 경우)
    if (onAlarmDeactivated != null) {
      onAlarmDeactivated!(alarmId);
      print('알람 비활성화 콜백 호출: ID $alarmId');
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
