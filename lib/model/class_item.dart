import 'package:quiver/core.dart';

class ClassItem {
  int? id;
  int? weekDay;
  String? subject;
  DateTime? startTime;
  DateTime? endTime;
  String? teacher;
  String? location;

  ClassItem(this.subject, this.startTime, this.endTime,
      {this.teacher, this.location, required this.weekDay});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassItem &&
          id == other.id &&
          weekDay == other.weekDay &&
          subject == other.subject &&
          teacher == other.teacher &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          location == other.location;

  @override
  int get hashCode =>
      hash4(id.hashCode, subject.hashCode, weekDay.hashCode, teacher.hashCode);

  /// Create a [ClassItem] object from a map.
  ClassItem.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    weekDay = map['weekDay'];
    subject = map['subject'];
    startTime = DateTime.parse(map['startTime']);
    endTime = DateTime.parse(map['endTime']);
    location = map['location'];
    teacher = map['teacher'];
  }

  /// Create a [Map] from a [ClassItem] (to be stored in DB).
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["weekDay"] = weekDay;
    map["subject"] = subject;
    map["startTime"] = startTime.toString();
    map["endTime"] = endTime.toString();
    map["location"] = location;
    map["teacher"] = teacher;

    return map;
  }

  @override
  String toString() => """
subject: $subject
teacher: $teacher
startTime: $startTime
endTime: $endTime
location: $location
""";
}
