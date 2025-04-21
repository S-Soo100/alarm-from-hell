import 'package:alarm_from_hell/data/model/AlarmModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlarmListWidget extends StatelessWidget {
  final List<AlarmModel> alarms;
  final Function(int) onDeleteAlarm;
  final Function(Map<String, dynamic>) onUpdateAlarm;
  final Function(int) onToggleAlarm;

  const AlarmListWidget({
    super.key,
    required this.alarms,
    required this.onDeleteAlarm,
    required this.onUpdateAlarm,
    required this.onToggleAlarm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.grey[800];

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                "알람 목록",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            alarms.isEmpty
                ? Container(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 30 : 13),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    "등록된 알람이 없습니다",
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),
                )
                : Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 30 : 13),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemBuilder: (BuildContext context, int index) {
                        final alarm = alarms[index];
                        return Dismissible(
                          key: Key(alarm.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20.0),
                            color: const Color.fromARGB(255, 122, 122, 122),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: cardColor,
                                  title: Text(
                                    '알람 삭제',
                                    style: TextStyle(color: textColor),
                                  ),
                                  content: Text(
                                    '이 알람을 삭제하시겠습니까?',
                                    style: TextStyle(color: textColor),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: Text('아니오'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: Text('예'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            onDeleteAlarm(alarm.id);
                          },
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showEditAlarmModal(context, alarm);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: AlarmItem(
                                  alarm: alarm,
                                  onDelete: () => onDeleteAlarm(alarm.id),
                                  isDark: isDark,
                                  onToggle: onToggleAlarm,
                                ),
                              ),
                              if (index < alarms.length - 1)
                                Padding(
                                  padding: const EdgeInsets.only(left: 70.0),
                                  child: Container(
                                    height: 0.5,
                                    color:
                                        isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[300],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      itemCount: alarms.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _showEditAlarmModal(BuildContext context, AlarmModel alarm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.grey[800];
    final darkBlue = Color(0xFF1F2E36);

    // 현재 알람 데이터로 초기화된 컨트롤러
    final titleController = TextEditingController(text: alarm.title);
    final bodyController = TextEditingController(text: alarm.body);

    // 시간과 분 설정
    int selectedHour = alarm.alarmTime;
    int selectedMinute = alarm.alarmMinute;

    // 반복 알람 설정
    bool isRepeating = alarm.isRepeating;
    List<bool> repeatingDays = List.from(alarm.repeatingDays);

    // 요일 이름
    final List<String> dayNames = ['월', '화', '수', '목', '금', '토', '일'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '알람 수정',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 20),

                    // 반복 알람 스위치
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '반복 알람',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Switch(
                            value: isRepeating,
                            onChanged: (value) {
                              setState(() {
                                isRepeating = value;

                                // 모든 요일 선택/해제
                                if (!value) {
                                  for (int i = 0; i < 7; i++) {
                                    repeatingDays[i] = false;
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
                    if (isRepeating)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '반복 요일',
                              style: TextStyle(
                                color: textColor,
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
                                      repeatingDays[index] =
                                          !repeatingDays[index];
                                      // 하나라도 선택되어 있으면 반복 알람 활성화
                                      isRepeating = repeatingDays.any(
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
                                          repeatingDays[index]
                                              ? Colors.blue
                                              : (isDark
                                                  ? Colors.grey[800]
                                                  : Colors.grey[200]),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      dayNames[index],
                                      style: TextStyle(
                                        color:
                                            repeatingDays[index]
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
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF3A3A3A) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade700),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedHour,
                              ),
                              magnification: 1.2,
                              squeeze: 1.2,
                              useMagnifier: true,
                              itemExtent: 32,
                              onSelectedItemChanged: (int value) {
                                setState(() {
                                  selectedHour = value;
                                });
                              },
                              children: List<Widget>.generate(24, (int index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: textColor,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              ":",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedMinute,
                              ),
                              magnification: 1.2,
                              squeeze: 1.2,
                              useMagnifier: true,
                              itemExtent: 32,
                              onSelectedItemChanged: (int value) {
                                setState(() {
                                  selectedMinute = value;
                                });
                              },
                              children: List<Widget>.generate(60, (int index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: textColor,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // 제목 입력
                    Text(
                      "알람 제목",
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: textColor),
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
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: bodyController,
                      style: TextStyle(color: textColor),
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

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.blue : Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final updatedAlarm = {
                            'id': alarm.id,
                            'alarmTime': selectedHour,
                            'alarmMinute': selectedMinute,
                            'title': titleController.text,
                            'body': bodyController.text,
                            'isRepeating': isRepeating,
                            'repeatingDays': repeatingDays,
                          };

                          onUpdateAlarm(updatedAlarm);
                          Navigator.pop(context);
                        },
                        child: Text(
                          '저장',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((result) {
      // 모달 결과가 있을 때만 처리
      if (result != null) {
        // 결과를 홈페이지의 updateAlarm 메소드로 전달
        onUpdateAlarm(result);
      }

      // 모달이 완전히 닫힌 후 컨트롤러 해제
      titleController.dispose();
      bodyController.dispose();
    });
  }
}

class AlarmItem extends StatelessWidget {
  final AlarmModel alarm;
  final VoidCallback onDelete;
  final bool isDark;
  final Function(int) onToggle;

  const AlarmItem({
    super.key,
    required this.alarm,
    required this.onDelete,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // 요일 표시를 위한 문자열 리스트
    final List<String> dayNames = ['월', '화', '수', '목', '금', '토', '일'];

    // 활성화된 요일을 문자열로 변환
    String repeatingDaysText = '';
    if (alarm.isRepeating) {
      List<String> activeDays = [];
      for (int i = 0; i < 7; i++) {
        if (alarm.repeatingDays[i]) {
          activeDays.add(dayNames[i]);
        }
      }
      repeatingDaysText = activeDays.join(', ');
    } else {
      repeatingDaysText = '반복 안함';
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              onToggle(alarm.id);
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color:
                    alarm.isActivated
                        ? Color(0xFF34C759).withAlpha(isDark ? 70 : 51)
                        : Colors.grey.withAlpha(isDark ? 70 : 51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                CupertinoIcons.alarm,
                color: alarm.isActivated ? Color(0xFF34C759) : Colors.grey,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.body,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${alarm.myDateTime.hour.toString().padLeft(2, '0')}:${alarm.myDateTime.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: alarm.isActivated ? Color(0xFF34C759) : Colors.grey,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      repeatingDaysText,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // SizedBox(width: 8),
                    // Expanded(
                    //   child: Text(
                    //     alarm.body,
                    //     style: TextStyle(
                    //       color: isDark ? Colors.grey[400] : Colors.grey[600],
                    //       fontSize: 14,
                    //     ),
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
