import 'package:alarm/alarm.dart';
import 'package:alarm_from_hell/data/model/AlarmModel.dart';
import 'package:alarm_from_hell/data/service/alarm_db_service.dart';
import 'package:alarm_from_hell/domain/services/alarm_service.dart';
import 'package:alarm_from_hell/ui/alarm_exit/alarm_exit_page.dart';
import 'package:alarm_from_hell/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:alarm_from_hell/core/constants/storage_constants.dart';
import 'package:alarm_from_hell/core/constants/theme_constants.dart';
import 'package:alarm_from_hell/core/utils/theme_provider.dart';

// 서비스 export - 모든 파일에서 동일한 인스턴스 접근을 위해
export 'package:alarm_from_hell/domain/services/alarm_service.dart';
export 'package:alarm_from_hell/data/service/alarm_db_service.dart';

// 전역 내비게이터 키
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

// 전역 알람 서비스
final alarmService = AlarmService();

// 전역 알람 DB 서비스
final alarmDBService = AlarmDBService();

// 전역 테마 상태 관리
// ThemeProvider 클래스는 core/utils/theme_provider.dart로 이동됨

/// Hive 어댑터 등록
void registerHiveAdapters() {
  print('-------------- Hive 어댑터 등록 시작 --------------');

  try {
    // AlarmModel 어댑터 등록
    if (!Hive.isAdapterRegistered(0)) {
      print('AlarmModel 어댑터 등록 (typeId: 0)');
      Hive.registerAdapter(AlarmModelAdapter());
      print('AlarmModel 어댑터 등록 완료');
    } else {
      print('AlarmModel 어댑터 이미 등록됨 (typeId: 0)');
    }
  } catch (e) {
    print('⚠️ Hive 어댑터 등록 오류: $e');
  }

  print('-------------- Hive 어댑터 등록 완료 --------------');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // 개발 중 디버그 모드에서만 사용하던 Hive 데이터 삭제 코드 제거
  // 사용자 알람 데이터가 앱 재시작 후에도 유지되도록 함
  /*
  try {
    print('-------------- Hive 청소 시작 --------------');
    await Hive.deleteBoxFromDisk('alarms_box');
    print('알람 박스 삭제 완료');
    print('-------------- Hive 청소 완료 --------------');
  } catch (e) {
    print('Hive 박스 삭제 실패: $e');
  }
  */

  // Hive 어댑터 등록
  registerHiveAdapters();

  // 알람 DB 서비스 초기화
  await alarmDBService.init();

  // 알람 서비스 초기화 (알람 초기화 + 리스너 설정)
  await alarmService.initialize(_navigatorKey);

  // 알림 권한 요청 (Android 및 iOS 모두)
  await requestNotificationPermissions();

  // 저장된 테마 설정 로드
  await themeProvider.loadThemeFromHive();

  runApp(const MyApp());
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 테마 변경을 감지하여 화면 갱신
    themeProvider.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // 앱 종료 시 알람 서비스 정리
    alarmService.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm From Hell',
      navigatorKey: _navigatorKey, // 전역 내비게이터 키 설정
      themeMode: themeProvider.themeMode,
      theme: ThemeConstants.lightTheme,
      darkTheme: ThemeConstants.darkTheme,
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {'/alarm_exit_page': (context) => AlarmExitPage()},
    );
  }
}
