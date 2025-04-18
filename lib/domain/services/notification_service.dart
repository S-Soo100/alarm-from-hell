import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService with WidgetsBindingObserver {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // 플러터 로컬 알림 플러그인
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 알림 채널 ID
  static const String _channelId = 'alarm_app_channel';
  static const String _channelName = 'Alarm App Notifications';
  static const String _channelDesc = 'Notifications for Alarm From Hell app';

  // 알림 ID
  static const int _appClosedNotificationId = 999;

  // 초기화
  Future<void> init() async {
    // 안드로이드 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    // iOS 설정
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
          onDidReceiveLocalNotification: (id, title, body, payload) async {},
        );

    // 초기화 설정
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // 플러그인 초기화
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 알림 클릭 시 동작
        debugPrint('알림 클릭됨: ${response.payload}');
      },
    );

    // 알림 권한 요청 (iOS)
    final platform =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    if (platform != null) {
      await platform.requestPermissions(alert: true, badge: true, sound: true);
    }

    // Android는 initialize에서 이미 설정됨
    debugPrint('알림 권한 요청 완료');

    // 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);

    debugPrint('알림 서비스 초기화 완료');
  }

  // 앱 생명주기 변화 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      // 앱이 종료되거나 백그라운드로 갈 때
      showAppClosedNotification();
      debugPrint('앱 상태 변경: $state - 알림 표시');
    } else if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때
      onAppActivated();
      debugPrint('앱 상태 변경: $state - 알림 제거');
    }
  }

  // 앱 종료 알림 표시
  Future<void> showAppClosedNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      _appClosedNotificationId,
      '알람 앱이 종료되었습니다',
      '알람이 작동하려면 앱을 다시 실행해주세요',
      notificationDetails,
    );
  }

  // 앱이 활성화될 때 호출
  void onAppActivated() {
    // 앱이 다시 활성화되면 종료 알림 제거
    flutterLocalNotificationsPlugin.cancel(_appClosedNotificationId);
  }

  // 수동으로 알림 표시 (테스트용)
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      100,
      '테스트 알림',
      '이것은 테스트 알림입니다',
      notificationDetails,
    );
  }

  // 리소스 해제
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
