import 'package:flutter/material.dart';

class NextAlarmTimeWidget extends StatelessWidget {
  const NextAlarmTimeWidget({super.key, required this.nextAlarmTime});

  final String nextAlarmTime;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.amber),
          height: 80,
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(nextAlarmTime)],
          ),
        ),
      ),
    );
  }
}
