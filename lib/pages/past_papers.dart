import 'dart:async';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:studento/model/MainFolder.dart';
import 'package:flutter/material.dart';

import '../UI/loading_page.dart';
import '../UI/mainFilesList.dart';
import 'past_papers_details_select.dart';
import 'package:studento/UI/studento_app_bar.dart';
import 'package:studento/CAIE/subjects_staggered_view.dart';

// ignore: must_be_immutable
class PastPapersPage extends StatefulWidget {
  String domainId;
  PastPapersPage({required this.domainId});
  @override
  // ignore: library_private_types_in_public_api
  _PastPapersPageState createState() => _PastPapersPageState();
}

class _PastPapersPageState extends State<PastPapersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: StudentoAppBar(
          title: "Past Papers",
          context: context,
        ),
        body: mainFilesList(
          domainId: widget.domainId,
          title: 'Past Papers',
        )
        //  SubjectsStaggeredListView(openPastPapersDetailsSelect),
        );
  }
}

class PastPapersPageCAIE extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _PastPapersPageCAIEState createState() => _PastPapersPageCAIEState();
}

class _PastPapersPageCAIEState extends State<PastPapersPageCAIE> {
  @override
  void initState() {
    super.initState();
    // getData();
    getMyData();
  }

  List? level;
  List? levelid;
  initLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    level = prefs.getStringList('level');
    levelid = prefs.getStringList('levelid');
    print(level.toString());
    print(levelid.toString());
    return level;
  }

  var res;
  getMyData() async {
    await initLevel();
    if (level!.length >= 2) {
      return getData();
    } else {
      log('done');
      setState(() {
        res = levelid![0];
      });
      _streamController.add(res);
    }
  }

  getData() async {
    Future.delayed(
      Duration.zero,
      () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text('Select Level'),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              content: ListView.builder(
                shrinkWrap: true,
                itemCount: level!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.pop(context, index);
                    },
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(level![index]),
                    ),
                  );
                },
              ),
            );
          },
        ).then((indexFromDialog) {
          // use the value as you wish
          print(
              "Level Name ${level![indexFromDialog]}, Level Id ${levelid![indexFromDialog]}");
          setState(() {
            res = levelid![indexFromDialog];
          });
          _streamController.add(res);
        });
      },
    );
  }

  @override
  void dispose() {
    _streamController.close();
    // ignore: todo
    // TODO: implement dispose
    super.dispose();
  }

  StreamController _streamController = StreamController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StudentoAppBar(
        title: "Past Papers",
        context: context,
      ),
      // body: SubjectsStaggeredListView(openPastPapersDetailsSelect),
      body: StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return loadingPage();
            default:
              if (snapshot.hasError) {
                return Text('Error');
              } else if (res != null) {
                log(res);
                return SubjectsStaggeredListView(
                    openPastPapersDetailsSelect, res);
              } else {
                return loadingPage();
              }
          }
        },
      ),
    );
  }

  void openPastPapersDetailsSelect(MainFolder subject) {
    // Open the past_paper_details_select page.
    print('hhhhhhhhhhhhhhhh');
    print(subject.name);
    print(subject.parent);
    print(subject.id);
    // return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
              PaperDetailsSelectionPage(subject)),
    );
  }
}
