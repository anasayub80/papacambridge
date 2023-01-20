import 'dart:async';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studento/pages/inner_files_screen.dart';
import 'package:studento/services/backend.dart';

import '../model/MainFolder.dart';
import 'package:http/http.dart' as http;

import '../utils/ads_helper.dart';

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
  Random random = Random();

  // List<MainFolder> selectedM = [];
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    initSubjects();
    int randomNumber = random.nextInt(5);
    switch (randomNumber) {
      case 2:
        _interstitialAd?.dispose();
        createInterstitialAd();
        break;
      case 4:
        _interstitialAd?.dispose();
        createInterstitialAd();
        break;
      default:
    }
  }

  InterstitialAd? _interstitialAd;

  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            // _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            _interstitialAd!.show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            // _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (numInterstitialLoadAttempts < 3) {
              createInterstitialAd();
            }
          },
        ));
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
    _streamController.add('loading');
    allItem.clear();
    favItem.clear();
    favItemName.clear();
    debugPrint('***subject init mainFile***');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    debugPrint(
        'Inner File favItem${widget.domainId}${widget.title.trim()} & favItemName${widget.domainId}');

    favItem = prefs
            .getStringList('favItem${widget.domainId}${widget.title.trim()}') ??
        [];
    favItemName = prefs.getStringList(
            'favItemName${widget.domainId}${widget.title.trim()}') ??
        [];

    // favItemName = prefs.getStringList('favItemName$boardId') ?? [];
    http.Response res = await http.post(Uri.parse(mainFileApi), body: {
      'token': token,
      'domain': widget.domainId,
    });
    debugPrint(res.body);
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
    debugPrint('to save $id & $name');
    BotToast.showLoading();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favItem.add(id);
    favItemName.add(name);
    prefs.setStringList(
        'favItem${widget.domainId}${widget.title.trim()}', favItem);
    prefs.setStringList(
        'favItemName${widget.domainId}${widget.title.trim()}', favItemName);
    setState(() {
      allItem.removeWhere((item) => item.id == allItem[index].id);
    });
    BotToast.closeAllLoading();
  }

  String prettifySubjectName(String subjectName) {
    return subjectName.replaceFirst("\r\n", "");
  }

  removeFromFav(index, id, name) async {
    debugPrint('to remove $id & $name');
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
          'favItem${widget.domainId}${widget.title.trim()}', favItem);
      prefs.setStringList(
          'favItemName${widget.domainId}${widget.title.trim()}', favItemName);
    });
    BotToast.closeAllLoading();
    initSubjects();
    // prefs.setStringList('favItem$boardId', favItem);
    // prefs.setStringList('favItemName$boardId', favItemName);
  }

  StreamController _streamController = StreamController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      // future: backEnd().fetchMainFiles(domainId),
      stream: _streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == 'loading') {
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
                            debugPrint('not syllabus');
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (context) {
                            //     return innerfileScreen(
                            //       inner_file: favItem[i],
                            //       title: widget.title,
                            //     );
                            //   },
                            // ));
                            Navigator.push(
                                context,
                                innerfileScreen.getRoute(
                                    favItemName[i], favItem[i], widget.title));
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
                            prettifySubjectName(favItemName[i]),
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
                      Navigator.push(
                          context,
                          innerfileScreen.getRoute(allItem[index].name!,
                              allItem[index].id, widget.title));

                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (context) {
                      //     return innerfileScreen(
                      //       inner_file: allItem[index].id,
                      //       title: widget.title,
                      //     );
                      //   },
                      // ));
                    },
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/icons/folder.png',
                      ),
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
                    title: Container(
                      // color: Colors.brown,
                      width: double.infinity,
                      padding: EdgeInsets.all(0),
                      child: Text(
                        // allItem[index].name!,
                        prettifySubjectName(allItem[index].name!),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
