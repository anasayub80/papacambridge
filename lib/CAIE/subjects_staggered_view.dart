// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:studento/UI/random_gradient.dart';
import 'package:studento/UI/loading_page.dart';
import 'package:studento/model/MainFolder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// past papers

// ignore: must_be_immutable
class SubjectsStaggeredListView extends StatefulWidget {
  // String mainFolder;
  String levelid;

  SubjectsStaggeredListView(
      this.onGridTileTap,
      //  this.mainFolder,
      this.levelid);

  /// The function to execute when a GridTile is
  /// tapped.
  final Function(MainFolder subject) onGridTileTap;

  @override
  _SubjectsStaggeredListViewState createState() =>
      _SubjectsStaggeredListViewState();
}

class _SubjectsStaggeredListViewState extends State<SubjectsStaggeredListView> {
  List<MainFolder> subjects = [];
  // BannerAd _bannerAd;
  Widget? subjectTilesBuilder;
  List<MainFolder> data = [];
  List<String> selected = [];
  @override
  void initState() {
    super.initState();

    initSubjects();
    // PdfHelper.checkIfPro().then((isPro) {
    //   if (!isPro) {
    //     _bannerAd = createBannerAd()..load();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Choose a subject",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
            ),
          ),
        ),
        isloading == true
            ? loadingPage()
            : (data.isEmpty)
                ? Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Nothing Found',
                          style: Theme.of(context).textTheme.headline3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: StaggeredGridView(
                      shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(15),
                      children: data
                          .map(
                              (MainFolder subject) => buildSubjectTile(subject))
                          .toList(),
                      gridDelegate:
                          SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        staggeredTileBuilder: (int i) =>
                            StaggeredTile.count(2, i.isEven ? 2 : 3),
                        mainAxisSpacing: 15.0,
                        crossAxisSpacing: 15.0,
                        staggeredTileCount: data.length,
                      ),
                    ),
                  ),
      ],
    );
  }

  @override
  void deactivate() {
    // _bannerAd?.dispose();
    super.deactivate();
  }

  List<String> mainFolder = [];

  // getfolderid() async {
  //   switch (widget.mainFolder) {
  //     case 'O Level':
  //       return '32494';
  //     case 'A Level':
  //       return '7094';
  //     case 'PreU':
  //       return '30141';
  //     default:
  //       return '41683';
  //   }
  // }

  bool isloading = true;
  void initSubjects() async {
    log('***subject init simple***');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> selectedSubjectList =
        prefs.getStringList('selectedSubject${widget.levelid}') ?? [];
    print("selected subject list $selectedSubjectList & id${widget.levelid}");
    // var mainFolder = await getfolderid();
    String url =
        'https://papacambridge.com/api.php?main_folder=${widget.levelid}&papers=pastpapers';
    log(url.toString());
    http.Response res = await http.get(Uri.parse(url));
    // http.Response res = await http.post(Uri.parse(innerFileApi), body: {
    //   'token': token,
    //   'fileid': widget.levelid,
    // });

    log(res.body);
    List<MainFolder> dataL = mainFolderFromJson(res.body);
    // UserData userData = Hive.box<UserData>('userData').get(0);
    List<MainFolder> selectedM = [];
    log('Model Data ${dataL[0].id.toString()}');
    for (var subject in dataL) {
      if (selectedSubjectList.contains(subject.id.toString())) {
        print('1 \n ${subject.name.toString()}');
        selectedM.add(subject);
      }
    }
    log("${selectedM.toString()} data res");
    setState(() {
      log('call setState');
      // selected = getlist;
      isloading = false;
      data = selectedM;
      // subjects = userData.chosenSubjects;
    });
  }

  Widget buildSubjectTile(MainFolder subject) {
    TextStyle subjectNameStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontSize: 16.0,
    );

    Widget subjectNameText = Text(
      prettifySubjectName(subject.name!),
      textAlign: TextAlign.center,
      overflow: TextOverflow.fade,
      style: subjectNameStyle,
    );

    Widget subjectCodeText = Text(
      " \n(${subject.folderCode})",
      style: TextStyle(fontSize: 14.0, color: Colors.white),
    );

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 2.0,
      color: Colors.transparent,
      child: Ink(
        child: InkWell(
          onTap: () => widget.onGridTileTap(subject),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: subjectNameText,
              ),
              subjectCodeText,
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
        decoration: BoxDecoration(
          gradient: getRandomGradient(),
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
      ),
    );
  }

  /// Breaks lengthy subject names into two lines.
  String prettifySubjectName(String subjectName) {
    return subjectName.replaceFirst(" ", " \n");
  }
}
