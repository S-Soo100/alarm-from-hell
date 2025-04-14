import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 백그라운드 오디오 세션 설정
    setupAudioSession()
    
    // iOS에서 푸시 알림 권한 요청
    registerForPushNotifications(application: application)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // 오디오 세션 설정
  private func setupAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(
        .playback,
        mode: .default,
        options: [.mixWithOthers, .duckOthers]
      )
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("오디오 세션 설정 실패: \(error.localizedDescription)")
    }
  }
  
  // 푸시 알림 권한 요청
  private func registerForPushNotifications(application: UIApplication) {
    UNUserNotificationCenter.current().delegate = self
    
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .criticalAlert]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { granted, error in
        if granted {
          print("알림 권한이 허용되었습니다.")
        } else {
          print("알림 권한이 거부되었습니다: \(String(describing: error))")
        }
      }
    )
    
    application.registerForRemoteNotifications()
  }
  
  // 백그라운드 작업 처리
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    completionHandler(.newData)
  }
}
