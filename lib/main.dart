import 'package:alarm/alarm.dart';
import 'package:alarm_from_hell/ui/alarm_exit/alarm_exit_page.dart';
import 'package:alarm_from_hell/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:alarm_from_hell/core/constants/storage_constants.dart';
import 'package:alarm_from_hell/core/constants/theme_constants.dart';

// 전역 내비게이터 키
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

// 전역 테마 상태 관리
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Hive에서 테마 설정 로드
  Future<void> loadThemeFromHive() async {
    final box = await Hive.openBox(StorageConstants.themeBoxName);
    final isDark =
        box.get(StorageConstants.isDarkModeKey, defaultValue: true) as bool;
    setDarkMode(isDark);
  }

  // Hive에 테마 설정 저장
  Future<void> saveThemeToHive(bool isDark) async {
    final box = await Hive.openBox(StorageConstants.themeBoxName);
    await box.put(StorageConstants.isDarkModeKey, isDark);
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    saveThemeToHive(!isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

final themeProvider = ThemeProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // 알람 초기화
  await Alarm.init();

  // 알람 링잉 핸들러 설정
  setupAlarmHandlers();

  // 알림 권한 요청 (Android 및 iOS 모두)
  await requestNotificationPermissions();

  // 저장된 테마 설정 로드
  await themeProvider.loadThemeFromHive();

  runApp(const MyApp());
}

// 알람 핸들러 설정
void setupAlarmHandlers() {
  // 알람이 울릴 때 호출되는 콜백
  Alarm.ringing.listen((alarmSet) {
    if (alarmSet.alarms.isEmpty) {
      print('알람이 울렸지만 알람 목록이 비어 있습니다.');
      return;
    }

    print('알람이 울립니다! ID: ${alarmSet.alarms.first.id}');

    // 알람이 울리면 특정 페이지로 이동
    // 메인 스레드에서 실행해야 UI 업데이트가 가능합니다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_navigatorKey.currentState != null) {
        // 여기서 원하는 페이지로 이동합니다
        _navigatorKey.currentState!.pushNamed(
          '/alarm_exit_page',
          arguments: alarmSet.alarms.first,
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
