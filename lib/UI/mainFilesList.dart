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
import 'package:studento/utils/like_icon.dart';

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
    log('***subject init mainFile***');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // List<String> basicData = prefs.getStringList('favItem$boardId')!;
    // Map<String, dynamic> jsonDatais = jsonDecode(basicData);
    // List<MainFolder> basicInfoModel = mainFolderFromJson(jsonDatais);
    log('Inner File favItem${widget.domainId} & favItemName${widget.domainId}');

    favItem = prefs.getStringList('favItem${widget.domainId}') ?? [];
    favItemName = prefs.getStringList('favItemName${widget.domainId}') ?? [];

    // favItemName = prefs.getStringList('favItemName$boardId') ?? [];
    http.Response res = await http.post(Uri.parse(mainFileApi), body: {
      'token': token,
      'domain': widget.domainId,
    });
    log(res.body);
    if (res.statusCode == 200) {
      if (res.body.isNotEmpty) {
        if (res.body.length <= 64) {
          print('Something Wrong');
        } else {
          print(favItem.toString());
          List<MainFolder> dataL = mainFolderFromJson(res.body);
          List<MainFolder> selectedM = [];
          debugPrint('mainFile list ${res.body}');

          for (var subject in dataL) {
            if (favItem.contains(subject.id.toString())) {
              // if that specific item already in fav item
              // selectedM.removeWhere((item) => item.id == subject.id);
            } else {
              selectedM.add(subject);
            }
          }
          setState(() {
            allItem = selectedM;
          });
        }
      } else {
        print('Something Wrong');
      }
    }

    _streamController.add('event');
  }

  addtoFav(index, String id, String name) async {
    log('to save $id & $name');
    BotToast.showLoading();
    // showDialog(
    //   context: context,
    //   builder: (context) => CustomAlertDialog(),
    // );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favItem.add(id);
    favItemName.add(name);
    prefs.setStringList('favItem${widget.domainId}', favItem);
    prefs.setStringList('favItemName${widget.domainId}', favItemName);
    setState(() {
      allItem.removeWhere((item) => item.id == allItem[index].id);
    });
    BotToast.closeAllLoading();
  }

  removeFromFav(index, id, name) async {
    log('to remove $id & $name');
    BotToast.showLoading();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    MainFolder folderModel = MainFolder(
      name: favItemName[index],
      id: favItem[index],
    );
    setState(() {
      allItem.add(folderModel);
      favItem.removeWhere((item) => item == favItem[index]);
      favItemName.removeWhere((item2) => item2 == favItemName[index]);
      prefs.setStringList('favItem${widget.domainId}', favItem);
      prefs.setStringList('favItemName${widget.domainId}', favItemName);
      // favItem.remove(id);
      // favItemName.remove(name);
    });

    prefs.setStringList('favItem$boardId', favItem);
    prefs.setStringList('favItemName$boardId', favItemName);
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
          return ListView(
            children: [
              favItem.isEmpty
                  ? SizedBox.shrink()
                  : ListView.builder(
                      itemCount: favItem.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) {
                        return ListTile(
                          onTap: () {
                            // if (widget.title != 'Syllabus') {
                            log('not syllabus');
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return innerfileScreen(
                                  inner_file: favItem[i],
                                  title: widget.title,
                                );
                              },
                            ));
                            // }
                            // else {
                            //   log('syllabus');
                            //   Navigator.push(context, MaterialPageRoute(
                            //     builder: (context) {
                            //       return SubjectsStaggeredListViewS(
                            //         // launchSyllabusView(snapshot.data[i]['name']),
                            //         favItemName[i],
                            //         favItem[i],
                            //       );
                            //     },
                            //   ));
                            // }
                          },
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/icons/folder.png'),
                          ),
                          trailing: IconButton(
                            onPressed: (() {
                              removeFromFav(
                                i,
                                favItem[i],
                                favItemName[i],
                              );
                            }),
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                          ),
                          title: Text(
                            favItemName[i],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
              ListView.builder(
                itemCount: allItem.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      // if (widget.title != 'Syllabus') {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return innerfileScreen(
                            inner_file: allItem[index].id,
                            title: widget.title,
                          );
                        },
                      ));
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
                          allItem[index].name!,
                        );
                      }),
                      icon: Icon(
                        Icons.favorite_border,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                    ),
                    title: Text(
                      allItem[index].name ?? 'NONE',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    // subtitle: Text(allItem[index].id),
                  );
                },
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
