import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NextAlarmTimeWidget extends StatelessWidget {
  const NextAlarmTimeWidget({super.key, required this.nextAlarmTime});

  final String nextAlarmTime;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? Color(0xFF2A2A2A) : CupertinoColors.systemBackground;
    final headerColor =
        isDark
            ? Color(0xFF1F2E36).withOpacity(0.5)
            : CupertinoColors.systemBlue.withOpacity(0.1);
    final accentColor = Color(0xFF34C759);
    final textColor = isDark ? Colors.white : CupertinoColors.label;
    final borderColor =
        isDark ? Colors.grey.shade800 : CupertinoColors.systemGrey5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: headerColor,
                    border: Border(
                      bottom: BorderSide(color: borderColor, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.clock, color: accentColor, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "다음 알람",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.alarm,
                        size: 28,
                        color:
                            isDark
                                ? Colors.grey.shade400
                                : CupertinoColors.systemGrey,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          nextAlarmTime,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
