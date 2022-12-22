import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:quiver/core.dart';

part 'subject.g.dart';

@HiveType(typeId: 2)
class Subject extends HiveObject {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject &&
          subjectCode == other.subjectCode &&
          name == other.name;

  @override
  int get hashCode => hash2(name.hashCode, subjectCode.hashCode);

  @override
  String toString() =>
      "Subject name: $name \nCode: $subjectCode \nstartYear: $startYear \nendYear: $endYear";

  /// Create a subject object from a map.
  Subject.fromMap(Map<String, dynamic> map) {
    name = map['subject_name'];
    subjectCode = map['subject_code'];
    startYear = map['start_year'];
    endYear = map['end_year'];
  }

  List<Subject> SubjectFromMap(String str) =>
      List<Subject>.from(json.decode(str).map((x) => Subject.fromMap(x)));
  Subject(
    this.name,
    this.subjectCode,
    this.startYear,
    this.endYear,
  );

  @HiveField(0)
  int? subjectCode;

  @HiveField(1)
  String? name;

  @HiveField(2)
  int? startYear;

  @HiveField(3)
  int? endYear;

  @HiveField(4)
  bool? isSelected = false;
}
