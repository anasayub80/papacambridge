import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:studento/pages/editable_pdf.dart';
import 'package:studento/pages/home_page.dart';
import 'package:studento/pages/multiPaperView.dart';
import 'package:studento/provider/multiViewhelper.dart';
import 'package:studento/services/backend.dart';
import 'package:studento/utils/bannerAdmob.dart';
import 'package:studento/utils/funHelper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../UI/show_case_widget.dart';
import '../UI/studento_app_bar.dart';
import '../model/MainFolder.dart';
import '../provider/loadigProvider.dart';
import '../services/bread_crumb_navigation.dart';
import '../utils/pdf_helper.dart';
import 'other_fileView.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'past_paper_view.dart';

// ignore: must_be_immutable
class innerfileScreen extends StatefulWidget {
  String? inner_file;
  String? domain;
  String? domainName;
  String? domainId;
  String? boardName;
  final title;
  final url_structure;
  bool iscomeFromMainFiles;
  static const isShowCaseLaunch = "isShowCaseLaunchinnerScreen";

  innerfileScreen({
    super.key,
    this.inner_file,
    this.domainName,
    this.boardName,
    this.domainId,
    required this.title,
    required this.url_structure,
    required this.iscomeFromMainFiles,
  });
  static MaterialPageRoute getRoute(
          String name, innerfile, title, bool iscomeFromMainFiles) =>
      MaterialPageRoute(
          settings: RouteSettings(name: name),
          builder: (context) => (iscomeFromMainFiles)
              ? ShowCaseWidget(
                  builder: Builder(builder: (context) {
                    return innerfileScreen(
                      inner_file: innerfile,
                      title: title,
                      iscomeFromMainFiles: iscomeFromMainFiles,
                      url_structure: '',
                    );
                  }),
                )
              : innerfileScreen(
                  inner_file: innerfile,
                  iscomeFromMainFiles: iscomeFromMainFiles,
                  title: title,
                  url_structure: 'none',
                ));
  @override
  State<innerfileScreen> createState() => _innerfileScreenState();
}

