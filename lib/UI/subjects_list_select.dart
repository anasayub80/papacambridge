import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:studento/UI/random_gradient.dart';
import 'package:studento/model/MainFolder.dart';
import 'package:studento/model/user_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studento/services/backend.dart';
import 'loading_page.dart';
import 'package:studento/Globals.dart' as globals;
import 'setup_page.dart';

/// Builds a [ListView] containing [CheckBoxListTiles] for each of the
/// subjects. Used during setup.
class SubjectsList extends StatefulWidget {
  final String levelid;
  final String name;
  final VoidCallback? onFloatingButtonPressed2;
  const SubjectsList({
    required this.levelid,
    required this.name,
    this.onFloatingButtonPressed2,
  });
  @override
  // ignore: library_private_types_in_public_api
  _SubjectsListState createState() => _SubjectsListState();
}

class _SubjectsListState extends State<SubjectsList> {
  UserData? userData;
  BoxDecoration topBackgroundDecoration =
      BoxDecoration(gradient: getRandomGradient());

  /// The list of subjects available to the user for his level.
  List<MainFolder> subjects = [];
  bool loading = true;
  @override
  initState() {
    super.initState();
    // userData = Hive.box<UserData>('userData').get(0);
    if (subjects != []) getSubjects();
  }

  void getSubjects() async {
    List<MainFolder> subjectsList = [];

    print("Subject list from json file is: \n $subjectsList");

    String url1 = '$caeiAPI?main_folder=${widget.levelid}&papers=pastpapers';
    print(url1);
    http.Response res = await http.get(Uri.parse(url1));
    print("subject list ${res.body}");
    List<MainFolder> dataL = mainFolderFromJson(res.body);
    setState(() {
      subjects = dataL;
      loading = false;
    });
  }

  List<MainFolder> selectedItem = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildCancelButton(),
            buildDoneButton(),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Column(
          children: [
            buildTopBackground(Icons.book, context, topBackgroundDecoration),
            buildPageCaption("Choose your subjects below for ${widget.name}"),
            if (loading) loadingPage(),
            // if (!loading && subjects.isEmpty)
            //   Expanded(
            //     child: Center(
            //       child: Text(
            //         'No Data Found',
            //         style: Theme.of(context).textTheme.headline4,
            //       ),
            //     ),
            //   ),
            Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 50),
                  itemCount: subjects.length,
                  itemBuilder: (_, int index) {
                    MainFolder currentSubject = subjects[index];
                    String subjectName =
                        currentSubject.name!.replaceAll("\n", "");
                    String subjectCode =
                        currentSubject.folderCode!.replaceAll("\n", "");
                    // bool isSubjectSelected = currentSubject.year == null ? false : true;
                    return CheckboxListTile(
                      activeColor: Colors.blue,
                      value: selectedItem.contains(subjects[index]),
                      selected: selectedItem.contains(subjects[index]),
                      title: Text(
                        " $subjectName",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      secondary: Text(subjectCode),
                      onChanged: (bool? isSelected) => updateChosenSubjects(
                          isSelected!, index, widget.levelid),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDoneButton() => Container(
        height: 50,
        width: 150,
        child: FloatingActionButton.extended(
          tooltip: 'SAVE',
          heroTag: 'SAVE',
          label: Row(
            children: <Widget>[
              Icon(
                Icons.save,
                color: Colors.white,
              ),
              Text("SAVE",
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          onPressed: widget.onFloatingButtonPressed2,
          backgroundColor: Colors.green, // Imperialish blue
          shape: StadiumBorder(),
        ),
      );
  Widget buildCancelButton() => Container(
        height: 50,
        width: 150,
        child: FloatingActionButton.extended(
          heroTag: 'Back',
          tooltip: 'Back',
          label: Row(
            children: <Widget>[
              Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
              Text("Back",
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          onPressed: () {
            BotToast.showLoading();
            Navigator.pop(context, false);
          },
          backgroundColor: Colors.red, // Imperialish blue
          shape: StadiumBorder(),
        ),
      );

  List<String> selected = [];
  void updateChosenSubjects(bool isSelected, int index, levelid) async {
    // print("${subjects[index].toString()}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (selectedItem.contains(subjects[index])) {
        selectedItem.remove(subjects[index]);
        globals.selectedG.remove(subjects[index]);
        selected.remove(subjects[index].id.toString());
      } else {
        selectedItem.add(subjects[index]);
        globals.selectedG.add(subjects[index]);
        selected.add(subjects[index].id.toString());
      }
      // prefs.setStringList('selectedSubject+$lev\elid', selected);
      log('Selected $selected');
      prefs.setStringList('selectedSubject${widget.levelid}', selected);
      // subjects[index].year = isSelected;
      // userData
      //   ..chosenSubjects1 =
      //       subjects.where((subject) => subject.year).toList()
      //   ..save();

      // print("selected subjects are: ${userData.chosenSubjects}");
    });
  }
}
