import 'dart:async';
import 'dart:developer';
import 'package:flutter_spotlight_plus/flutter_spotlight_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studento/pages/home_page.dart';
import 'package:studento/pages/past_paper_view.dart';
import 'package:studento/provider/multiViewhelper.dart';
import 'package:studento/services/backend.dart';
import 'package:studento/utils/bannerAdmob.dart';
import '../UI/studento_app_bar.dart';
import '../model/MainFolder.dart';
import '../services/bread_crumb_navigation.dart';
import 'other_fileView.dart';

class innerfileScreen extends StatefulWidget {
  final inner_file;
  final title;

  const innerfileScreen({
    super.key,
    required this.inner_file,
    required this.title,
  });
  static MaterialPageRoute getRoute(String name, innerfile, title) =>
      MaterialPageRoute(
          settings: RouteSettings(name: name),
          builder: (context) => innerfileScreen(
                inner_file: innerfile,
                title: title,
              ));
  @override
  State<innerfileScreen> createState() => _innerfileScreenState();
}

class _innerfileScreenState extends State<innerfileScreen> {
  var mytotalAmount = '';

  var listUpdate = false;

  void updateList(List list) {
    setState(() {
      listUpdate = true;
      foodItems = list;
    });
  }

  @override
  void initState() {
    super.initState();
    initData();
    // Future.delayed(Duration(seconds: 3)).then((value) {
    //   spotlight(0);
    // });
  }

  String prettifySubjectName(String subjectName) {
    return subjectName.replaceFirst("\r\n", "");
  }

  @override
  void dispose() {
    favItem = [];
    favItemName = [];
    allItem = [];
    super.dispose();
  }

