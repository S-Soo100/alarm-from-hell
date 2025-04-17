import 'dart:async';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm_from_hell/core/constants/sound_constants.dart';
import 'package:alarm_from_hell/ui/alarm_exit/alarm_exit_page.dart';
import 'package:flutter/material.dart';

class TestAlarmPage extends StatefulWidget {
  const TestAlarmPage({super.key});

  @override
  State<TestAlarmPage> createState() => _TestAlarmPageState();
}

class _TestAlarmPageState extends State<TestAlarmPage> {
  DateTime time = DateTime.now();
  AlarmSettings? myAlarmSettings;
  int alarmId = 0;

  // 알람 울림 리스너
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    myAlarmSettings = AlarmSettings(
      id: 42,
      dateTime: time.add(Duration(seconds: 10)),
      assetAudioPath: SoundConstants.testAlarmSound,
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: Platform.isIOS ? 1.0 : 0.2,
        fadeDuration: Duration(seconds: 3),
        volumeEnforced: true,
      ),
      notificationSettings: const NotificationSettings(
        title: '알람 알림',
        body: '알람 시간입니다! 확인해주세요.',
        stopButton: '알람 끄기',
        icon: 'notification_icon',
        iconColor: Color.fromARGB(255, 255, 0, 0), // 아이콘 컬러구나 ㅇㅋㅇㅋ
      ),
    );

    // 알람 리스너는 main.dart에서 전역적으로 관리합니다.
    // 중복 라우팅 방지를 위해 이 컴포넌트에서는 리스너를 설정하지 않습니다.

    // setTestAlarm();
  }

  @override
  void dispose() {
    // 리스너 해제
    _subscription?.cancel();
    super.dispose();
  }

  void setTestAlarm() async {
    if (myAlarmSettings != null) {
      if (Platform.isIOS) {
        print("iOS에서 알람을 설정합니다. 백그라운드 모드에서 알림이 표시되는지 확인하세요.");
      }

      await Alarm.set(alarmSettings: myAlarmSettings!);
      alarmId = myAlarmSettings!.id;
    }
  }

  Future<void> cancelTestAlarm() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AlarmExitPage()),
    );
    await Alarm.stop(alarmId);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('알람 설정 완료'),
            Text("알람 ID: ${myAlarmSettings!.id.toString()}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final newAlarmSettings = myAlarmSettings!.copyWith(
                  dateTime: DateTime.now().add(Duration(seconds: 10)),
                );
                setState(() {
                  myAlarmSettings = newAlarmSettings;
                });
                await Alarm.set(alarmSettings: newAlarmSettings);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('알람이 10초 후로 설정되었습니다')));
              },
              child: Text('알람 재설정 (10초 후)'),
            ),
            ElevatedButton(
              onPressed: () async {
                await cancelTestAlarm();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('알람이 종료 되었습니다.')));
              },
              child: Text('제발 그만 말해'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Alarm.set(alarmSettings: myAlarmSettings!);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('재시작')));
              },
              child: Text('다시 말해 말해'),
            ),
          ],
        ),
      ),
    );
  }
}
