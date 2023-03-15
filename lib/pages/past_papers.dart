import 'dart:async';
import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:studento/model/MainFolder.dart';
import 'package:flutter/material.dart';
import 'package:studento/pages/searchPage.dart';
import '../UI/loading_page.dart';
import '../UI/mainFilesList.dart';
import '../CAIE/past_papers_details_select.dart';
import 'package:studento/UI/studento_app_bar.dart';
import 'package:studento/CAIE/subjects_staggered_view.dart';
import '../utils/ads_helper.dart';

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
  void initState() {
    super.initState();
    // if (kIsWeb) {
    //   Future.delayed(
    //     Duration.zero,
    //     () {
    //       Provider.of<loadingProvider>(context, listen: false)
    //           .changeDomainid(widget.domainId);
    //     },
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    print('past paper domain id ${widget.domainId}');
    return Scaffold(
      appBar: StudentoAppBar(
        title: "Past Papers",
        context: context,
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.push(context, MaterialPageRoute(
        //           builder: (context) {
        //             return SearchPage(
        //               domainId: widget.domainId,
        //               domainName: "Past Papers",
        //             );
        //           },
        //         ));
        //       },
        //       icon: Icon(Icons.search)),
        // ],
      ),
      body: ShowCaseWidget(
        builder: Builder(builder: (context) {
          return mainFilesList(
            domainId: widget.domainId,
            title: 'Papers',
            isPastPapers: true,
            domainName: 'papers',
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return SearchPage(
                domainId: widget.domainId,
                domainName: "Past Papers",
              );
            },
          ));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}

class PastPapersPageCAIE extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _PastPapersPageCAIEState createState() => _PastPapersPageCAIEState();
}

class _PastPapersPageCAIEState extends State<PastPapersPageCAIE> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    ).load();
    // getData();
    getMyData();
  }

  List? level;
  List levelid = [];
  initLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    level = prefs.getStringList('level');
    levelid = prefs.getStringList('levelid') ?? [];
    print('My level ${level.toString()} & id ${levelid.toString()}');
    print(level.toString());
    print(levelid.toString());
    return level;
  }

  var res;
  getMyData() async {
    await initLevel();
    if (levelid.length >= 2) {
      return getData();
    } else if (levelid.isEmpty) {
      _streamController.add('No Subject Selected');
    } else {
      log('done');
      setState(() {
        res = levelid[0];
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
              content: SizedBox(
                width: 200,
                height: 500,
                child: ListView.builder(
                  // shrinkWrap: true,
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
              ),
            );
          },
        ).then((indexFromDialog) {
          // use the value as you wish
          print(
              "Level Name ${level![indexFromDialog]}, Level Id ${levelid[indexFromDialog]}");
          setState(() {
            res = levelid[indexFromDialog];
          });
          _streamController.add(res);
        });
      },
    );
  }

  @override
  void dispose() {
    _streamController.close();
    if (_ad != null) {
      _ad!.dispose();
    }

    super.dispose();
  }

  StreamController _streamController = BehaviorSubject();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StudentoAppBar(
        title: "Past Papers",
        isFile: true,
        centerTitle: false,
        context: context,
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.push(context, MaterialPageRoute(
        //           builder: (context) {
        //             return SearchPage(
        //               domainId: '1',
        //               domainName: "Past Papers",
        //             );
        //           },
        //         ));
        //       },
        //       icon: Icon(Icons.search)),
        // ],
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
              } else if (snapshot.data == 'No Subject Selected') {
                return Center(
                  child: Text('No Subject Selected'),
                );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return SearchPage(
                domainId: '1',
                domainName: "Past Papers",
              );
            },
          ));
        },
        child: Icon(Icons.search),
      ),
      bottomNavigationBar: _ad != null
          ? Container(
              width: _ad!.size.width.toDouble(),
              height: 72.0,
              alignment: Alignment.center,
              child: AdWidget(ad: _ad!),
            )
          : SizedBox.shrink(),
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
