import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:alarm_from_hell/core/constants/sound_constants.dart';
import 'package:flutter/material.dart';

class TestAlarmPage extends StatefulWidget {
  const TestAlarmPage({super.key});

  @override
  State<TestAlarmPage> createState() => _TestAlarmPageState();
}

class _TestAlarmPageState extends State<TestAlarmPage> {
  DateTime time = DateTime.now();
  AlarmSettings? alarmSettings;

  @override
  void initState() {
    super.initState();

    alarmSettings = AlarmSettings(
      id: 42,
      dateTime: time.add(Duration(seconds: 10)),
      assetAudioPath: SoundConstants.testAlarmSound,
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: Duration(seconds: 5),
        volumeEnforced: true,
      ),
      notificationSettings: const NotificationSettings(
        title: 'This is the title',
        body: 'This is the body',
        stopButton: 'Stop the alarm',
        icon: 'notification_icon',
        iconColor: Color(0xff862778),
      ),
    );

    setTestAlarm();
  }

  void setTestAlarm() async {
    if (alarmSettings != null) {
      await Alarm.set(alarmSettings: alarmSettings!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: [
            Text('alarm setting'),
            Text("${alarmSettings!.id.toString()}"),
          ],
        ),
      ),
    );
  }
}
