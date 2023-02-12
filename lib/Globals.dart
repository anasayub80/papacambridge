import 'package:studento/model/MainFolder.dart';

List<MainFolder> selectedG = [];
List domainIDList = [];
String prettifySubjectName(String subjectName) {
  var name = subjectName.replaceFirst("\r", "");
  return name.replaceFirst("\n", "");
}
