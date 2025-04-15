import 'package:alarm_from_hell/component/next_alarm_time_widget.dart';
import 'package:flutter/material.dart';

class AlarmListWidget extends StatefulWidget {
  const AlarmListWidget({super.key});

  @override
  State<AlarmListWidget> createState() => _AlarmListWidgetState();
}

class _AlarmListWidgetState extends State<AlarmListWidget> {
  int _count = 4;

  void _setCountMinus() {
    setState(() {
      _count--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          Text("여기에 List를 추가해주세요."),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ListView.builder(
          //     itemBuilder: (BuildContext context, int index) {
          //       return GestureDetector(
          //         onTap: () => _setCountMinus,
          //         child: NextAlarmTimeWidget(),
          //       );
          //     },
          //     // separatorBuilder: (BuildContext context, int index) => Divider(),
          //     itemCount: _count,
          //     shrinkWrap: true,
          //     physics: BouncingScrollPhysics(),
          //   ),
          // ),
          Divider(),
        ],
      ),
    );
  }
}
