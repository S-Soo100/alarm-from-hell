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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    SizedBox(height: 30),

                    // 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade700,
                          ),
                          child: Text(
                            "취소",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // 알람 업데이트 로직
                            // 여기서는 화면을 닫기만 합니다 (실제 업데이트 기능은 홈페이지에서 구현해야 함)
                            Navigator.of(context).pop({
                              'id': alarm.id,
                              'alarmTime': selectedHour,
                              'alarmMinute': selectedMinute,
                              'title': titleController.text,
                              'body': bodyController.text,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlue,
                          ),
                          child: Text(
                            "저장",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
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
                  alarm.title,
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
                Text(
                  alarm.body,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
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
