import 'package:alarm/alarm.dart';
import 'package:alarm_from_hell/ui/alarm_exit/alarm_exit_page.dart';
import 'package:alarm_from_hell/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
// import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

// 전역 내비게이터 키
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알람 초기화
  await Alarm.init();

  // 알람 링잉 핸들러 설정
  setupAlarmHandlers();

  // 알림 권한 요청 (Android 및 iOS 모두)
  await requestNotificationPermissions();

  runApp(const MyApp());
}

// 알람 핸들러 설정
void setupAlarmHandlers() {
  // 알람이 울릴 때 호출되는 콜백
  Alarm.ringStream.stream.listen((alarmSettings) {
    print('알람이 울립니다! ID: ${alarmSettings.id}');

    // 알람이 울리면 특정 페이지로 이동
    // 메인 스레드에서 실행해야 UI 업데이트가 가능합니다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_navigatorKey.currentState != null) {
        // 여기서 원하는 페이지로 이동합니다
        _navigatorKey.currentState!.pushNamed(
          '/alarm_ring_page',
          arguments: alarmSettings,
        );
      }
    });
  });
}

Future<void> requestNotificationPermissions() async {
  // Android 13+ (SDK 33+)에서는 POST_NOTIFICATIONS 권한 필요
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Android 전용 권한
  if (Platform.isAndroid) {
    await Permission.scheduleExactAlarm.request();
  }

  // iOS 전용 권한
  if (Platform.isIOS) {
    await Permission.criticalAlerts.request(); // 중요 알림 권한 요청
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm From Hell',
      navigatorKey: _navigatorKey, // 전역 내비게이터 키 설정
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {'/alarm_ring_page': (context) => AlarmExitPage()},
    );
  }
}
