import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:alarm_from_hell/core/constants/sound_constants.dart';
import 'package:alarm_from_hell/data/model/AlarmModel.dart';
import 'package:alarm_from_hell/core/utils/theme_provider.dart';
import 'package:alarm_from_hell/domain/services/sound_service.dart';

class AddAlarmPage extends StatefulWidget {
  const AddAlarmPage({super.key});

  @override
  State<AddAlarmPage> createState() => _AddAlarmPageState();
}

class _AddAlarmPageState extends State<AddAlarmPage> {
  final SoundService _soundService = SoundService();
  bool _isPlaying = false;

  // 알람 시간과 분을 위한 변수
  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;

  // 알람 입력을 위한 컨트롤러
  final TextEditingController _bodyController = TextEditingController();

  // 반복 알람 설정을 위한 변수
  bool _isRepeating = false;
  List<bool> _repeatingDays = List.filled(7, false);

  // 선택된 알람 사운드
  String _selectedSound = SoundConstants.alarmSounds.keys.first;

  // 요일 이름
  final List<String> _dayNames = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void dispose() {
    _bodyController.dispose();
    _soundService.reset();
    super.dispose();
  }

  // 알람 모델 생성 메서드
  Future<AlarmModel?> _createNewAlarmModel() async {
    try {
      final newAlarmId =
          DateTime.now().second * 1000 + DateTime.now().millisecond;

      // 선택된 사운드 경로 가져오기
      final soundPath =
          SoundConstants.alarmSounds[_selectedSound] ??
          SoundConstants.testAlarmSound;

      // assets/ 경로가 이미 포함되어 있는지 확인
      final assetAudioPath =
          soundPath.startsWith("assets/") ? soundPath : "assets/$soundPath";

      final newAlarm = AlarmModel(
        id: newAlarmId,
        alarmTime: _selectedHour,
        alarmMinute: _selectedMinute,
        assetAudioPath: assetAudioPath,
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        volume: 1.0,
        fadeDuration: const Duration(seconds: 3),
        volumeEnforced: true,
        title: _bodyController.text.isEmpty ? "알람" : _bodyController.text,
        body: _bodyController.text.isEmpty ? "일어나세요!" : _bodyController.text,
        stopButton: "중지",
        isActivated: false,
        isRepeating: _isRepeating,
        repeatingDays: List.from(_repeatingDays),
      );

      print('새 알람 모델 생성 성공: ${newAlarm.id}');
      return newAlarm;
    } catch (e) {
      print('새 알람 모델 생성 오류: $e');
      return null;
    }
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

  // 알람 사운드 미리듣기
  Future<void> _previewSound() async {
    if (_isPlaying) {
      await _soundService.stopSound();
      setState(() {
        _isPlaying = false;
      });
    } else {
      final soundPath =
          SoundConstants.alarmSounds[_selectedSound] ??
          SoundConstants.testAlarmSound;

      // assets/ 경로가 이미 포함되어 있는지 확인
      final assetAudioPath =
          soundPath.startsWith("assets/") ? soundPath : "assets/$soundPath";

      await _soundService.playSound(assetAudioPath);
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkBlue = Color(0xFF1F2E36);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: Text("새 알람 추가", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 반복 알람 스위치
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '반복 알람',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          value: _isRepeating,
                          onChanged: (value) {
                            setState(() {
                              _isRepeating = value;
                              if (!value) {
                                for (int i = 0; i < 7; i++) {
                                  _repeatingDays[i] = false;
                                }
                              }
                            });
                          },
                          activeColor: isDark ? Colors.blue : Colors.blue,
                        ),
                      ],
                    ),
                  ),

                  // 요일 선택 UI
                  if (_isRepeating)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '반복 요일',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(7, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _repeatingDays[index] =
                                        !_repeatingDays[index];
                                    _isRepeating = _repeatingDays.any(
                                      (day) => day,
                                    );
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        _repeatingDays[index]
                                            ? Colors.blue
                                            : (isDark
                                                ? Colors.grey[800]
                                                : Colors.grey[200]),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _dayNames[index],
                                    style: TextStyle(
                                      color:
                                          _repeatingDays[index]
                                              ? Colors.white
                                              : (isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600]),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                  // 시간 선택
                  Text(
                    "알람 시간",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildTimePicker(),
                  SizedBox(height: 20),

                  // 알람 내용 입력
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
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
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
                  SizedBox(height: 20),

                  // 알람 사운드 선택
                  Text(
                    "알람 소리",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade700),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedSound,
                            isExpanded: true,
                            underline: SizedBox(),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            dropdownColor:
                                isDark ? Color(0xFF2A2A2A) : Colors.white,
                            items:
                                SoundConstants.alarmSounds.keys.map((
                                  String sound,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: sound,
                                    child: Text(sound),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedSound = newValue;
                                  if (_isPlaying) {
                                    _previewSound();
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: _previewSound,
                        icon: Icon(
                          _isPlaying ? Icons.stop : Icons.play_arrow,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.grey[800] : Colors.grey[200],
                          padding: EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 하단 고정 버튼
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF2A2A2A) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 사운드가 재생 중이면 먼저 중지합니다
                      if (_isPlaying) {
                        _soundService.stopSound();
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      "취소",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // 사운드가 재생 중이면 먼저 중지합니다
                      if (_isPlaying) {
                        await _soundService.stopSound();
                        setState(() {
                          _isPlaying = false;
                        });
                      }

                      final newAlarm = await _createNewAlarmModel();
                      if (newAlarm != null) {
                        Navigator.pop(context, newAlarm);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      "저장",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
