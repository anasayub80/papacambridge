// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studento/UI/random_gradient.dart';
import 'package:studento/UI/loading_page.dart';
import 'package:studento/UI/studento_app_bar.dart';
import 'package:studento/model/MainFolder.dart';
import 'package:http/http.dart' as http;

import '../pages/inner_files_screen.dart';
import '../pages/syllabus.dart';
import '../services/backend.dart';

// without caie
// ignore: must_be_immutable
class SubjectsStaggeredListViewS extends StatefulWidget {
  String mainFolder;
  String inner_file;
  // folder id = inner_file
  SubjectsStaggeredListViewS(
      // this.onGridTileTap,
      this.mainFolder,
      this.inner_file);

  /// The function to execute when a GridTile is
  /// tapped.
  // final Function(MainFolder subject) onGridTileTap;

  @override
  _SubjectsStaggeredListViewStateS createState() =>
      _SubjectsStaggeredListViewStateS();
}

class _SubjectsStaggeredListViewStateS
    extends State<SubjectsStaggeredListViewS> {
  List<MainFolder> subjects = [];
  // BannerAd _bannerAd;
  Widget? subjectTilesBuilder;
  List<MainFolder> data = [];
  @override
  void initState() {
    super.initState();
    initSubjects();
    // PdfHelper.checkIfPro().then((isPro) {
    // if (!isPro!) {
    //     // _bannerAd = createBannerAd()..load();
    //   }
    // });
  }

  @override
  void dispose() {
    subjects == [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StudentoAppBar(
        title: widget.mainFolder,
        context: context,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
            child: Text(
              "Choose a subject",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 30,
                  color: Theme.of(context).textTheme.titleMedium!.color),
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
                            .map((MainFolder subject) =>
                                buildSubjectTile(subject))
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
      ),
    );
  }

  @override
  void deactivate() {
    // _bannerAd?.dispose();
    super.deactivate();
  }

  bool isloading = true;

  void initSubjects() async {
    log('***subject init***');
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // List<String> getlist = prefs.getStringList('selectedSubject') ?? [];
    // print(getlist);

    // var mainFolder = await getfolderid();

    http.Response res = await http.post(Uri.parse(innerFileApi), body: {
      'token': token,
      'fileid': widget.inner_file,
    });
    List<MainFolder> dataL = mainFolderFromJson(res.body);
    // debugPrint(res.body);
    // UserData userData = Hive.box<UserData>('userData').get(0);
    List<MainFolder> selectedM = [];
    for (var subject in dataL) {
      // if (getlist.contains(subject.id.toString())) {
      selectedM.add(subject);
      // }
    }
    setState(() {
      // selected = getlist;
      data = selectedM;
      isloading = false;
      // subjects = selectedM;
      // subjects = userData.chosenSubjects;
    });
  }

  Widget buildSubjectTile(MainFolder subject) {
    String subjectName = "${subject.name}!";
    List<String> listo = subjectName.split(' ');
    TextStyle subjectNameStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontSize: 20.0,
    );

    Widget subjectNameText = Text(
      prettifySubjectName(listo[0]), //(subject.name),
      textAlign: TextAlign.center,
      overflow: TextOverflow.fade,
      style: subjectNameStyle,
    );

    Widget subjectCodeText = Text(
      " \n(${listo[0]})",
      style: TextStyle(fontSize: 18.0, color: Colors.white),
    );

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 2.0,
      color: Colors.transparent,
      child: Ink(
        child: InkWell(
          // onTap: () => widget.onGridTileTap(subject),
          onTap: () {
            // log('this is my pdf ${widget.subjectPdfUrl} url');
            launchSyllabusView(subject);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              subjectNameText,
              subjectCodeText,
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

  launchSyllabusView(MainFolder subject) {
    if (subject.urlPdf != "") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SyllabusPdfView(subject),
          ));
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return innerfileScreen(
            inner_file: subject.id,
            title: '',
          );
        },
      ));
    }
  }
  // BannerAd createBannerAd() => BannerAd(
  //       adUnitId: ads.bannerAdUnitId,
  //       targetingInfo: ads.targetingInfo,
  //       size: AdSize.smartBanner,
  //       listener: (MobileAdEvent event) {
  //         if (event == MobileAdEvent.loaded) {
  //           // dispose after you received the loaded event seems okay.
  //           if (mounted) {
  //             _bannerAd..show();
  //           } else {
  //             _bannerAd = null;
  //           }
  //         }
  //       },
  //     );
}
