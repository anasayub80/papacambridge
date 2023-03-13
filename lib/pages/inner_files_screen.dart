// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:need_resume/need_resume.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:studento/pages/multiPaperView.dart';
import 'package:studento/provider/multiViewhelper.dart';
import 'package:studento/services/backend.dart';
import 'package:studento/utils/bannerAdmob.dart';
import 'package:studento/utils/funHelper.dart';
import '../Globals.dart';
import '../UI/show_case_widget.dart';
import '../UI/studento_app_bar.dart';
import '../model/MainFolder.dart';
import '../model/mainFolderRes.dart';
import '../provider/loadigProvider.dart';
import '../services/bread_crumb_navigation.dart';
import '../services/database/mysql.dart';
import '../utils/pdf_helper.dart';
import 'home_page.dart';
import 'other_fileView.dart';
import 'past_paper_view.dart';
import 'searchPage.dart';

// ignore: must_be_immutable
class innerfileScreen extends StatefulWidget {
  String? inner_file;
  String? domain;
  String? domainName;
  String? domainId;
  String? boardName;
  final title;
  bool iscomeFromMainFiles;
  static const isShowCaseLaunch = "isShowCaseLaunchinnerScreen";

  innerfileScreen({
    super.key,
    this.inner_file,
    this.domainName,
    this.boardName,
    this.domainId,
    required this.title,
    required this.iscomeFromMainFiles,
  });

  static MaterialPageRoute getRoute(String name, innerfile, title,
          bool iscomeFromMainFiles, domainId, domainName) =>
      MaterialPageRoute(
          settings: RouteSettings(name: name),
          builder: (context) => (iscomeFromMainFiles)
              ? ShowCaseWidget(
                  builder: Builder(builder: (context) {
                    return innerfileScreen(
                      inner_file: innerfile.toString(),
                      title: title,
                      iscomeFromMainFiles: iscomeFromMainFiles,
                      domainId: domainId,
                      domainName: domainName,
                    );
                  }),
                )
              : innerfileScreen(
                  inner_file: innerfile,
                  iscomeFromMainFiles: iscomeFromMainFiles,
                  title: title,
                  domainId: domainId,
                  domainName: domainName,
                ));
  @override
  State<innerfileScreen> createState() => _innerfileScreenState();
}