  List<MainFolder>? dataL;
  void initData() async {
    _streamController.add('loading');
    allItem.clear();
    favItem.clear();
    favItemName.clear();
    log('***subject init innerfile***');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log('Inner File favItem${widget.inner_file}${widget.title.trim()} & favItemName${widget.inner_file}');
    favItem = prefs.getStringList(
            'favItem${widget.inner_file}${widget.title.trim()}') ??
        [];
    blockList = prefs.getStringList('blockList') ?? [];
    favItemName = prefs.getStringList(
            'favItemName${widget.inner_file}${widget.title.trim()}') ??
        [];

    // var res = await backEnd().fetchInnerFiles(widget.inner_file);
    http.Response res = await http.post(Uri.parse(innerFileApi), body: {
      'token': token,
      'fileid': widget.inner_file,
    });

    print(innerFileApi + widget.inner_file);
    log(res.body);
    if (res.statusCode == 200) {
      if (res.body.isNotEmpty) {
        if (res.body.length <= 64) {
          print('Something Wrong');
        } else {
          dataL = mainFolderFromJson(res.body);
          List<MainFolder> selectedM = [];
          debugPrint('mainFile list ${res.body}');

          for (var subject in dataL!) {
            if (favItem.contains(subject.id.toString())) {
              print('Should not to show');
            } else if (blockList.contains(subject.id.toString())) {
              print('Should not to show bcz it is blocked ');
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
    print(favItem.toString());

    _streamController.add('event');
  }

  List<String> blockList = [];
  List foodItems = [];
  List<String> favItem = [];
  List<MainFolder> allItem = [];
  List<String> favItemName = [];
  var url;
  StreamController _streamController = StreamController();
  addtoBlockList(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    blockList = prefs.getStringList('blockList') ?? [];
    blockList.add(id);
    prefs.setStringList('blockList', blockList);
  }

  List multiItem = [];
  List selectedList = [];
  @override
  Widget build(BuildContext context) {
    final multiProvider = Provider.of<multiViewProvider>(context, listen: true);

    /// Open the Paper in the PastPaperView.
    void openPaper(String url, fileName) async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PastPaperView([
            url,
          ], fileName, boardId, false),
        ),
      );
    }

    addtoFav(index, String id, String name) async {
      log('to save $id & $name');
      BotToast.showLoading();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      favItem.add(id);
      favItemName.add(name);
      prefs.setStringList(
          'favItem${widget.inner_file}${widget.title.trim()}', favItem);
      prefs.setStringList(
          'favItemName${widget.inner_file}${widget.title.trim()}', favItemName);
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
        prefs.setStringList(
            'favItem${widget.inner_file}${widget.title.trim()}', favItem);
        prefs.setStringList(
            'favItemName${widget.inner_file}${widget.title.trim()}',
            favItemName);
      });
      BotToast.closeAllLoading();
      initData();
    }

    return Scaffold(
      appBar: StudentoAppBar(
        title: widget.title,
        context: context,
      ),
      body: StreamBuilder<dynamic>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == 'loading') {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (allItem.isEmpty && favItem.isEmpty) {
            addtoBlockList(widget.inner_file);
            return Center(
              child: Text(
                'No Data Found',
                style: Theme.of(context).textTheme.headline4,
              ),
            );
          } else if (snapshot.hasData) {
            if (multiItem.isEmpty)
              selectedList = List.generate(allItem.length, (index) => false);

            return ListView(
              children: [
                SizedBox(
                  height: 10,
                ),
                // ignore: iterable_contains_unrelated_type
                SizedBox(
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          multiProvider.setMultiViewFalse();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: multiProvider.multiView == true
                              ? Colors.transparent
                              : Colors.purple,
                          side: BorderSide(
                              color: multiProvider.multiView == false
                                  ? Colors.transparent
                                  : Theme.of(context).unselectedWidgetColor),
                        ),
                        child: Text(
                          'Single View',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          multiProvider.setMultiViewTrue();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: multiProvider.multiView == false
                              ? Colors.transparent
                              : Colors.purple,
                          side: BorderSide(
                              color: multiProvider.multiView == true
                                  ? Colors.transparent
                                  : Theme.of(context).unselectedWidgetColor),
                        ),
                        child: Text(
                          'Multi View',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  ),
                  height: 48,
                ),
                SizedBox(
                  height: 10,
                ),
                BreadCrumbNavigator(),
                SizedBox(
                  height: 10,
                ),
                favItem.isEmpty
                    ? SizedBox.shrink()
                    : ListView.builder(
                        itemCount: favItem.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          return ListTile(
                            onTap: () {
                              log('not syllabus');
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return innerfileScreen(
                                    inner_file: favItem[i],
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
                            // subtitle: Text(allItem[i].id),
                            title: Text(
                              prettifySubjectName(favItemName[i]),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                ListView.separated(
                  itemCount: allItem.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    if (index % 10 == 5 && index != 0)
                      return BannerAdmob(
                        size: AdSize.largeBanner,
                      );

                    return const SizedBox();
                  },
                  itemBuilder: (context, index) {
                    return ListTile(
                      // onTap: () =>,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      selectedTileColor: Colors.green,
                      selected: selectedList[index],
                      selectedColor: Colors.white,
                      onTap: () {
                        if (allItem[index].urlPdf == "" ||
                            allItem[index].urlPdf == null) {
                          debugPrint('newScreen');
                          Navigator.push(
                              context,
                              innerfileScreen.getRoute(allItem[index].name!,
                                  allItem[index].id, widget.title));
                        } else {
                          if (backEnd().pdfFilter(allItem[index].urlPdf)) {
                            if (multiProvider.multiView == true) {
                              if (selectedList[index] == true) {
                                multiItem.remove(allItem[index].id);
                                selectedList[index] = false;
                                setState(() {});
                              } else {
                                multiItem.add(allItem[index].id);
                                selectedList[index] = true;
                                setState(() {});
                              }
                            } else {
                              openPaper(
                                  allItem[index].urlPdf!,
                                  allItem[index]
                                      .name!
                                      .replaceFirst(" ", " \n"));
                            }
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OtherFilesViewPage(
                                  [
                                    allItem[index].urlPdf ?? '',
                                  ],
                                  prettifySubjectName(allItem[index].name!),
                                  allItem[index]
                                      .id
                                      .toString()
                                      .replaceFirst(" ", " \n"),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(backEnd()
                            .fileLogoAssets(allItem[index].urlPdf.toString())),
                      ),
                      onLongPress: () {
                        print(
                            "${selectedList[index].toString()} & ${multiItem.length}");
                      },
                      trailing: backEnd().heartFilter(
                                  allItem[index].urlPdf.toString()) ==
                              true
                          ? IconButton(
                              onPressed: (() {
                                addtoFav(
                                  index,
                                  allItem[index].id,
                                  allItem[index].name!,
                                );
                              }),
                              icon: Icon(
                                Icons.favorite_border,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color,
                              ),
                            )
                          : SizedBox.shrink(),
                      title: Text(
                        prettifySubjectName(allItem[index].name!),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );

            // }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      bottomNavigationBar: allItem.length <= 5
          ? Container(
              width: 320,
              height: 50,
              child: BannerAdmob(
                size: AdSize.banner,
              ),
            )
          : SizedBox(
              height: 0,
            ),
    );
  }
}
