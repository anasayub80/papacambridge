// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LevelAdapter extends TypeAdapter<Level?> {
  @override
  final typeId = 1;

  @override
  Level? read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Level.O;
      case 1:
        return Level.A;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, Level? obj) {
    switch (obj!) {
      case Level.O:
        writer.writeByte(0);
        break;
      case Level.A:
        writer.writeByte(1);
        break;
      case Level.PreU:
        // ignore: todo
        // TODO: Handle this case.
        break;
      case Level.Igcse:
        // ignore: todo
        // TODO: Handle this case.
        break;
    }
  }
}

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final typeId = 0;

  @override
  UserData read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserData(
      fields[0] as bool,
      fields[1] as Level,
      (fields[2] as List).cast<Subject>(),
      isPro: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.isSetupComplete)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.chosenSubjects)
      ..writeByte(3)
      ..write(obj.isPro);
  }
}
