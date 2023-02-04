import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:studento/model/subject.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class TestPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _selectedLevel = 'A';
  List<Subject> subjects = [];

  Map<String, List> componentsListMap = {};
  Map urlListMap = {};
  Map mirrorNames = {};
  Map mirrorNames2 = {};

  List<String> syllabusUrls = [];
  List<int> codes = [];

  List<int> unknowns = [];
  List<int> craponents = [];
  List<int> linkDupes = [];
  List<int> codeDupes = [];

  @override
  void initState() {
    super.initState();
    getSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Spacer(flex: 2),
            Text("$_selectedLevel Level"),
            Switch(
                value: _selectedLevel == 'O',
                onChanged: (bool val) {
                  setState(
                    () => _selectedLevel = (val) ? 'O' : 'A',
                  );
                  getSubjects();
                }),
            Spacer(),
            ElevatedButton.icon(
              onPressed: _testSubjects,
              icon: Icon(Icons.book),
              label: Text("Test Subjects"),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: _testSyllabus,
              icon: Icon(Icons.burst_mode),
              label: Text("Test Syllabus"),
            ),
            Spacer(flex: 2)
          ],
        ),
      ),
    );
  }

  void _testSyllabus() async {
    print("Syllabus test started...");
    for (var link in syllabusUrls) {
      Dio dio = Dio(BaseOptions(
        connectTimeout: 6000,
        validateStatus: (status) {
          return status == 200 ? true : false;
        },
        receiveTimeout: 50000,
      ));
      String cambridgeSyllabusUrlPrefix =
          "http://www.cambridgeinternational.org/Images";
      var url = cambridgeSyllabusUrlPrefix + link;
      Response response;
      try {
        response = await dio.head(url).catchError((Object error) {
          // ignore: unused_local_variable
          DioError myerror = error as DioError;
          print("Failed for $url. MSG: ${error.message}");
          // ignore: invalid_return_type_for_catch_error
          return myerror.message;
        });
        if (response.statusCode == 200) {
          print("SUCESS");
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    print('Test finished');
  }

  void _testSubjects() async {
    List<int> missingforOne = [];
    List<int> missingforTwo = [];
    List<int> missingForZero = [];

    for (var subject in subjects) {
      Dio dio = Dio(BaseOptions(
        connectTimeout: 6000,
        validateStatus: (status) {
          return status == 200 ? true : false;
        },
        receiveTimeout: 50000,
      ));

      // ignore: unused_local_variable
      Response response;
      // ignore: unused_local_variable
      var name1 = mirrorNames[_selectedLevel]["${subject.subjectCode}"];
      // ignore: unused_local_variable
      var name2 = mirrorNames2[_selectedLevel]["${subject.subjectCode}"];

      // ignore: unnecessary_null_comparison
      if (subject.name != null) {
        print(subject.name);
        var prefix = "https://papers.xtremepape.rs/CAIE/";
        var level = "$_selectedLevel Level/".replaceFirst("A", "AS and A");

        String suffix = subject.name!
            .replaceFirst(" Language", " - Language")
            .replaceFirst("(AS)", " (AS Level only)")
            .replaceFirst("(A Level)", " (A Level only)");
        switch (subject.subjectCode) {
          case 8281:
            suffix =
                suffix.replaceFirst("Japanese - Language", "Japanese Language");
            break;
          case 8665:
            suffix = suffix.replaceFirst(
                "Spanish First - Language", "Spanish - First Language");
            break;
          case 3247:
            suffix = suffix.replaceFirst(
                "Urdu - First - Language", "Urdu - First Language");
            break;
          case 3248:
            suffix = suffix.replaceFirst(
                "Urdu - Second - Language", "Urdu - Second Language");
            break;
          case 8291:
            suffix = suffix.replaceFirst(
                "Environmental Management (AS Level only)",
                "Environmental Management (AS only)");
            break;
          case 8058:
            suffix = suffix.replaceFirst(
                "Hinduism (AS Level only)", "Hinduism (AS level only)");
            break;
          case 9686:
            suffix =
                suffix.replaceFirst("Urdu - Pakistan", "Urdu - Pakistan only");
            break;
          case 4037:
            suffix = suffix.replaceFirst(
                "Additional Mathematics", "Mathematics - Additional");

            break;
          default:
            if (subject.subjectCode == 9479 || subject.subjectCode == 9483)
              suffix = suffix.replaceAll("(New)", '');
        }
        suffix = suffix.replaceFirst("&", "and").replaceAll(" ", "%20");
        var url = "$prefix$level$suffix%20(${subject.subjectCode})";

        print(url);
        try {
          // ignore: body_might_complete_normally_catch_error
          response = await dio.head(url).catchError((Object error) {
            // ignore: no_leading_underscores_for_local_identifiers
            DioError _error = error as DioError;
            print(
                "Display 0 failed for ${subject.subjectCode}. MSG: ${_error.message}");
          });
          List<int> components =
              componentsListMap[subject.subjectCode.toString()]!
                  .toList()
                  .cast<int>();
          print("Testing $components for ${subject.subjectCode}");
          for (var component in components) {
            for (var i = 10; i < 20; i++) {
              var fileUrl =
                  "$url/${subject.subjectCode}_w${i}_qp_$component.pdf";
              // ignore: body_might_complete_normally_catch_error
              response = await dio.head(fileUrl).catchError((Object error) {
                // ignore: no_leading_underscores_for_local_identifiers
                DioError _error = error as DioError;
                print(
                    "Component $component failed for ${subject.subjectCode} for year $i. MSG: ${_error.message}");
              });
            }
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      } else {
        missingForZero.add(subject.subjectCode!);
      }
      // if (name1 != null) {
      //   print(name1);
      //   var prefix =
      //       "https://pastpapers.co/cie/?dir=$_selectedLevel-Level/fatra";
      //   var url = prefix + name1;
      //   try {
      //     response = await dio.head(url).catchError((Object error) {
      //       DioError _error = error;
      //       print(
      //           "Display 1 failed for ${subject.subjectCode}. MSG: ${_error.message}");
      //     });
      //     print(response.statusCode);
      //   } catch (e) {}
      // } else {
      //   missingforOne.add(subject.subjectCode);
      // }

      // if (name2 != null) {
      //   print(name2);
      //   var prefix =
      //       "https://papers.gceguide.com/$_selectedLevel%20Levels/fatra";
      //   var url = prefix + name1;
      //   try {
      //     response = await dio.head(url).catchError((Object error) {
      //       DioError _error = error;
      //       print(
      //           "Display 2 failed for ${subject.subjectCode}. MSG: ${_error.message}");
      //     });
      //     print(response.statusCode);
      //   } catch (e) {}
      // } else {
      //   missingforTwo.add(subject.subjectCode);
      // }
    }
    print("Display name 1 missing for $missingforOne");
    print("Display name 2 missing for $missingforTwo");
  }

  void getSubjects() async {
    /// Actual type: [Map<String, dynamic>]
    /// Because of json_decode, can't strong type this.
    // ignore: no_leading_underscores_for_local_identifiers
    List<dynamic> _subjectsList = [];
    subjects = [];
    syllabusUrls = [];

    /// Holds decoded data from json file. We can't directly use this, because
    /// it contains subjects for both levels.
    Map<String, dynamic> decodedSubjectData;

    String subjectData =
        await rootBundle.loadString("assets/json/subjects_list.json");
    decodedSubjectData = json.decode(subjectData);

    /// Filter out the subjects that aren't for the user's level.
    _subjectsList = decodedSubjectData[_selectedLevel];

    print("Subject list from json file is: \n $_subjectsList");
    await loadUrlList();
    await loadComponents();
    await loadDisplayNames();

    setState(() {
      for (var subjectMap in _subjectsList) {
        var subject = Subject.fromMap(subjectMap);
        print(subject.toString());

        if (codes.contains(subject.subjectCode)) {
          codeDupes.add(subject.subjectCode!);
        }
        codes.add(subject.subjectCode!);

        var link = _constructSubjectUrl(subject.subjectCode!, urlListMap);
        if (syllabusUrls.contains(link) && link != '') {
          linkDupes.add(subject.subjectCode!);
        }
        if (link != '') {
          syllabusUrls.add(link);
        }

        checkComponent(subject.subjectCode!);

        subjects.add(subject);
      }
      print(unknowns.toString());
      print("\nCraponents\n");
      print(craponents.toString());
      print("\nDupes\n");
      print(linkDupes.toString());
      print("\nCode Dupes\n");
      print(codeDupes.toString());
    });
  }

  /// Load the list of URLs corresponding to each subject's syllabi.
  Future<void> loadUrlList() async {
    var assetPath = 'assets/json/subjects_syllabus_urls.json';

    var dataStr = await rootBundle.loadString(assetPath);
    setState(() {
      urlListMap = json.decode(dataStr);
    });
  }

  /// Construct the syllabus url for the given [code] from the
  /// [urlList].
  String _constructSubjectUrl(int subjectCode, Map urlList) {
    String subjectSpecificUniqueUrlComponent = '';
    try {
      subjectSpecificUniqueUrlComponent = urlList["$subjectCode"]['url'];
    } catch (e) {
      unknowns.add(subjectCode);
    }

    return subjectSpecificUniqueUrlComponent;
  }

  checkComponent(int code) {
    try {
      List components = componentsListMap["$code"]!;
      if (components.isEmpty) {
        craponents.add(code);
      }
    } catch (e) {
      craponents.add(code);
    }
  }

  /// Loads the components of the selected subjects from json file.
  Future<void> loadComponents() async {
    var dataStr = await rootBundle.loadString('assets/json/components.json');
    setState(() {
      componentsListMap = Map<String, List>.from(json.decode(dataStr));
    });
  }

  Future<void> loadDisplayNames() async {
    var data = await rootBundle.loadString('assets/json/display_names.json');
    var data2 = await rootBundle.loadString('assets/json/display_names_2.json');

    setState(() {
      mirrorNames = json.decode(data);
      mirrorNames2 = json.decode(data2);
    });
  }
}
