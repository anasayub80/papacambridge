import 'dart:async';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studento/model/MainFolder.dart';
import 'package:flutter/material.dart';

import '../UI/loading_page.dart';
import '../UI/mainFilesList.dart';
import 'past_papers_details_select.dart';
import 'package:studento/UI/studento_app_bar.dart';
import 'package:studento/UI/subjects_staggered_view.dart';

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
    getData();
  }

  List? level;
  List? levelid;
  initLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    level = prefs.getStringList('level');
    levelid = prefs.getStringList('levelid');
    print(level.toString());
    return level;
  }

  var res;
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
              content: FutureBuilder<dynamic>(
                future: initLevel(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());

                    default:
                      if (snapshot.hasError) {
                        return Text('Error');
                      } else if (snapshot.data != null) {
                        return ListView.builder(
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

                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: GestureDetector(
                            //     onTap: () {
                            //       Navigator.pop(context, level![index]);
                            //     },
                            //     child: Container(
                            //       child: Column(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         crossAxisAlignment: CrossAxisAlignment.center,
                            //         mainAxisSize: MainAxisSize.max,
                            //         children: [
                            //           Image.asset(
                            //             'assets/icons/folder.png',
                            //             height: 45,
                            //             width: 45,
                            //           ),
                            //           Padding(
                            //             padding: const EdgeInsets.all(8.0),
                            //             child: Text(level![index]),
                            //           )
                            //         ],
                            //       ),
                            //       decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(16),
                            //           color: Theme.of(context).cardColor),
                            //     ),
                            //   ),
                            // );
                          },
                        );
                      } else {
                        return loadingPage();
                      }
                  }
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
              return Center(child: CircularProgressIndicator());
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
