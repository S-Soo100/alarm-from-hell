import 'package:alarm_from_hell/component/alarm_list_widget.dart';
import 'package:alarm_from_hell/component/next_alarm_time_widget.dart';
import 'package:alarm_from_hell/data/model/AlarmModel.dart';
import 'package:alarm_from_hell/domain/services/next_alarm_time_serivce.dart';
import 'package:alarm_from_hell/ui/test_alarm/test_alarm_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

// 메인에서 정의된 테마 프로바이더 가져오기
import 'package:alarm_from_hell/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isModalOn = false;
  NextAlarmTimeSerivce? _nextTimeService;
  String nextAlarm = "다음 알람이 없습니다";

  // 알람 시간과 분을 위한 변수
  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;

  // 테마 모드 상태
  bool _isDarkMode = true;

  final List<AlarmModel> _alarmModel = [
    AlarmModel(
      id: 1,
      alarmTime: 23,
      alarmMinute: 0,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      volume: 0.2,
      fadeDuration: Duration(seconds: 5),
      volumeEnforced: true,
      title: '테스트 타이틀',
      body: '테스트 바디',
      stopButton: '테스트 스탑 버튼',
    ),
  ];

  // 알람 입력을 위한 컨트롤러들
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nextTimeService = NextAlarmTimeSerivce();
    updateNextAlarmTime();
  }

  // 테마 모드 변경
  void _toggleThemeMode() async {
    final isDark = !themeProvider.isDarkMode;

    // 테마 변경
    themeProvider.toggleTheme();

    // 시스템 UI 테마 업데이트
    _updateSystemUI(isDark);
  }

  // 시스템 UI 테마 업데이트
  void _updateSystemUI(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: brightness,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? Color(0xFF121212) : Colors.white,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  // 다음 알람 시간 업데이트 메소드
  void updateNextAlarmTime() {
    setState(() {
      nextAlarm = _nextTimeService!.getNextAlarmTimeWithAlarms(_alarmModel);
    });
  }

  // 알람 추가 메소드
  void addAlarm(AlarmModel alarm) {
    setState(() {
      _alarmModel.add(alarm);
      updateNextAlarmTime();
    });
  }

  // 알람 삭제 메소드
  void deleteAlarm(int index) {
    setState(() {
      _alarmModel.removeAt(index);
      updateNextAlarmTime();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // 시간 선택 Cupertino Picker 위젯
  Widget _buildTimePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2A2A2A) : Colors.white,
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 시간 선택 picker
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: _selectedHour,
              ),
              magnification: 1.2,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32,
              onSelectedItemChanged: (int value) {
                setState(() {
                  _selectedHour = value;
                });
              },
              children: List<Widget>.generate(24, (int index) {
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 22,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }),
            ),
          ),
          // 시간과 분 사이 구분선
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              ":",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          // 분 선택 picker
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: _selectedMinute,
              ),
              magnification: 1.2,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32,
              onSelectedItemChanged: (int value) {
                setState(() {
                  _selectedMinute = value;
                });
              },
              children: List<Widget>.generate(60, (int index) {
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 22,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final darkBlue = Color(0xFF1F2E36);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: darkBlue,
        leading: PopupMenuButton<String>(
          icon: Icon(Icons.menu, color: Colors.white),
          onSelected: (value) {
            if (value == 'toggle_theme') {
              _toggleThemeMode();
            }
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'toggle_theme',
                  child: Row(
                    children: [
                      Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: theme.iconTheme.color,
                      ),
                      SizedBox(width: 8),
                      Text(isDark ? '라이트 모드로 전환' : '다크 모드로 전환'),
                    ],
                  ),
                ),
              ],
        ),
        title: Text("Alarm From Hell", style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isModalOn = !_isModalOn;
                });
              },
              icon: Icon(Icons.add, size: 40, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NextAlarmTimeWidget(nextAlarmTime: nextAlarm),
                  AlarmListWidget(
                    alarms: _alarmModel,
                    onDeleteAlarm: deleteAlarm,
                  ),
                  TestAlarmPage(),
                ],
              ),
            ),
          ),
          _modal(),
        ],
      ),
    );
  }

  Widget _modal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkBlue = Color(0xFF1F2E36);

    return _isModalOn
        ? Center(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF2A2A2A) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  spreadRadius: 0.5,
                  blurRadius: 1.0,
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
            width: MediaQuery.sizeOf(context).width * 0.9,
            height: MediaQuery.sizeOf(context).height * 0.7,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "새 알람 추가",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 20),

                // 시간 선택
                Text(
                  "알람 시간",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                // Cupertino Picker로 대체
                _buildTimePicker(),
                SizedBox(height: 20),

                // 제목 입력
                Text(
                  "알람 제목",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "알람 제목을 입력하세요",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: darkBlue),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // 내용 입력
                Text(
                  "알람 내용",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _bodyController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "알람 내용을 입력하세요",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: darkBlue),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isModalOn = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                      ),
                      child: Text("취소", style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 알람 모델 생성 및 추가
                        final newAlarm = AlarmModel(
                          id: DateTime.now().millisecondsSinceEpoch,
                          alarmTime: _selectedHour,
                          alarmMinute: _selectedMinute,
                          assetAudioPath: 'assets/alarm.mp3',
                          loopAudio: true,
                          vibrate: true,
                          warningNotificationOnKill: true,
                          androidFullScreenIntent: true,
                          volume: 1.0,
                          fadeDuration: Duration(seconds: 3),
                          volumeEnforced: true,
                          title:
                              _titleController.text.isEmpty
                                  ? "알람"
                                  : _titleController.text,
                          body:
                              _bodyController.text.isEmpty
                                  ? "일어나세요!"
                                  : _bodyController.text,
                          stopButton: "중지",
                        );

                        // 알람 추가 및 모달 닫기
                        addAlarm(newAlarm);
                        setState(() {
                          _isModalOn = false;
                        });

                        // 입력필드 초기화
                        _titleController.clear();
                        _bodyController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                      ),
                      child: Text("저장", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        : SizedBox();
  }
}
