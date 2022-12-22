import 'package:studento/model/MainFolder.dart';
import 'package:hive/hive.dart';
import 'package:studento/model/subject.dart';

part 'user_data.g.dart';

@HiveType(typeId: 0)
class UserData extends HiveObject {
  @HiveField(0)
  bool? isSetupComplete;
  @HiveField(1)
  Level? level;
  @HiveField(2)
  List<Subject>? chosenSubjects;
  List<MainFolder>? chosenSubjects1;
  @HiveField(3)
  bool? isPro;

  UserData(this.isSetupComplete, this.level, this.chosenSubjects, {this.isPro});
}

@HiveType(typeId: 1)
enum Level {
  @HiveField(0)
  O,
  @HiveField(1)
  A,
  @HiveField(2)
  // ignore: constant_identifier_names
  PreU,
  @HiveField(3)
  // ignore: constant_identifier_names
  Igcse,
}

extension LevelExtension on Level {
  String? get value {
    switch (this) {
      case Level.O:
        return 'O Level';
      case Level.A:
        return 'A Level';
      case Level.PreU:
        return 'Pre U';
      case Level.Igcse:
        return 'Igcse';
      default:
        return null;
    }
  }
}
