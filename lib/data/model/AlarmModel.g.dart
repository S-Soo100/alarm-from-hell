// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AlarmModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmModelAdapter extends TypeAdapter<AlarmModel> {
  @override
  final int typeId = 0;

  @override
  AlarmModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmModel(
      id: fields[0] as int,
      alarmTime: fields[1] as int,
      alarmMinute: fields[2] as int,
      assetAudioPath: fields[3] as String,
      loopAudio: fields[4] as bool,
      vibrate: fields[5] as bool,
      warningNotificationOnKill: fields[6] as bool,
      androidFullScreenIntent: fields[7] as bool,
      volume: fields[8] as double,
      fadeDuration: Duration(milliseconds: fields[9] as int),
      volumeEnforced: fields[10] as bool,
      title: fields[11] as String,
      body: fields[12] as String,
      stopButton: fields[13] as String,
      isActivated: fields[14] as bool,
      isRepeating:
          fields.containsKey(15) ? (fields[15] as bool?) ?? false : false,
      repeatingDays:
          fields.containsKey(16)
              ? ((fields[16] as List?)?.cast<bool>()) ?? List.filled(7, false)
              : List.filled(7, false),
    );
  }

  @override
  void write(BinaryWriter writer, AlarmModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.alarmTime)
      ..writeByte(2)
      ..write(obj.alarmMinute)
      ..writeByte(3)
      ..write(obj.assetAudioPath)
      ..writeByte(4)
      ..write(obj.loopAudio)
      ..writeByte(5)
      ..write(obj.vibrate)
      ..writeByte(6)
      ..write(obj.warningNotificationOnKill)
      ..writeByte(7)
      ..write(obj.androidFullScreenIntent)
      ..writeByte(8)
      ..write(obj.volume)
      ..writeByte(9)
      ..write(obj.fadeDurationMillis)
      ..writeByte(10)
      ..write(obj.volumeEnforced)
      ..writeByte(11)
      ..write(obj.title)
      ..writeByte(12)
      ..write(obj.body)
      ..writeByte(13)
      ..write(obj.stopButton)
      ..writeByte(14)
      ..write(obj.isActivated)
      ..writeByte(15)
      ..write(obj.isRepeating)
      ..writeByte(16)
      ..write(obj.repeatingDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
