import 'package:flutter/material.dart';

class NextAlarmTimeWidget extends StatefulWidget {
  const NextAlarmTimeWidget({super.key});

  @override
  State<NextAlarmTimeWidget> createState() => _NextAlarmTimeWidgetState();
}

class _NextAlarmTimeWidgetState extends State<NextAlarmTimeWidget> {
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
            children: [Text("다음 알람은 00000시 입니다.")],
          ),
        ),
      ),
    );
  }
}