class _innerfileScreenState extends State<innerfileScreen> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<multiViewProvider>(context, listen: false)
          .setMultiViewFalse();
    });
    getStoredData();
  }

  String prettifySubjectName(String subjectName) {
    var name = subjectName.replaceFirst("\r", "");
    return name.replaceFirst("\n", "");
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

  List downloadedId = [];

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
          bool isFileAlreadyDownloaded = await PdfHelper.checkIfDownloaded(
              prettifySubjectName(subject.name!));
          if (isFileAlreadyDownloaded) {
            downloadedId.add(subject.id);
          }
          selectedM.add(subject);
        }
      }
      setState(() {
        allItem = selectedM;
      });
    }
    _streamController.add('event');
    // show showcase if platform is not web
    // if (widget.iscomeFromMainFiles) {
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        if (funHelper().heartFilter(allItem[0].urlPdf.toString()) == false)
          _isFirstLaunch().then((result) {
            if (!result)
              ShowCaseWidget.of(context)
                  .startShowCase([searchLogoKey, favLogoKey]);
          });
      },
    );
    // }
  }

  GlobalKey favLogoKey = GlobalKey();
  GlobalKey searchLogoKey = GlobalKey();
  List<MainFolder>? dataL;
  void initData() async {
    _streamController.add('loading');
    http.Response res;
    res = await http.post(Uri.parse(innerFileApi), body: {
      'token': token,
      'fileid': widget.inner_file,
    });

    clearifyData(res, false);
  }

  bool isrever = false;
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
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => EditablePastPaperView([
      //       url,
      //     ],
      //         fileName,
      //         Provider.of<loadingProvider>(context, listen: false).getboardId,
      //         false),
      //   ),
      // );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PastPaperView([
            url,
          ],
              fileName,
              Provider.of<loadingProvider>(context, listen: false).getboardId,
              false),
        ),
      );
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
              boarId: Provider.of<loadingProvider>(context, listen: false)
                  .getboardId,
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

    return Scaffold(
      appBar: StudentoAppBar(
        title: widget.title,
        context: context,
        centerTitle: false,
        isFile: true,
        actions: [
          (allItem.length >= 2 &&
                  funHelper().heartFilter(allItem[0].urlPdf.toString()) ==
                      false)
              ? (widget.iscomeFromMainFiles)
                  ? CustomShowcaseWidget(
                      globalKey: searchLogoKey,
                      description: "View Paper's in MultiView Screen",
                      title: 'MultiView',
                      child: multiViewBTN(context, multiProvider))
                  : multiViewBTN(context, multiProvider)
              : SizedBox.shrink(),
          IconButton(
            onPressed: () {
              if (isrever) {
                setState(() {
                  isrever = false;
                });
              } else {
                setState(() {
                  isrever = true;
                });
              }
              print(isrever.toString());
            },
            icon: isrever
                ? Icon(
                    Icons.arrow_downward,
                    color: Color(0xff6C63FF),
                  )
                : Icon(
                    Icons.arrow_upward,
                    color: Theme.of(context).iconTheme.color,
                  ),
          )
        ],
      ),
      body: mobileLayout(multiProvider, removeFromFav, openMultiPaperView,
          openPaper, addtoFav),
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

  Widget multiViewBTN(BuildContext context, multiViewProvider multiProvider) {
    return Row(
      children: [
        Text(
          'Multi View',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium!.color,
            fontSize: 12,
          ),
        ),
        IconButton(
          onPressed: () {
            if (Provider.of<multiViewProvider>(context, listen: false)
                    .multiView ==
                false) {
              debugPrint('set true');
              multiProvider.setMultiViewTrue();
            } else {
              multiProvider.setMultiViewFalse();
              debugPrint('set false');
              selectedList = List.generate(
                  favItem.length + allItem.length, (index) => false);
              multiItemname.clear();
              multiItemurl.clear();
            }
          },
          style: IconButton.styleFrom(
            backgroundColor: multiProvider.multiView == false
                ? Colors.white
                : Color(0xff6C63FF),
            side: BorderSide(
                color: multiProvider.multiView == true
                    ? Colors.transparent
                    : Theme.of(context).unselectedWidgetColor),
          ),
          icon: Icon(Icons.view_agenda_outlined,
              color: multiProvider.multiView == false
                  ? Theme.of(context).iconTheme.color
                  : Color(0xff6C63FF)),
        ),
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
              style: Theme.of(context).textTheme.headlineMedium,
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
              SizedBox(
                width: double.infinity,
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) {
                              return HomePage();
                            },
                          ));
                        },
                        icon: Icon(
                          Icons.home_outlined,
                          color: Colors.pink,
                        )),
                    BreadCrumbNavigator(),
                    SizedBox(
                      width: 100,
                    ),
                  ],
                ),
              ),
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
                            Navigator.push(
                                context,
                                innerfileScreen.getRoute(
                                    favItemName[i],
                                    favItem[i],
                                    widget.title,
                                    widget.iscomeFromMainFiles));
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
                reverse: isrever,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  if (index % 10 == 5 && index != 0) {
                    return BannerAdmob(
                      size: AdSize.largeBanner,
                    );
                  }

                  return const SizedBox();
                },
                itemBuilder: (context, index) {
                  return filesListTile(
                      index,
                      context,
                      allItem[index].urlPdf ?? '',
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

  Widget filesListTile(
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
          Navigator.push(
              context,
              innerfileScreen.getRoute(
                  name, allItem[index].id, widget.title, true));
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
      },
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(funHelper().fileLogoAssets(urlPdf.toString())),
      ),
      onLongPress: () {
        print(urlPdf);
      },
      trailing: kIsWeb
          ? SizedBox.shrink()
          : funHelper().heartFilter(urlPdf.toString()) == true
              ? (widget.iscomeFromMainFiles == true)
                  ? index == 0
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: CustomShowcaseWidget(
                            globalKey: favLogoKey,
                            description:
                                'You can save your favorite subject at top',
                            title: 'favorite',
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
                  : downloadedId.contains(allItem[index].id)
                      ? Icon(Icons.verified, color: Colors.green)
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
        color: Theme.of(context).textTheme.bodyLarge!.color,
      ),
    );
  }
}
