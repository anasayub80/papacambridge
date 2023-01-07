import 'dart:async';
import 'dart:convert';
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
  // List<MainFolder> selectedM = [];
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
    // ignore: todo
    // TODO: implement dispose
    super.dispose();
  }

  void initSubjects() async {
    log('***subject init***');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // List<String> basicData = prefs.getStringList('favItem$boardId')!;
    // Map<String, dynamic> jsonDatais = jsonDecode(basicData);
    // List<MainFolder> basicInfoModel = mainFolderFromJson(jsonDatais);
    favItem = prefs.getStringList('favItem$boardId') ?? [];
    favItemName = prefs.getStringList('favItemName$boardId') ?? [];

    // favItemName = prefs.getStringList('favItemName$boardId') ?? [];
    http.Response res = await http.post(Uri.parse(mainFileApi), body: {
      'token': token,
      'domain': widget.domainId,
    });
    print(favItem.toString());
    List<MainFolder> dataL = mainFolderFromJson(res.body);
    List<MainFolder> selectedM = dataL;
    for (var subject in dataL) {
      if (favItem.contains(subject.id.toString())) {
        log('contain');
        // favItem.add(subject.id);
        // allItem.remove(subject.id);
        allItem.removeWhere((item) => item.id == subject.id);
        // selectedM.remove(subject);
      } else {
        // favItem.remove(subject.id);
        log('not contain');
      }
    }
    setState(() {
      // allItem.addAll(selectedM);
      allItem = selectedM;
    });
    _streamController.add('event');
  }

  addtoFav(index, id, name) async {
    log('to save $id & $name');
    BotToast.showLoading();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favItem.add(id);
    favItemName.add(name);
    prefs.setStringList('favItem$boardId', favItem);
    prefs.setStringList('favItemName$boardId', favItemName);
    // prefs.setStringList('favItemName$boardId', favItem);
    // for (var subject in allItem) {
    //   if (favItem.contains(id)) {
    //     log('contain');
    //     // selectedM.remove(subject);

    //   } else {
    //     log('not contain');
    //   }
    // }
    setState(() {
      allItem.removeWhere((item) => item.id == allItem[index].id);
    });
    BotToast.closeAllLoading();
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
              favItem.isEmpty
                  ? SizedBox.shrink()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: favItem.length,
                        shrinkWrap: true,
                        // physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          return ListTile(
                            onTap: () {
                              if (widget.title != 'Syllabus') {
                                log('not syllabus');
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return innerfileScreen(
                                      inner_file: favItem[i],
                                      title: widget.title,
                                    );
                                  },
                                ));
                              } else {
                                log('syllabus');
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return SubjectsStaggeredListViewS(
                                      // launchSyllabusView(snapshot.data[i]['name']),
                                      favItemName[i].replaceFirst(" ", " \n"),
                                      favItem[i].replaceFirst(" ", " \n"),
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
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                            ),
                            subtitle: Text(allItem[i].id),
                            title: Text(
                              favItemName[i],
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
                  // physics: NeverScrollableScrollPhysics(),
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
                                allItem[index].name!.replaceFirst(" ", " \n"),
                                allItem[index].id.replaceFirst(" ", " \n"),
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
                            index,
                            allItem[index].id,
                            allItem[index].name,
                          );
                        }),
                        icon: Icon(
                          Icons.favorite_border,
                          color: Colors.black,
                        ),
                      ),
                      title: Text(
                        allItem[index].name ?? 'NONE',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(allItem[index].id),
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
