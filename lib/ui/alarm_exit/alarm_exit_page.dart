import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm_from_hell/core/utils/random_sentense.dart';
import 'package:flutter/material.dart';

class AlarmExitPage extends StatefulWidget {
  const AlarmExitPage({Key? key}) : super(key: key);

  @override
  State<AlarmExitPage> createState() => _AlarmExitPageState();
}

class _AlarmExitPageState extends State<AlarmExitPage> {
  AlarmSettings? alarmSettings;
  final TextEditingController _textController = TextEditingController();
  bool _isTextCorrect = false;
  String _targetText = "우리는 어제의 오늘보다 더 나은 내일을 꿈꾸며 나아갑니다.";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _targetText = RandomSentense.getRandomSentense();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // arguments로 알람 설정을 받아옵니다
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is AlarmSettings) {
      alarmSettings = args;
    }
  }

  void _checkText() {
    if (_textController.text == _targetText) {
      setState(() {
        _isTextCorrect = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                const Text(
                  '이 문장을 그대로 따라 치세요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '여기에 입력하세요',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isTextCorrect ? null : _checkText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('확인', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 30),
                if (_isTextCorrect)
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
      ),
    );
  }
}
