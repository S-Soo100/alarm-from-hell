import 'package:alarm_from_hell/component/alarm_list_widget.dart';
import 'package:alarm_from_hell/component/next_alarm_time_widget.dart';
import 'package:alarm_from_hell/data/model/AlarmModel.dart';
import 'package:alarm_from_hell/domain/services/next_alarm_time_serivce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:alarm_from_hell/core/constants/sound_constants.dart';
import 'package:alarm_from_hell/core/utils/theme_provider.dart';

// 메인에서 정의된 프로바이더와 서비스 가져오기
import 'package:alarm_from_hell/main.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:alarm_from_hell/domain/services/alarm_service.dart';
import 'package:alarm_from_hell/domain/services/notification_service.dart';
import 'package:alarm_from_hell/ui/add_alarm/add_alarm_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AlarmService alarmService = AlarmService();
  final AlarmDBService alarmDBService = AlarmDBService();
  final NotificationService notificationService = NotificationService();
  final NextAlarmTimeSerivce nextTimeService = NextAlarmTimeSerivce();
  String nextAlarm = "다음 알람이 없습니다.";

  // 알람 울림 리스너
  StreamSubscription? _subscription;

  // 이미 처리된 알람 ID 추적
  final Set<int> _processedAlarmIds = {};

  // 알람 시간과 분을 위한 변수
  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;

  // 알람 입력을 위한 컨트롤러들
  final TextEditingController _bodyController = TextEditingController();

  // 반복 알람 설정을 위한 변수
  bool _isRepeating = false;
  List<bool> _repeatingDays = List.filled(7, false);

  // 선택된 알람 사운드
  String _selectedSound = SoundConstants.alarmSounds.keys.first;

  // 요일 이름
  final List<String> _dayNames = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void initState() {
    super.initState();
    _initializeAlarm();
  }

  // 알람 초기화 메소드
  Future<void> _initializeAlarm() async {
    // 권한 체크는 필요 없음 (이미 main.dart에서 처리됨)

    // 1. 가지고 있는 알람 목록 확인
    print('======= 알람 시스템 초기화 =======');
    print('1. 현재 알람 목록 확인');
    final alarms = alarmDBService.getAllAlarms();
    print('등록된 알람 수: ${alarms.length}');

    // 처리된 알람 ID 초기화
    _processedAlarmIds.clear();

    // 기존 구독 취소
    _subscription?.cancel();

    // 알람 리스너는 main.dart에서 전역적으로 관리합니다.
    // 중복 라우팅 방지를 위해 이 컴포넌트에서는 리스너를 설정하지 않습니다.

    // 3. 기존 등록된 알람 정리
    await _cleanupExistingAlarms();

    // // 4. 테스트 알람은 앱을 처음 설치했을 때만 생성
    // if (alarms.isEmpty) {
    //   await _setTestAlarm();
    // } else {
    //   print('3. 기존 알람이 있으므로 테스트 알람은 생성하지 않습니다.');
    //   print('======= 알람 시스템 초기화 완료 =======');
    // }
  }

  // 알람이 울린 후 목록에서 제거하지 않고 비활성화로 변경
  void removeTriggeredAlarm(int alarmId) {
    // Hive에서 알람의 활성화 상태 업데이트
    alarmDBService.updateAlarmActivation(alarmId, false);
    updateNextAlarmTime();
    print('울린 알람(ID: $alarmId)이 비활성화되었습니다.');
  }

  // 기존 알람 정리
  Future<void> _cleanupExistingAlarms() async {
    try {
      // 알람 서비스에 등록된 알람 유지 (알람 중지 코드 제거)
      // await alarmService.stopAllAlarms();
      print('2. 기존 알람 서비스의 알람을 유지합니다');

      // 기존 DB에 저장된 알람을 확인하고 필요 시 재활성화
      final savedAlarms = alarmDBService.getAllAlarms();
      for (var alarm in savedAlarms) {
        if (alarm.isActivated) {
          // 현재 시간과 비교해서 이미 지난 알람은 비활성화
          final now = DateTime.now();
          DateTime alarmDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            alarm.alarmTime,
            alarm.alarmMinute,
          );

          // 알람이 현재 시간보다 이전이면 다음 날로 조정
          if (alarmDateTime.isBefore(now)) {
            alarmDateTime = alarmDateTime.add(const Duration(days: 1));

            // 알람 재설정
            await alarmService.setAlarmFromModel(alarm);
            print('지난 알람(ID: ${alarm.id})을 다음 날로 재설정 완료');
          } else {
            // 이미 설정된 알람은 그대로 유지
            print('기존 알람(ID: ${alarm.id})은 이미 설정되어 있습니다');
          }
        }
      }

      updateNextAlarmTime();
    } catch (e) {
      print('기존 알람 처리 중 오류: $e');
    }
  }

  // 테스트 알람 설정
  Future<void> _setTestAlarm() async {
    try {
      // 현재 시간에서 30초 후로 설정
      final now = DateTime.now();
      final alarmTime = now.add(const Duration(seconds: 30));

      print('3. 테스트 알람 설정');
      print('현재 시간: $now');
      print('알람 설정 시간: $alarmTime');

      // 알람 ID는 Int 최대값(2147483647)보다 작아야 함
      final alarmId = 12345;

      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: alarmTime,
        assetAudioPath: SoundConstants.testAlarmSound,
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        volumeSettings: VolumeSettings.fade(
          volume: Platform.isIOS ? 1.0 : 1.0,
          fadeDuration: const Duration(seconds: 3),
          volumeEnforced: true,
        ),
        notificationSettings: const NotificationSettings(
          title: '테스트 알람',
          body: '30초 후 울리는 테스트 알람입니다!',
          stopButton: '알람 끄기',
          icon: 'notification_icon',
          iconColor: Color.fromARGB(255, 255, 0, 0),
        ),
      );

      // 알람 설정
      bool isSet = await alarmService.setAlarm(alarmSettings);

      print('알람 설정 성공 여부: $isSet');
      print('알람 ID: $alarmId');

      // 4. 새 알람 모델 생성 및 UI에 추가
      try {
        final newAlarm = AlarmModel(
          id: alarmId,
          alarmTime: alarmTime.hour,
          alarmMinute: alarmTime.minute,
          assetAudioPath: SoundConstants.testAlarmSound,
          loopAudio: true,
          vibrate: true,
          warningNotificationOnKill: false,
          androidFullScreenIntent: true,
          volume: 1.0,
          fadeDuration: const Duration(seconds: 3),
          volumeEnforced: true,
          title: '테스트 알람',
          body: '30초 후 울리는 테스트 알람입니다!',
          stopButton: '알람 끄기',
          isActivated: isSet, // 알람 설정 성공 여부에 따라 활성화 상태 설정
        );

        // Hive DB에 알람 추가
        await alarmDBService.addAlarm(newAlarm);
        print('4. 알람 DB에 테스트 알람 추가 완료');
      } catch (e) {
        print('알람 모델 생성 또는 저장 중 오류: $e');
      }

      updateNextAlarmTime();
      print('5. UI 업데이트 완료');
      print('======= 알람 시스템 초기화 완료 =======');
    } catch (e) {
      print('테스트 알람 설정 중 오류 발생: $e');
    }
  }

  // 테마 모드 변경
  void _toggleThemeMode() async {
    final isDark = !themeProvider.isDarkMode;

    // 테마 변경
    themeProvider.toggleTheme();

    // 시스템 UI 테마 업데이트
    _updateSystemUI(isDark);
  }

  // 시스템 UI 테마 업데이트
  void _updateSystemUI(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: brightness,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? Color(0xFF121212) : Colors.white,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  // 다음 알람 시간 업데이트 메소드
  void updateNextAlarmTime() {
    final alarms = alarmDBService.getAllAlarms();
    setState(() {
      nextAlarm = nextTimeService.getNextAlarmTimeWithAlarms(alarms);
    });
  }

  // 알람 추가 시 Alarm.set 적용
  Future<void> addAlarm(AlarmModel alarm) async {
    try {
      // DateTime 계산
      final now = DateTime.now();
      DateTime alarmDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.alarmTime,
        alarm.alarmMinute,
      );

      // 선택한 시간이 현재 시간보다 이전이면 다음 날로 설정
      if (alarmDateTime.isBefore(now)) {
        alarmDateTime = alarmDateTime.add(const Duration(days: 1));
      }

      // AlarmSettings 생성
      final alarmSettings = AlarmSettings(
        id: alarm.id,
        dateTime: alarmDateTime,
        assetAudioPath: alarm.assetAudioPath,
        loopAudio: alarm.loopAudio,
        vibrate: alarm.vibrate,
        warningNotificationOnKill: false,
        androidFullScreenIntent: alarm.androidFullScreenIntent,
        volumeSettings: VolumeSettings.fade(
          volume: alarm.volume,
          fadeDuration: alarm.fadeDuration,
          volumeEnforced: alarm.volumeEnforced,
        ),
        notificationSettings: NotificationSettings(
          title: alarm.title,
          body: alarm.body,
          stopButton: alarm.stopButton,
          icon: 'notification_icon',
          iconColor: const Color.fromARGB(255, 255, 0, 0),
        ),
      );

      // 알람 설정
      bool isSet = await alarmService.setAlarm(alarmSettings);

      // 알람 활성화 상태 업데이트
      alarm.isActivated = isSet;

      // Hive DB에 알람 추가
      await alarmDBService.addAlarm(alarm);
      updateNextAlarmTime();

      print('알람(ID: ${alarm.id}) 추가 및 설정 완료: ${isSet ? '활성화' : '비활성화'}');
    } catch (e) {
      print('알람 추가 중 오류 발생: $e');
    }
  }

  // 알람 삭제 메소드
  Future<void> deleteAlarm(int id) async {
    try {
      // 실제 알람 취소
      await alarmService.stopAlarm(id);

      // Hive DB에서 알람 삭제
      await alarmDBService.deleteAlarm(id);
      updateNextAlarmTime();

      print('알람(ID: $id) 삭제 완료');
    } catch (e) {
      print('알람 삭제 중 오류 발생: $e');
    }
  }

  // 알람 업데이트 메소드
  Future<void> updateAlarm(Map<String, dynamic> updatedAlarmData) async {
    try {
      // 기존 알람 가져오기
      final alarmId = updatedAlarmData['id'] as int;
      AlarmModel? existingAlarm = alarmDBService.getAlarm(alarmId);

      if (existingAlarm == null) {
        print('업데이트할 알람을 찾을 수 없습니다: $alarmId');
        return;
      }

      // 기존 알람의 값 복사
      final updatedAlarm = existingAlarm.copyWith(
        alarmTime: updatedAlarmData['alarmTime'] as int,
        alarmMinute: updatedAlarmData['alarmMinute'] as int,
        title: updatedAlarmData['title'] as String,
        body: updatedAlarmData['body'] as String,
        isRepeating: updatedAlarmData['isRepeating'] as bool,
        repeatingDays: updatedAlarmData['repeatingDays'] as List<bool>,
      );

      // DB에 업데이트
      await alarmDBService.updateAlarm(updatedAlarm);

      // 알람이 활성화되어 있다면 알람 재설정
      if (updatedAlarm.isActivated) {
        await alarmService.stopAlarm(alarmId);
        await alarmService.setAlarmFromModel(updatedAlarm);
      }

      updateNextAlarmTime();
      print('알람 업데이트 완료: $alarmId');
    } catch (e) {
      print('알람 업데이트 중 오류 발생: $e');
    }
  }

  // 알람 활성화/비활성화 토글 메소드
  Future<void> toggleAlarm(int alarmId) async {
    try {
      // 알람 가져오기
      final alarm = alarmDBService.getAlarm(alarmId);

      if (alarm == null) {
        print('토글할 알람을 찾을 수 없습니다: $alarmId');
        return;
      }

      // 현재 상태의 반대로 설정
      bool newState = !alarm.isActivated;

      if (newState) {
        // 알람 활성화 - 새로 알람 설정
        bool isSet = await alarmService.setAlarmFromModel(alarm);

        // DB에 상태 업데이트
        alarm.isActivated = isSet;
        await alarmDBService.updateAlarm(alarm);

        print('알람(ID: $alarmId) 활성화 완료');
      } else {
        // 알람 비활성화 - 알람 중지
        await alarmService.stopAlarm(alarmId);

        // DB에 상태 업데이트
        alarm.isActivated = false;
        await alarmDBService.updateAlarm(alarm);

        print('알람(ID: $alarmId) 비활성화 완료');
      }

      // 다음 알람 시간 업데이트
      updateNextAlarmTime();
    } catch (e) {
      print('알람 토글 중 오류 발생: $e');
    }
  }

  @override
  void dispose() {
    // 알람 서비스에서 콜백 제거
    alarmService.onAlarmDeactivated = null;

    // 리소스 해제
    _subscription?.cancel();
    alarmService.stopAllAlarms(); // 모든 알람 중지
    _bodyController.dispose();
    super.dispose();
  }

  // 시간 선택 Cupertino Picker 위젯
  Widget _buildTimePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2A2A2A) : Colors.white,
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 시간 선택 picker
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: _selectedHour,
              ),
              magnification: 1.2,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32,
              onSelectedItemChanged: (int value) {
                setState(() {
                  _selectedHour = value;
                });
              },
              children: List<Widget>.generate(24, (int index) {
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 22,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }),
            ),
          ),
          // 시간과 분 사이 구분선
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              ":",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          // 분 선택 picker
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: _selectedMinute,
              ),
              magnification: 1.2,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32,
              onSelectedItemChanged: (int value) {
                setState(() {
                  _selectedMinute = value;
                });
              },
              children: List<Widget>.generate(60, (int index) {
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 22,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // 알람 모델 생성 메서드
  Future<AlarmModel?> _createNewAlarmModel() async {
    try {
      final newAlarmId =
          DateTime.now().second * 1000 + DateTime.now().millisecond;
      final newAlarm = AlarmModel(
        id: newAlarmId,
        alarmTime: _selectedHour,
        alarmMinute: _selectedMinute,
        assetAudioPath:
            SoundConstants.alarmSounds[_selectedSound] ??
            SoundConstants.testAlarmSound,
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        volume: 1.0,
        fadeDuration: const Duration(seconds: 3),
        volumeEnforced: true,
        title: _bodyController.text.isEmpty ? "알람" : _bodyController.text,
        body: _bodyController.text.isEmpty ? "일어나세요!" : _bodyController.text,
        stopButton: "중지",
        isActivated: false, // 초기 상태는 비활성화
        isRepeating: _isRepeating,
        repeatingDays: List.from(_repeatingDays),
      );

      print('새 알람 모델 생성 성공: ${newAlarm.id}');
      return newAlarm;
    } catch (e) {
      print('새 알람 모델 생성 오류: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('알람'), backgroundColor: Color(0xFF1F2E36)),
      body: Column(
        children: [
          NextAlarmTimeWidget(nextAlarmTime: nextAlarm),
          Expanded(child: _buildAlarmList()),
        ],
      ),
      floatingActionButton: _buildAddAlarmButton(),
    );
  }

  Widget _buildAlarmList() {
    return ValueListenableBuilder(
      valueListenable: alarmDBService.alarmsListenable,
      builder: (context, box, _) {
        final alarms = box.values.toList();
        return AlarmListWidget(
          alarms: alarms,
          onDeleteAlarm: deleteAlarm,
          onUpdateAlarm: updateAlarm,
          onToggleAlarm: toggleAlarm,
        );
      },
    );
  }

  Widget _buildAddAlarmButton() {
    return FloatingActionButton(
      onPressed: () async {
        final newAlarm = await Navigator.push<AlarmModel>(
          context,
          MaterialPageRoute(builder: (context) => AddAlarmPage()),
        );

        if (newAlarm != null) {
          addAlarm(newAlarm);
        }
      },
      backgroundColor: Color(0xFF1F2E36),
      child: Icon(Icons.add, color: Colors.white),
    );
  }
}
