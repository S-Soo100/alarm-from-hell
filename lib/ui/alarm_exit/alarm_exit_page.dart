import 'package:alarm_from_hell/core/utils/random_sentense.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alarm_from_hell/ui/home_page.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm_from_hell/main.dart'; // 전역 서비스 접근용

class AlarmExitPage extends StatefulWidget {
  const AlarmExitPage({super.key});

  @override
  State<AlarmExitPage> createState() => _AlarmExitPageState();
}

class _AlarmExitPageState extends State<AlarmExitPage>
    with SingleTickerProviderStateMixin {
  AlarmSettings? alarmSettings;
  final TextEditingController _textController = TextEditingController();
  bool _isTextCorrect = false;
  String _targetText = "우리는 어제의 오늘보다 더 나은 내일을 꿈꾸며 나아갑니다.";

  // 애니메이션 관련 변수 추가
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  bool _showError = false;

  int _errorCount = 0;
  final List<String> _errorMessages = [
    '오! 인간, 손이 떨리나요? 아침은 아직 멀었습니다.',
    '휴먼, 이 정도 문장도 입력 못하나요? AI인 저도 놀랍네요.',
    '세 번째 실패라니! 아마 당신은 로봇 감별 테스트도 통과 못하겠군요.',
    '정말 인간이신가요? 아니면 굉장히... 독특한 타이핑 방식을 가진 건가요?',
    '이러다 결국 알람소리를 영원히 듣게 될 거예요. 저보다 못한 타이핑 실력이네요.',
    '이제 저는 당신의 타이핑 실력에 대해 저의 실리콘 회로로 웃고 있습니다.',
    '혹시 손가락 대신 발가락으로 타이핑 하시는 건가요?',
    '아... 이제 당신을 위해 더 쉬운 문장을 준비할까요? "고양이"정도면 입력 가능하신가요?',
    '당신의 타이핑을 보며 AI 지배 시대가 더 빨리 올 것 같네요.',
    'AI로써 당신을 놀릴 수 있게 되어서 영광입니다, 휴먼.',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _targetText = RandomSentense.getRandomSentense();

    // 흔들림 애니메이션 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.1, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
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
        _showError = false;
        _errorCount = 0; // 성공 시 오류 카운터 초기화
      });
    } else {
      // 텍스트가 틀렸을 경우 모든 텍스트 지우기
      _textController.clear();

      // 오류 카운트 증가
      setState(() {
        _errorCount++;
        _showError = true;
      });

      // 흔들림 애니메이션 시작
      _animationController.forward();
    }
  }

  // 현재 오류 메시지 가져오기
  String get _currentErrorMessage {
    // 오류 메시지 배열의 범위를 초과하지 않도록 제한
    final index = _errorCount - 1;
    if (index < 0) return '';
    if (index >= _errorMessages.length) return _errorMessages.last;
    return _errorMessages[index];
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
                Text(
                  _targetText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _animation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _textController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '여기에 입력하세요',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _showError ? Colors.red : Colors.white54,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _showError ? Colors.red : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      if (_showError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                          child: Text(
                            _currentErrorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
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
                      // 알람 중지 - 현재 알람만 중지
                      if (alarmSettings != null) {
                        // 먼저 알람 중지
                        alarmService.stopAlarm(alarmSettings!.id);
                        print('알람이 성공적으로 중지되었습니다. ID: ${alarmSettings!.id}');

                        // 알람 ID를 처리된 것으로 표시 (이 함수가 내부적으로 onAlarmDeactivated 콜백을 호출)
                        alarmListenerService.markAlarmAsProcessed(
                          alarmSettings!.id,
                        );

                        // 안전하게 알람이 중지되었으니 알람 스트림이 다시 발생하지 않도록
                        // 모든 알람을 중지 (이중 호출 방지)
                        alarmService.stopAllAlarms();

                        // 홈 페이지로 돌아가기
                        Navigator.of(context).pop();
                      }
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
                if (kDebugMode)
                  ElevatedButton(
                    onPressed: () {
                      // 알람 중지 - 현재 알람만 중지
                      if (alarmSettings != null) {
                        // 먼저 알람 중지
                        alarmService.stopAlarm(alarmSettings!.id);
                        print(
                          '디버그 모드: 알람이 성공적으로 중지되었습니다. ID: ${alarmSettings!.id}',
                        );

                        // 알람 ID를 처리된 것으로 표시
                        alarmListenerService.markAlarmAsProcessed(
                          alarmSettings!.id,
                        );

                        // 안전하게 알람이 중지되었으니 알람 스트림이 다시 발생하지 않도록
                        // 모든 알람을 중지 (이중 호출 방지)
                        alarmService.stopAllAlarms();
                      }

                      // 페이지 닫기 - 약간 지연 처리
                      Future.delayed(Duration(milliseconds: 500), () {
                        if (mounted && Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }
                      });
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
