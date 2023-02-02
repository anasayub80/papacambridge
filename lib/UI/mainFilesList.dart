import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:showcaseview/showcaseview.dart';
import 'package:studento/pages/inner_files_screen.dart';
import 'package:studento/responsive/responsive_layout.dart';
import 'package:studento/services/backend.dart';
import 'package:studento/utils/sideAdsWidget.dart';

import '../model/MainFolder.dart';
import 'package:http/http.dart' as http;

import '../pages/home_page.dart';
import '../provider/loadigProvider.dart';
import '../utils/ads_helper.dart';
import '../utils/funHelper.dart';
import '../utils/pdf_helper.dart';
import '../utils/theme_provider.dart';
import 'package:provider/provider.dart';

import 'web_appbar.dart';

// ignore: must_be_immutable
class mainFilesList extends StatefulWidget {
  bool? isPastPapers = false;
  mainFilesList(
      {super.key,
      required this.domainId,
      required this.domainName,
      required this.title,
      this.isPastPapers});
  final domainId;
  final domainName;
  final title;

  @override
  State<mainFilesList> createState() => _mainFilesListState();
}

class _mainFilesListState extends State<mainFilesList> {
  List<MainFolder> allItem = [];
  List<String> favItem = [];
  List<String> favItemName = [];
  Random random = Random();
  String? prettyTitle;
  // List<MainFolder> selectedM = [];
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    prettyTitle = widget.title.toString().replaceAll(' ', '-');
    if (kIsWeb) {
      initSubjects();
    } else {
      getStoredData();
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
    super.dispose();
  }

  getStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var isConnected = await PdfHelper.checkIfConnected();
    if (isConnected) {
      var res = await funHelper().checkifDataExist(
          'mainFileData${widget.domainId}${widget.title.trim()}');
      if (res != null) {
        http.Response myres = await http.post(Uri.parse(mainFileApi), body: {
          'token': token,
          'domain': widget.domainId,
        });
        if (myres.body.length <= res.length) {
          print('equal');
          clearifyData(res, true);
        } else {
          print('not equal update');
          prefs.remove('mainFileData${widget.domainId}${widget.title.trim()}');
        }
      } else {
        initSubjects();
      }
    } else {
      var res = await funHelper().checkifDataExist(
          'mainFileData${widget.domainId}${widget.title.trim()}');
      if (res != null) {
        clearifyData(res, true);
      } else {
        _streamController.add('NetworkError');
      }
    }
  }

  clearifyData(dynamic res, bool isLocal) async {
    allItem.clear();
    favItem.clear();
    favItemName.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favItem = prefs
            .getStringList('favItem${widget.domainId}${widget.title.trim()}') ??
        [];
    favItemName = prefs.getStringList(
            'favItemName${widget.domainId}${widget.title.trim()}') ??
        [];
    if (!isLocal) {
      // get Data From Api
      if (res.statusCode == 200) {
        if (res.body.isNotEmpty) {
          if (res.body.length <= 64) {
            print('Something Wrong');
          } else {
            var response = jsonEncode(res.body);
            await prefs.setString(
                'mainFileData${widget.domainId}${widget.title.trim()}',
                response);

            List<MainFolder> dataL = mainFolderFromJson(res.body.toString());
            List<MainFolder> selectedM = [];
            for (var subject in dataL) {
              if (favItem.contains(subject.id.toString())) {
                // if that specific item already in fav item
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
    } else {
      // get local data
      List<MainFolder> dataL = mainFolderFromJson(res.toString());
      List<MainFolder> selectedM = [];
      for (var subject in dataL) {
        if (favItem.contains(subject.id.toString())) {
        } else {
          selectedM.add(subject);
        }
      }
      setState(() {
        allItem = selectedM;
      });
    }

    _streamController.add('event');
  }

  void initSubjects() async {
    http.Response res;
    _streamController.add('loading');
    allItem.clear();
    favItem.clear();
    favItemName.clear();
    if (!kIsWeb)
      res = await http.post(Uri.parse(mainFileApi), body: {
        'token': token,
        'domain': widget.domainId,
      });
    else {
      print('get data for web');
      res = await http.post(Uri.parse("$webAPI?page=main_file"), body: {
        'domain': widget.domainId,
        'token': token,
      });
    }
    // debugPrint(res.body);
    clearifyData(res, false);
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
    var name = subjectName.replaceFirst("\r", "");
    return name.replaceFirst("\n", "");
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
    getStoredData();
  }

  StreamController _streamController = BehaviorSubject();

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: mobileLayout(),
      webBody: webBody(context),
    );
  }

  Row webBody(BuildContext context) {
    final themeProvider = Provider.of<ThemeSettings>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.70,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.title}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  color: Theme.of(context).cardColor,
                ),
              ),

              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: mobileLayout(),
                  ),
                  color: Theme.of(context).cardColor,
                ),
              )),
              SizedBox(
                height: 20,
              ),
              // Working Mode
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset(
                          themeProvider.currentTheme == ThemeMode.light
                              ? 'assets/icons/logo.png'
                              : 'assets/icons/Darklogo.png',
                          height: 50,
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () {}, child: Text('Advertise')),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(onPressed: () {}, child: Text('Contact')),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                  color: Theme.of(context).cardColor,
                ),
              ),
            ],
          ),
        ),
        // second column
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.20,
          child: sideAdsWidget(),
        )
      ],
    );
  }

  StreamBuilder<dynamic> mobileLayout() {
    return StreamBuilder<dynamic>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == 'loading') {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.data == 'NetworkError') {
          return Center(child: Text('No Internet Connection'));
        } else if (allItem.isEmpty && favItem.isEmpty) {
          return Center(
            child: Text(
              'No Data Found',
              style: Theme.of(context).textTheme.headlineMedium,
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
                            debugPrint('not syllabus');
                            Navigator.push(
                                context,
                                innerfileScreen.getRoute(favItemName[i],
                                    favItem[i], widget.title, false));
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
                      if (kIsWeb) {
                        GoRouter.of(context).pushNamed('innerfile', params: {
                          'domainName': widget.domainName,
                          'boardName': returnBoardName(
                              Provider.of<loadingProvider>(context,
                                      listen: false)
                                  .getboardId),
                          'url': allItem[index].mainUrl.toString(),
                        });
                      } else {
                        Navigator.push(
                            context,
                            innerfileScreen.getRoute(allItem[index].name!,
                                allItem[index].id, widget.title, true));
                      }
                    },
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/icons/folder.png',
                      ),
                    ),
                    trailing: kIsWeb
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
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
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
