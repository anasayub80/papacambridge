import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:studento/pages/home_page.dart';
import 'package:studento/pages/multiPaperView.dart';
import 'package:studento/pages/past_paper_view.dart';
import 'package:studento/provider/multiViewhelper.dart';
import 'package:studento/responsive/responsive_layout.dart';
import 'package:studento/services/backend.dart';
import 'package:studento/utils/bannerAdmob.dart';
import 'package:studento/utils/funHelper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../UI/show_case_widget.dart';
import '../UI/studento_app_bar.dart';
import '../UI/web_appbar.dart';
import '../model/MainFolder.dart';
import '../services/bread_crumb_navigation.dart';
import '../utils/pdf_helper.dart';
import '../utils/sideAdsWidget.dart';
import '../utils/theme_provider.dart';
import 'other_fileView.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ignore: must_be_immutable
class innerfileScreen extends StatefulWidget {
  final inner_file;
  final title;
  bool iscomeFromMainFiles;
  static const isShowCaseLaunch = "isShowCaseLaunchinnerScreen";

  innerfileScreen({
    super.key,
    required this.inner_file,
    required this.title,
    required this.iscomeFromMainFiles,
  });
  static MaterialPageRoute getRoute(
          String name, innerfile, title, bool iscomeFromMainFiles) =>
      MaterialPageRoute(
          settings: RouteSettings(name: name),
          builder: (context) => (iscomeFromMainFiles && kIsWeb == false)
              ? ShowCaseWidget(
                  builder: Builder(builder: (context) {
                    return innerfileScreen(
                      inner_file: innerfile,
                      title: title,
                      iscomeFromMainFiles: iscomeFromMainFiles,
                    );
                  }),
                )
              : innerfileScreen(
                  inner_file: innerfile,
                  iscomeFromMainFiles: iscomeFromMainFiles,
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

    getStoredData();
  }

  String prettifySubjectName(String subjectName) {
    return subjectName.replaceFirst("\r\n", "");
  }

  @override
  void dispose() {
    // favItem.clear();
    // favItemName.clear();
    // allItem.clear();
    super.dispose();
  }

  getStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isConnected = await PdfHelper.checkIfConnected();
    if (isConnected) {
      var res = await funHelper().checkifDataExist(
          'innerData${widget.inner_file}${widget.title.trim()}');
      if (res != null) {
        http.Response myres = await http.post(Uri.parse(innerFileApi), body: {
          'token': token,
          'fileid': widget.inner_file,
        });
        if (myres.body.length <= res.length) {
          print('equal');
          clearifyData(res, true);
        } else {
          print('not equal update');
          prefs.remove('innerData${widget.inner_file}${widget.title.trim()}');
        }
      } else {
        debugPrint(res.toString());
        initData();
      }
    } else {
      var res = await funHelper().checkifDataExist(
          'innerData${widget.inner_file}${widget.title.trim()}');
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
    favItem = prefs.getStringList(
            'favItem${widget.inner_file}${widget.title.trim()}') ??
        [];
    blockList = prefs.getStringList('blockList') ?? [];
    favItemName = prefs.getStringList(
            'favItemName${widget.inner_file}${widget.title.trim()}') ??
        [];
    if (!isLocal) {
      // get Data From Api
      if (res.body.isNotEmpty) {
        if (res.body.length <= 64) {
          print('Something Wrong');
        } else {
          var response = jsonEncode(res.body);
          await prefs.setString(
              'innerData${widget.inner_file}${widget.title.trim()}', response);
          dataL = mainFolderFromJson(res.body);
          List<MainFolder> selectedM = [];
          debugPrint('innerFile list ${res.body}');
          for (var subject in dataL!) {
            if (favItem.contains(subject.id.toString())) {
              // print('Should not to show');
            } else if (blockList.contains(subject.id.toString())) {
              // print('Should not to show bcz it is blocked ');
            } else {
              selectedM.add(subject);
            }
          }
          setState(() {
            allItem = selectedM;
          });
        }
      }
    } else {
      // get local data
      dataL = mainFolderFromJson(res.toString());
      List<MainFolder> selectedM = [];
      for (var subject in dataL!) {
        if (favItem.contains(subject.id.toString())) {
          // print('Should not to show');
        } else if (blockList.contains(subject.id.toString())) {
          // print('Should not to show bcz it is blocked ');
        } else {
          selectedM.add(subject);
        }
      }
      setState(() {
        allItem = selectedM;
      });
    }

    _streamController.add('event');
    // show showcase if platform is not web
    if (widget.iscomeFromMainFiles && kIsWeb == false) {
      Future.delayed(
        Duration(milliseconds: 500),
        () {
          _isFirstLaunch().then((result) {
            if (!result)
              ShowCaseWidget.of(context)
                  .startShowCase([searchLogoKey, favLogoKey]);
          });
        },
      );
    }
  }

  GlobalKey favLogoKey = GlobalKey();
  GlobalKey searchLogoKey = GlobalKey();
  List<MainFolder>? dataL;
  void initData() async {
    _streamController.add('loading');
    http.Response res = await http.post(Uri.parse(innerFileApi), body: {
      'token': token,
      'fileid': widget.inner_file,
    });
    clearifyData(res, false);
  }

  List<String> blockList = [];
  List foodItems = [];
  List<String> favItem = [];
  List<MainFolder> allItem = [];
  List<String> favItemName = [];
  var url;
  StreamController _streamController = BehaviorSubject();
  addtoBlockList(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    blockList = prefs.getStringList('blockList') ?? [];
    blockList.add(id);
    prefs.setStringList('blockList', blockList);
  }

  List multiItemurl = [];
  List multiItemname = [];
  List selectedList = [];
  Future<bool> _isFirstLaunch() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    bool isFirstLaunch =
        sharedPreferences.getBool(innerfileScreen.isShowCaseLaunch) ?? false;

    if (!isFirstLaunch)
      sharedPreferences.setBool(innerfileScreen.isShowCaseLaunch, true);
    return isFirstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    final multiProvider = Provider.of<multiViewProvider>(context, listen: true);
    void openPaper(String url, fileName) async {
      if (kIsWeb) {
        launchUrl(Uri.parse(url));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PastPaperView([
              url,
            ], fileName, boardId, false),
          ),
        );
      }
    }

    void openMultiPaperView() async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiPaperView(
              url1: multiItemurl[0],
              url2: multiItemurl[1],
              fileName1: multiItemname[0],
              fileName2: multiItemname[1],
              boarId: boardId,
              isOthers: false),
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
      getStoredData();
    }

    final themeProvider = Provider.of<ThemeSettings>(context, listen: false);

    return Scaffold(
      appBar: kIsWeb
          ? webAppBar(themeProvider, context)
          : StudentoAppBar(
              title: widget.title,
              context: context,
            ),
      body: ResponsiveLayout(
        mobileBody: mobileLayout(multiProvider, removeFromFav,
            openMultiPaperView, openPaper, addtoFav),
        webBody: webBody(context, multiProvider, removeFromFav,
            openMultiPaperView, openPaper, addtoFav),
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

  Row webBody(
      BuildContext context,
      multiViewProvider multiProvider,
      Future<void> Function(dynamic index, dynamic id, dynamic name)
          removeFromFav,
      void Function() openMultiPaperView,
      void Function(String url, dynamic fileName) openPaper,
      Future<void> Function(dynamic index, String id, String name) addtoFav) {
    return Row(
      children: [
        Expanded(
            child: mobileLayout(multiProvider, removeFromFav,
                openMultiPaperView, openPaper, addtoFav)),
        // second column
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.20,
            height: 500,
            child: sideAdsWidget())
      ],
    );
  }

  StreamBuilder<dynamic> mobileLayout(
      multiViewProvider multiProvider,
      Future<void> Function(dynamic index, dynamic id, dynamic name)
          removeFromFav,
      void Function() openMultiPaperView,
      void Function(String url, dynamic fileName) openPaper,
      Future<void> Function(dynamic index, String id, String name) addtoFav) {
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
          addtoBlockList(widget.inner_file);
          return Center(
            child: Text(
              'No Data Found',
              style: Theme.of(context).textTheme.headline4,
            ),
          );
        } else if (snapshot.hasData) {
          if (multiItemurl.isEmpty)
            selectedList = List.generate(
                favItem.length + allItem.length, (index) => false);
          return ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              kIsWeb
                  ? ElevatedButton.icon(
                      onPressed: () {
                        GoRouter.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: EdgeInsets.all(8),
                        maximumSize: Size(200, 50),
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ))
                  : BreadCrumbNavigator(),
              SizedBox(
                height: 10,
              ),
              (allItem.length >= 2 && !kIsWeb)
                  ? Column(
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  multiProvider.setMultiViewFalse();
                                  selectedList = List.generate(
                                      favItem.length + allItem.length,
                                      (index) => false);
                                  multiItemname.clear();
                                  multiItemurl.clear();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      multiProvider.multiView == true
                                          ? Colors.transparent
                                          : Color(0xff6C63FF),
                                  side: BorderSide(
                                      color: multiProvider.multiView == false
                                          ? Colors.transparent
                                          : Theme.of(context)
                                              .unselectedWidgetColor),
                                ),
                                child: Text(
                                  'Single View',
                                  style: TextStyle(
                                      color: multiProvider.multiView == true
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .color
                                          : Colors.white),
                                ),
                              ),
                              (widget.iscomeFromMainFiles && !kIsWeb)
                                  ? CustomShowcaseWidget(
                                      globalKey: searchLogoKey,
                                      description:
                                          "View Paper's in MultiView Screen",
                                      title: 'MultiView',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: MultiViewButton(
                                            multiProvider: multiProvider),
                                      ),
                                    )
                                  : MultiViewButton(
                                      multiProvider: multiProvider),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          ),
                          height: 48,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
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
                                  iscomeFromMainFiles:
                                      widget.iscomeFromMainFiles,
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
                  return filesListTile(
                      index,
                      context,
                      allItem[index].urlPdf!,
                      allItem[index].id,
                      allItem[index].name!,
                      multiProvider,
                      openMultiPaperView,
                      openPaper,
                      addtoFav);
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
    );
  }

  ListTile filesListTile(
      int index,
      BuildContext context,
      String urlPdf,
      String id,
      String name,
      multiViewProvider multiProvider,
      void Function() openMultiPaperView,
      void Function(String url, dynamic fileName) openPaper,
      Future<void> Function(dynamic index, String id, String name) addtoFav) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      selected: selectedList[index],
      onTap: () {
        if (urlPdf == "" || urlPdf == 'null') {
          debugPrint('newScreen');
          if (kIsWeb) {
            print('inner go route');
            GoRouter.of(context).pushNamed('innerfile', params: {
              // 'title': widget.title,
              // 'id': allItem[index].id,
              'id': allItem[index].id,
              'domainName': 'papers',
              'boardName': 'ocr',
              'url': allItem[index].mainUrl.toString(),
            });
          } else {
            Navigator.push(
                context,
                innerfileScreen.getRoute(
                    name, allItem[index].id, widget.title, false));
          }
        } else {
          if (funHelper().pdfFilter(urlPdf)) {
            if (multiProvider.multiView == true && allItem.length >= 2) {
              if (selectedList[index] == true) {
                multiItemurl.remove(urlPdf);
                multiItemname.remove(allItem[index].name);
                selectedList[index] = false;
                setState(() {});
              } else if (multiItemurl.length != 2) {
                multiItemurl.add(
                  urlPdf,
                );
                multiItemname.add(
                  allItem[index].name,
                );
                selectedList[index] = true;
                setState(() {});
                if (multiItemurl.length >= 2) {
                  openMultiPaperView();
                }
              } else {
                BotToast.showText(
                    text: 'Only Two Paper Supported in MultiView');
              }
            } else {
              openPaper(urlPdf, name.replaceFirst(" ", " \n"));
            }
          } else {
            if (kIsWeb) {
              print(urlPdf.toString());
              launchUrl(Uri.parse(urlPdf));
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OtherFilesViewPage(
                    [
                      urlPdf,
                    ],
                    prettifySubjectName(name),
                    allItem[index].id.toString().replaceFirst(" ", " \n"),
                  ),
                ),
              );
            }
          }
        }
      },
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(funHelper().fileLogoAssets(urlPdf.toString())),
      ),
      onLongPress: () {
        print(urlPdf);
      },
      trailing: funHelper().heartFilter(urlPdf.toString()) == true
          ? (widget.iscomeFromMainFiles == true && !kIsWeb)
              ? index == 0
                  ? SizedBox(
                      width: 50,
                      height: 50,
                      child: CustomShowcaseWidget(
                        globalKey: favLogoKey,
                        description:
                            'You can save your favorite subject at top',
                        title: 'Favourite',
                        child: favButton(addtoFav, index, name, context),
                      ),
                    )
                  : favButton(addtoFav, index, name, context)
              : favButton(addtoFav, index, name, context)
          : selectedList[index] == true
              ? Icon(
                  Icons.check,
                  color: Colors.green,
                )
              : SizedBox.shrink(),
      title: Text(
        prettifySubjectName(name),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  IconButton favButton(
      Future<void> Function(dynamic index, String id, String name) addtoFav,
      int index,
      String name,
      BuildContext context) {
    return IconButton(
      onPressed: (() {
        addtoFav(
          index,
          allItem[index].id,
          name,
        );
      }),
      icon: Icon(
        Icons.favorite_border,
        color: Theme.of(context).textTheme.bodyText1!.color,
      ),
    );
  }
}

class MultiViewButton extends StatelessWidget {
  const MultiViewButton({
    Key? key,
    required this.multiProvider,
  }) : super(key: key);

  final multiViewProvider multiProvider;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        multiProvider.setMultiViewTrue();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: multiProvider.multiView == false
            ? Colors.transparent
            : Color(0xff6C63FF),
        side: BorderSide(
            color: multiProvider.multiView == true
                ? Colors.transparent
                : Theme.of(context).unselectedWidgetColor),
      ),
      child: Text(
        'Multi View',
        style: TextStyle(
            color: multiProvider.multiView == false
                ? Theme.of(context).textTheme.bodyText1!.color
                : Colors.white),
      ),
    );
  }
}
