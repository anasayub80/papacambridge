import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:studento/UI/web_appbar.dart';
import 'package:studento/model/MainFolder.dart';
import 'package:flutter/material.dart';
import 'package:studento/pages/searchPage.dart';
import 'package:provider/provider.dart';
import '../UI/loading_page.dart';
import '../UI/mainFilesList.dart';
import '../CAIE/past_papers_details_select.dart';
import 'package:studento/UI/studento_app_bar.dart';
import 'package:studento/CAIE/subjects_staggered_view.dart';
import 'package:http/http.dart' as http;
import '../provider/loadigProvider.dart';
import '../services/backend.dart';
import '../utils/ads_helper.dart';
import '../utils/theme_provider.dart';

// ignore: must_be_immutable
class PastPapersPage extends StatelessWidget {
  String? domainId;
  PastPapersPage({this.domainId});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSettings>(context, listen: false);
    return Scaffold(
        appBar: kIsWeb
            ? webAppBar(themeProvider, context)
            : StudentoAppBar(
                title: "Past Papers",
                context: context,
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return SearchPage(
                              domainId: domainId!,
                              domainName: "Past Papers",
                            );
                          },
                        ));
                      },
                      icon: Icon(Icons.search)),
                ],
              ),
        body: kIsWeb ? webBody() : mobileBody(domainId: domainId)
        //  SubjectsStaggeredListView(openPastPapersDetailsSelect),
        );
  }
}

class webBody extends StatefulWidget {
  const webBody({
    Key? key,
  }) : super(key: key);

  @override
  State<webBody> createState() => _webBodyState();
}

class _webBodyState extends State<webBody> {
  void getDomainIdformainfile(provider) async {
    // get domain id according to board
    if (provider.getboardId == 'none') {
      // if board id is stored in cache bcz user was a new visitor
      provider.changeBoardId(returnboardid('caie'));
      log('get pastpapers data board is ${provider.getboardId},');
      http.Response res =
          await http.post(Uri.parse("$webAPI?page=domains"), body: {
        'board': provider.getboardId,
        'websiteurl': 'pastpapers.papacambridge.com',
        'token': token
      });
      var response = jsonDecode(res.body);
      log('res get ${response[0]["id"]}');
      _streamController.add(response);
      // return res;
    }
  }

  StreamController _streamController = BehaviorSubject();

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration.zero,
      () {
        getDomainIdformainfile(
            Provider.of<loadingProvider>(context, listen: false));
      },
    );
    return StreamBuilder<dynamic>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return mainFilesList(
              domainId: snapshot.data[0]["id"],
              title: 'Past Papers',
              isPastPapers: true,
              domainName: 'papers',
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class mobileBody extends StatelessWidget {
  const mobileBody({
    Key? key,
    required this.domainId,
  }) : super(key: key);

  final domainId;

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(builder: (context) {
        return mainFilesList(
          domainId: domainId,
          title: 'Past Papers',
          isPastPapers: true,
          domainName: 'papers',
        );
      }),
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
              content: ListView.builder(
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
                },
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
        context: context,
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
