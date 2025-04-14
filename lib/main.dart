import 'package:alarm/alarm.dart';
import 'package:alarm_from_hell/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알람 초기화
  await Alarm.init();

  // 안드로이드 알림 권한 요청
  if (Platform.isAndroid) {
    await requestNotificationPermissions();
  }

  runApp(const MyApp());
}

Future<void> requestNotificationPermissions() async {
  // Android 13+ (SDK 33+)에서는 POST_NOTIFICATIONS 권한 필요
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // 다른 필요한 권한들도 요청
  await Permission.scheduleExactAlarm.request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Alarm From Hell', home: HomePage());
  }
}
