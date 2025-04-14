import 'package:alarm_from_hell/ui/test_alarm/test_alarm_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alarm From Hell")),
      body: SafeArea(child: Center(child: Column(children: [TestAlarmPage()]))),
    );
  }
}
