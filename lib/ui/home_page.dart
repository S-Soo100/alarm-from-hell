import 'package:alarm_from_hell/component/alarm_list_widget.dart';
import 'package:alarm_from_hell/component/next_alarm_time_widget.dart';
import 'package:alarm_from_hell/ui/test_alarm/test_alarm_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isModalOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 31, 46, 54),
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
              icon: Icon(Icons.add, size: 40),
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
                  NextAlarmTimeWidget(),
                  AlarmListWidget(),
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
    return _isModalOn
        ? Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  spreadRadius: 0.3,
                  blurRadius: 0.3,
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
            width: MediaQuery.sizeOf(context).width * 0.9,
            height: MediaQuery.sizeOf(context).height * 0.7,
          ),
        )
        : SizedBox();
  }
}
