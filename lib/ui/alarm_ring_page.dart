import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';

class AlarmRingPage extends StatefulWidget {
  const AlarmRingPage({Key? key}) : super(key: key);

  @override
  State<AlarmRingPage> createState() => _AlarmRingPageState();
}

class _AlarmRingPageState extends State<AlarmRingPage> {
  AlarmSettings? alarmSettings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // arguments로 알람 설정을 받아옵니다
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is AlarmSettings) {
      alarmSettings = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '알람 시간입니다!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '알람 ID: ${alarmSettings?.id ?? '알 수 없음'}',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  // 알람 중지
                  if (alarmSettings != null) {
                    Alarm.stop(alarmSettings!.id);
                  }
                  // 페이지 닫기
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('알람 끄기', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
