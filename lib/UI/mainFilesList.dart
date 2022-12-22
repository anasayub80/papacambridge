import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studento/UI/subjects_staggered_viewS.dart';
import 'package:studento/pages/inner_files_screen.dart';
import 'package:studento/services/backend.dart';

import '../model/MainFolder.dart';
import 'package:http/http.dart' as http;

class mainFilesList extends StatefulWidget {
  final domainId;
  final title;
  const mainFilesList({super.key, required this.domainId, required this.title});

  @override
  State<mainFilesList> createState() => _mainFilesListState();
}

class _mainFilesListState extends State<mainFilesList> {
  List allItem = [];
  List favItem = [];
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    initSubjects();
  }

  void initSubjects() async {
    log('***subject init***');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favItem = prefs.getStringList('favItem') ?? [];
    http.Response res = await http.post(Uri.parse(mainFileApi), body: {
      'token': token,
      'domain': widget.domainId,
    });
    List<MainFolder> dataL = mainFolderFromJson(res.body);

    List<MainFolder> selectedM = [];
    for (var subject in dataL) {
      if (favItem.contains(subject.id.toString())) {
        log('contain');
      } else {
        log('not contain');
        selectedM.add(subject);
      }
    }
    // selected = getlist;
    setState(() {
      allItem = selectedM;
    });
    _streamController.add('event');
    // subjects = selectedM;
    // subjects = userData.chosenSubjects;
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
    return StreamBuilder<dynamic>(
      // future: backEnd().fetchMainFiles(domainId),
      stream: _streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: allItem.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        if (widget.title != 'Syllabus') {
                          log('not syllabus');
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return innerfileScreen(
                                inner_file: snapshot.data[index]['id'],
                                title: widget.title,
                              );
                            },
                          ));
                        } else {
                          log('syllabus');
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return SubjectsStaggeredListViewS(
                                // launchSyllabusView(snapshot.data[index]['name']),
                                allItem[index]['name'],
                                allItem[index]['id'],
                              );
                            },
                          ));
                        }
                      },
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset('assets/icons/folder.png'),
                      ),
                      trailing: IconButton(
                        onPressed: (() {}),
                        icon: Icon(Icons.favorite_border),
                      ),
                      title: Text(
                        allItem[index]['name'],
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

// ignore: must_be_immutable
// class normalListView extends StatelessWidget {
//   normalListView({
//     Key? key,
//     required this.title,
//     required this.snapshot,
//   }) : super(key: key);

//   var title;
//   AsyncSnapshot snapshot;
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }
