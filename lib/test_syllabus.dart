import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

// Couldn't really figure out how to test all my syllabus files from the test
// rofl, so here it is as a standalone app.
void main() {
  runApp(studento());
}

class studento extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _studentoState createState() => _studentoState();
}

class _studentoState extends State<studento> {
  var urlList;
  void setup() async {
    var assetPath = 'assets/json/subjects_syllabus_urls.json';
    String file = await rootBundle.loadString(assetPath);
    urlList = json.decode(file);

    assetPath = "assets/json/subjects_list.json";
    file = await rootBundle.loadString(assetPath);
    final subjectList = json.decode(file);

    var oLevelSubjects = subjectList["O level"];
    var aLevelSubjects = subjectList["A level"];

    oLevelSubjects.forEach(testSubjects);
    aLevelSubjects.forEach(testSubjects);
  }

  testSubjects(var subject) async {
    String cambridgeSyllabusUrlPrefix =
        "http://www.cambridgeinternational.org/Images";

    int code = subject["subject_code"];

    String subjectSpecificUniqueUrlComponent = urlList["$code"]['url'];

    String url = cambridgeSyllabusUrlPrefix + subjectSpecificUniqueUrlComponent;
    print("URL is $url");
    var dir = await getApplicationDocumentsDirectory();
    var filePath = "${dir.path}random";
    var file = File(filePath);

    Dio dio = Dio();
    Response response = await dio.download(url, file.path,
        onReceiveProgress: (received, total) {
      var progress = "${((received / total) * 100).toStringAsFixed(0)}%";
      print(progress.toString());
    });

    bool isResponseValid = response.statusCode == 200 &&
        response.headers.value(Headers.contentTypeHeader) == "application/pdf";

    if (isResponseValid) {
      print("Well received");
    } else {
      print("Well no shit.");
    }
  }

  @override
  Widget build(BuildContext context) {
    setup();
    return Container();
  }
}
