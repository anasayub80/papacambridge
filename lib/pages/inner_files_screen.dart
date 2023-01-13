import 'dart:async';
import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studento/pages/home_page.dart';
import 'package:studento/pages/past_paper_view.dart';
import 'package:studento/services/backend.dart';
import 'package:studento/utils/ads_helper.dart';
import 'package:studento/utils/bannerAdmob.dart';
import '../UI/studento_app_bar.dart';
import '../model/MainFolder.dart';
import '../utils/get_ad_widget.dart';
import 'other_fileView.dart';

class innerfileScreen extends StatefulWidget {
  final inner_file;
  final title;
  const innerfileScreen(
      {super.key, required this.inner_file, required this.title});

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
    // controller.load(keywords: ['valorant', 'games', 'fortnite']);
    // controller.onEvent.listen((event) {
    //   if (event.keys.first == NativeAdEvent.loaded) {}
    //   setState(() {});
    // });
  }

  @override
  void dispose() {
    favItem = [];
    favItemName = [];
    allItem = [];
    // if (_ad != null) {
    //   _ad!.dispose();
    // }
    // ignore: todo
    // TODO: implement dispose
    super.dispose();
  }

  List<MainFolder>? dataL;
  void initData() async {
    log('***subject init innerfile***');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log('Inner File favItem${widget.inner_file} & favItemName${widget.inner_file}');
    favItem = prefs.getStringList('favItem${widget.inner_file}') ?? [];
    favItemName = prefs.getStringList('favItemName${widget.inner_file}') ?? [];

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

  List foodItems = [];
  List<String> favItem = [];
  List<MainFolder> allItem = [];
  List<String> favItemName = [];
  var url;
  StreamController _streamController = StreamController();

  @override
  Widget build(BuildContext context) {
    /// Open the Paper in the PastPaperView.
    void openPaper(String url, fileName) async {
      // List<String> moreUrls = [];

      print("url file $url");
      // moreUrls.add(url);
      print('kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk');
      // print(moreUrls);
      print('lllllllllllllllllllllllllllllllllllllll');
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
      // showDialog(
      //   context: context,
      //   builder: (context) => CustomAlertDialog(),
      // );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      favItem.add(id);
      favItemName.add(name);
      prefs.setStringList('favItem${widget.inner_file}', favItem);
      prefs.setStringList('favItemName${widget.inner_file}', favItemName);
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
        prefs.setStringList('favItem${widget.inner_file}', favItem);
        prefs.setStringList('favItemName${widget.inner_file}', favItemName);
        // favItem.remove(id);
        // favItemName.remove(name);
      });

      prefs.setStringList('favItem$boardId', favItem);
      prefs.setStringList('favItemName$boardId', favItemName);
      BotToast.closeAllLoading();
    }

    return Scaffold(
      appBar: StudentoAppBar(
        title: widget.title,
        context: context,
      ),
      body: StreamBuilder<dynamic>(
        // future: backEnd().fetchInnerFiles(widget.inner_file),
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (allItem.isEmpty && favItem.isEmpty) {
            return Center(
              child: Text(
                'No Data Found',
                style: Theme.of(context).textTheme.headline4,
              ),
            );
          } else if (snapshot.hasData) {
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
                              // } else {
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
                            // subtitle: Text(allItem[i].id),
                            title: Text(
                              favItemName[i],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w600),
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
                    // Container(
                    //     width: _ad!.size.width.toDouble(),
                    //     height: 72.0,
                    //     alignment: Alignment.center,
                    //     child: AdWidget(ad: _ad!),
                    //   )

                    return const SizedBox();
                  },
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        if (allItem[index].urlPdf == "" ||
                            allItem[index].urlPdf == null) {
                          debugPrint('newScreen');
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return innerfileScreen(
                                inner_file: allItem[index].id,
                                title: widget.title,
                              );
                            },
                          ));
                        } else {
                          allItem[index].urlPdf.toString().contains('.pdf')
                              ? openPaper(allItem[index].urlPdf!,
                                  allItem[index].name!.replaceFirst(" ", " \n"))
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OtherFilesViewPage(
                                      [
                                        allItem[index].urlPdf ?? '',
                                      ],
                                      allItem[index]
                                          .name!
                                          .replaceFirst(" ", " \n"),
                                      allItem[index]
                                          .id
                                          .toString()
                                          .replaceFirst(" ", " \n"),
                                    ),
                                  ),
                                );
                        }
                      },
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(allItem[index]
                                .urlPdf
                                .toString()
                                .contains('.pdf')
                            ? 'assets/icons/pdf.png'
                            : allItem[index].urlPdf.toString().contains('.doc')
                                ? 'assets/icons/doc.png'
                                : 'assets/icons/folder.png'),
                      ),
                      trailing: allItem[index]
                              .urlPdf
                              .toString()
                              .contains('.pdf')
                          ? SizedBox.shrink()
                          : allItem[index].urlPdf.toString().contains('.doc')
                              ? SizedBox.shrink()
                              : allItem[index]
                                      .urlPdf
                                      .toString()
                                      .contains('.zip')
                                  ? SizedBox.shrink()
                                  : IconButton(
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
                                    ),
                      // subtitle: Text(allItem[index]['id']),
                      title: Text(
                        allItem[index].name.toString().replaceFirst(" ", " \n"),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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
    );
  }
}