class _innerfileScreenState extends ResumableState<innerfileScreen> {
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
    // getStoredData();
    initData();
  }

  @override
  void dispose() {
    // Remove the observer
    super.dispose();
  }

  @override
  Future<void> onResume() async {
    super.onResume();
    log('State Resume**');
    for (var subject in allItem) {
      if (subject.urlPdf != '') {
        bool isFileAlreadyDownloaded = await PdfHelper.checkIfDownloaded(
            prettifySubjectName(subject.name!));
        if (isFileAlreadyDownloaded) {
          log('downloaded ${subject.name} && ${subject.id}');
          downloadedId.add(subject.id);
        }
      } else {
        log('State Res Res ${subject.name}');
      }
    }
    if (mounted) {
      setState(() {});
    }
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
    // blockList = prefs.getStringList('blockList') ?? [];
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
            } else if (subject.count == 0 && subject.urlPdf == '') {
              log("Count Detected${subject.name}");
              // print('Should not to show');
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
      log('filter local data');
      // get local data
      dataL = mainFolderFromJson(res.toString());
      List<MainFolder> selectedM = [];
      for (var subject in dataL!) {
        if (favItem.contains(subject.id.toString())) {
          // print('Should not to show');
        } else if (subject.count == 0 && subject.urlPdf == '') {
          // print('Should not to show');
          log("Count Detected${subject.name}");
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

  var db = Mysql();

  GlobalKey favLogoKey = GlobalKey();
  GlobalKey searchLogoKey = GlobalKey();
  List<MainFolder>? dataL;
  void initData() async {
    _streamController.add('loading');
    // http.Response res = ;
    List<MainFolder> data = await db.fetchInnerFile(
        // ignore: use_build_context_synchronously
        widget.inner_file);
    // res = await http.post(Uri.parse(innerFileApi), body: {
    //   'token': token,
    //   'fileid': widget.inner_file,
    // });
    dataL = data;
    //  dataL = mainFolderFromJson(res.body);
    List<MainFolder> selectedM = [];
    // debugPrint('innerFile list ${res.body}');
    for (var subject in dataL!) {
      if (favItem.contains(subject.id.toString())) {
        // print('Should not to show');
      } else if (subject.count == 0 && subject.urlPdf == '') {
        log("Count Detected${subject.name}");
        // print('Should not to show');
      } else {
        log('add selected m');
        selectedM.add(subject);
      }
    }
    setState(() {
      allItem = selectedM;
    });
    _streamController.add('event');

    // clearifyData(res, false);
  }

  bool isrever = false;
  // List<String> blockList = [];
  List foodItems = [];
  List<String> favItem = [];
  List<MainFolder> allItem = [];
  List<String> favItemName = [];
  var url;
  StreamController _streamController = BehaviorSubject();
  // addtoBlockList(id) async {
  //   debugPrint('remove $id');
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   blockList = prefs.getStringList('blockList') ?? [];
  //   blockList.add(id);
  //   prefs.setStringList('blockList', blockList);
  //   setState(() {
  //     allItem.removeWhere((item) => item.id == id);
  //   });
  // }
  List<String> blockList = [];

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

  addtoBlockList(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    blockList = prefs.getStringList('blockList') ?? [];
    blockList.add(id);
    prefs.setStringList('blockList', blockList);
  }

  @override
  Widget build(BuildContext context) {
    final multiProvider = Provider.of<multiViewProvider>(context, listen: true);
    void openPaper(String url, fileName) async {
      push(
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
      push(
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

    showmultiView() {
      if (allItem.length >= 2 &&
          funHelper().heartFilter(allItem[0].urlPdf.toString()) == false) {
        return true;
      } else {
        return false;
      }
    }

    return Scaffold(
        appBar: StudentoAppBar(
          title: widget.title,
          context: context,
          centerTitle: false,
          isFile: true,
          actions: [
            (showmultiView())
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return SearchPage(
                  domainId: widget.domainId ?? '',
                  domainName: widget.domainName ?? '',
                );
              },
            ));
          },
          child: Icon(Icons.search),
        ),
        bottomNavigationBar: allItem.length <= 5
            ? Column(
                // width: 320,
                // height:  ,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BannerAdmob(
                    size: AdSize.banner,
                  ),
                ],
              )
            : SizedBox.shrink());
  }

  Widget multiViewBTN(BuildContext context, multiViewProvider multiProvider) {
    return Row(
      children: [
        ElevatedButton.icon(
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
          label: Text(
            'Multi View',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: multiProvider.multiView == false
                  ? Theme.of(context).textTheme.bodyMedium!.color
                  : Colors.white,
              fontSize: 12,
            ),
          ),
          style: IconButton.styleFrom(
            backgroundColor: multiProvider.multiView == false
                ? Theme.of(context).cardColor
                : Color(0xff6C63FF),
            side: BorderSide(
                color: multiProvider.multiView == true
                    ? Colors.transparent
                    : Theme.of(context).unselectedWidgetColor),
          ),
          icon: Icon(Icons.view_agenda_outlined,
              color: multiProvider.multiView == false
                  ? Theme.of(context).iconTheme.color
                  : Colors.white),
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
          if (multiItemurl.isEmpty) {
            selectedList = List.generate(
                favItem.length + allItem.length, (index) => false);
          }
          return ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                              builder: (context) {
                                return HomePage();
                              },
                            ));
                          },
                          label: Text(
                            'Home',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          icon: Icon(Icons.home_outlined, color: Colors.white)),
                    ),
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
                            push(
                                context,
                                innerfileScreen.getRoute(
                                  favItemName[i],
                                  favItem[i],
                                  widget.title,
                                  widget.iscomeFromMainFiles,
                                  widget.domainId,
                                  widget.domainName,
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
                      allItem[index].id.toString(),
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
          debugPrint('newScreen $urlPdf');
          push(
              context,
              innerfileScreen.getRoute(name, allItem[index].id.toString(),
                  widget.title, true, widget.domainId, widget.domainName));
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
            push(
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
      trailing: funHelper().heartFilter(urlPdf.toString()) == true
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
