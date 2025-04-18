import 'package:alarm_from_hell/data/model/AlarmModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlarmListWidget extends StatelessWidget {
  final List<AlarmModel> alarms;
  final Function(int) onDeleteAlarm;

  const AlarmListWidget({
    super.key,
    required this.alarms,
    required this.onDeleteAlarm,
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
                              AlarmItem(
                                alarm: alarm,
                                onDelete: () => onDeleteAlarm(alarm.id),
                                isDark: isDark,
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
}

class AlarmItem extends StatelessWidget {
  final AlarmModel alarm;
  final VoidCallback onDelete;
  final bool isDark;

  const AlarmItem({
    super.key,
    required this.alarm,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
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
