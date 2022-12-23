import 'dart:async';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studento/UI/subjects_staggered_viewS.dart';
import 'package:studento/pages/home_page.dart';
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
  List<MainFolder> allItem = [];
  List<String> favItem = [];
  List<String> favItemName = [];
  List<MainFolder> selectedM = [];
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    initSubjects();
  }

  @override
  void dispose() {
    _streamController.close();
    allItem = [];
    favItem = [];
    favItemName = [];
    selectedM = [];
    // ignore: todo
    // TODO: implement dispose
    super.dispose();
  }

  void initSubjects() async {
    log('***subject init***');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favItem = prefs.getStringList('favItem$boardId') ?? [];
    favItemName = prefs.getStringList('favItemName$boardId') ?? [];
    http.Response res = await http.post(Uri.parse(mainFileApi), body: {
      'token': token,
      'domain': widget.domainId,
    });
    List<MainFolder> dataL = mainFolderFromJson(res.body);
    selectedM.addAll(dataL);
    for (var subject in dataL) {
      if (favItem.contains(subject.id.toString())) {
        log('contain');
        // selectedM.removeWhere((item) => item.id == subject.id);
        selectedM.remove(subject);
      } else {
        log('not contain');
      }
    }
    setState(() {
      allItem.addAll(selectedM);
    });
    _streamController.add('event');
  }

  void modifySubjects() async {}

  addtoFav(id, name) async {
    log('to save $id & $name');
    BotToast.showLoading();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favItem.add(id);
    favItemName.add(name);
    prefs.setStringList('favItem$boardId', favItem);
    prefs.setStringList('favItemName$boardId', favItem);
    for (var subject in allItem) {
      if (favItem.contains(id)) {
        log('contain');
        // selectedM.remove(subject);
        selectedM.removeWhere((item) => item.id == subject.id);
      } else {
        log('not contain');
      }
    }
    setState(() {
      allItem = selectedM;
    });
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
          return SingleChildScrollView(
            child: Column(
              children: [
                Expanded(
                  child: favItem.isEmpty
                      ? SizedBox.shrink()
                      : ListView.builder(
                          itemCount: favItem.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                if (widget.title != 'Syllabus') {
                                  log('not syllabus');
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return innerfileScreen(
                                        inner_file: favItem[index],
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
                                        allItem[index].name!,
                                        allItem[index].id,
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
                                onPressed: (() {
                                  addtoFav(
                                    allItem[index].id,
                                    allItem[index].name!,
                                  );
                                }),
                                icon: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ),
                              title: Text(
                                allItem[index].name ?? 'NONE',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            );
                          },
                        ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: allItem.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          if (widget.title != 'Syllabus') {
                            log('not syllabus');
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return innerfileScreen(
                                  inner_file: allItem[index].id,
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
                                  allItem[index].name!,
                                  allItem[index].id,
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
                          onPressed: (() {
                            addtoFav(
                              allItem[index].id,
                              allItem[index].name,
                            );
                          }),
                          icon: Icon(Icons.favorite_border),
                        ),
                        title: Text(
                          allItem[index].name ?? 'NONE',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
