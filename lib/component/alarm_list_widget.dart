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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 알람 목록 제목 및 개수 표시
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "알람 목록",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                // 알람 개수 표시 (활성화된 알람 / 전체 알람)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF1F2E36) : Color(0xFFE8F0F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${alarms.where((a) => a.isActivated).length}/${alarms.length}",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Color(0xFF1F2E36),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 알람 목록 영역
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child:
                  alarms.isEmpty
                      ? Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 30 : 13),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.alarm,
                              size: 48,
                              color:
                                  isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              "등록된 알람이 없습니다",
                              style: TextStyle(
                                color:
                                    isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "+ 버튼을 눌러 알람을 추가하세요",
                              style: TextStyle(
                                color:
                                    isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
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
                          borderRadius: BorderRadius.circular(16),
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            itemBuilder: (BuildContext context, int index) {
                              final alarm = alarms[index];
                              return Dismissible(
                                key: Key(alarm.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 20.0),
                                  color: Colors.red.shade700,
                                  child: Icon(
                                    Icons.delete_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
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
                                                () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                            child: Text('아니오'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(true),
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
                                child: GestureDetector(
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
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 84.0),
                                child: Container(
                                  height: 0.5,
                                  color:
                                      isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[300],
                                ),
                              );
                            },
                            itemCount: alarms.length,
                            shrinkWrap: false,
                            physics: BouncingScrollPhysics(),
                          ),
                        ),
                      ),
            ),
          ),
        ],
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
      repeatingDaysText = activeDays.join(' · ');
    } else {
      repeatingDaysText = '일회성 알람';
    }

    // 알람 상태에 따른 색상 설정
    final Color activeColor = Color(0xFF34C759); // 활성화 색상 (녹색)
    final Color inactiveColor =
        isDark ? Colors.grey.shade500 : Colors.grey.shade600; // 비활성화 색상
    final Color timeColor = alarm.isActivated ? activeColor : inactiveColor;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          // 알람 아이콘 및 상태 표시 (활성화/비활성화)
          GestureDetector(
            onTap: () {
              onToggle(alarm.id);
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color:
                    alarm.isActivated
                        ? activeColor.withOpacity(0.15)
                        : inactiveColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: alarm.isActivated ? activeColor : inactiveColor,
                  width: 1.5,
                ),
              ),
              child: Icon(
                CupertinoIcons.alarm_fill,
                color: alarm.isActivated ? activeColor : inactiveColor,
                size: 22,
              ),
            ),
          ),
          SizedBox(width: 18),

          // 알람 정보 표시
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 시간 표시 (더 크게)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "${alarm.myDateTime.hour.toString().padLeft(2, '0')}:${alarm.myDateTime.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: timeColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    // 알람 상태 표시 (활성화/비활성화)
                    Text(
                      alarm.isActivated ? "활성화" : "비활성화",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: timeColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),

                // 알람 제목/내용
                Text(
                  alarm.body,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),

                // 반복 요일 정보
                Row(
                  children: [
                    Icon(
                      alarm.isRepeating
                          ? Icons.repeat
                          : Icons.looks_one_outlined,
                      size: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      repeatingDaysText,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
