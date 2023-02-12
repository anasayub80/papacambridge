// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:developer';
import 'package:bot_toast/bot_toast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:need_resume/need_resume.dart';
import 'package:studento/CAIE/pastPaperViewCAIE.dart';
import 'package:studento/UI/studento_app_bar.dart';
import 'package:studento/model/MainFolder.dart';
import 'package:studento/model/PdfModal.dart';
// import 'package:studento/pages/PdfDemo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studento/model/user_data.dart';
import 'package:studento/model/Filtered.dart';
import 'package:studento/UI/steps/year.dart';
import 'package:studento/UI/steps/season.dart';
import 'package:studento/model/MainFolderInit.dart';
import 'package:http/http.dart' as http;
import 'package:studento/services/backend.dart';
import 'package:studento/utils/funHelper.dart';
import '../Globals.dart';
import '../pages/multiPaperView.dart';
import '../pages/other_fileView.dart';
import '../provider/loadigProvider.dart';
import '../provider/multiViewhelper.dart';
import '../utils/bannerAdmob.dart';
import 'package:provider/provider.dart';

import '../utils/pdf_helper.dart';

enum Season { spring, summer, winter }

final dataKey = GlobalKey();
final dataKey2 = GlobalKey();

bool showPapers = false;

class PaperDetailsSelectionPage extends StatefulWidget {
  final MainFolder subject;
  // final Subject subject;
  const PaperDetailsSelectionPage(this.subject);

  @override
  // ignore: library_private_types_in_public_api
  _PaperDetailsSelectionPageState createState() =>
      _PaperDetailsSelectionPageState();

  // ignore: library_private_types_in_public_api
  static _PaperDetailsSelectionPageState? of(BuildContext context) {
    final _PaperDetailsSelectionPageState? navigator =
        context.findAncestorStateOfType<State<PaperDetailsSelectionPage>>()
            as _PaperDetailsSelectionPageState?;

    assert(() {
      if (navigator == null) {
        throw FlutterError(
            '_PaperDetailsSelectionPageState operation requested with a context that does '
            'not include a PaperDetailsSelectionPage.');
      }
      return true;
    }());

    return navigator;
  }
}

class _PaperDetailsSelectionPageState
    extends ResumableState<PaperDetailsSelectionPage> {
  int _currentStep = 0;
  set currentStep(int currentStep) =>
      setState(() => _currentStep = currentStep);
  int get currentStep => _currentStep;
  @override
  Future<void> onResume() async {
    super.onResume();
    log('State Resume**');
    for (var subject in pdfModal) {
      bool isFileAlreadyDownloaded =
          await PdfHelper.checkIfDownloaded(prettifySubjectName(subject.name!));
      if (isFileAlreadyDownloaded) {
        downloadedId.add(subject.id);
      }
    }
    setState(() {});
  }

  @override
  void onPause() {
    super.onPause();
    log('State Pause**');
  }

  int? _selectedComponent;
  set selectedComponent(int? componentNo) =>
      setState(() => _selectedComponent = componentNo);
  int? get selectedComponent => _selectedComponent;
  PdfModal? _selectedPdf;
  set selectedPdf(PdfModal? pdf) => setState(() => _selectedPdf = pdf);
  PdfModal? get selectedPdf => _selectedPdf;
  int? _selectedYear;
  // to change data from another file
  set selectedYear(int? year) => setState(() => _selectedYear = year);
  int? get selectedYear => _selectedYear;
  bool _isLoading = true;
  set isLoading(bool? val) => setState(() => _isLoading = val!);
  bool? get isLoading => _isLoading;
  Season? _selectedSeason;
  set selectedSeason(Season? season) =>
      setState(() => _selectedSeason = season);
  Season? get selectedSeason => _selectedSeason;

  static const _yearStepNo = 0;
  static const _seasonStepNo = 1;
  // ignore: unused_field
  static const _componentStepNo = 2;

  GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();

  Level? level;

  String? mirrorName;
  String? mirrorName2;
  List<Filtered> filtered = [];
  bool isLoaded = false;
  List<PdfModal> pdfModal = [];
  bool singleSelect = false;
  List<Step> steps() => <Step>[
        Step(
          title: Text(
            "Year",
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontWeight: FontWeight.normal,
                fontSize: 12),
          ),
          content: startDate == endDate
              ? InkWell(
                  onTap: () {
                    singleSelect = true;
                    selectedYear = startDate;
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 140,
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: singleSelect ? Colors.black : Colors.white),
                    child: Text('$startDate',
                        style: TextStyle(
                          color: !singleSelect ? Colors.black : Colors.white,
                        )),
                  ))
              : YearStep(
                  widget.subject,
                  startDate: startDate,
                  endDate: endDate,
                ),
          isActive: (_currentStep == _yearStepNo),
          state: getState(_yearStepNo),
        ),
        Step(
          title: Text(
            "Season",
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontWeight: FontWeight.normal,
                fontSize: 12),
          ),
          content: SeasonStep(),
          isActive: (_currentStep == _seasonStepNo),
          state: getState(_seasonStepNo),
        ),
      ];

  @override
  void initState() {
    getPapersData();
    super.initState();
  }

  int median(List<int> a) {
    int middle = a.length ~/ 2;
    if (a.length % 2 == 1) {
      return a[middle];
    } else {
      return (a[middle - 1] + a[middle]) ~/ 2.0;
    }
  }

  var type = 'QP';
  bool loading = true;
  int? startDate;
  int? endDate;
  getPapersData() async {
    String url =
        '$caeiAPI?main_folder=${widget.subject.parent}&papers=pastpapers&id=${widget.subject.id}';
    log('Url $url');
    http.Response res = await http.get(Uri.parse(url));
    List<MainFolderInit> data = mainFolderInitFromJson(res.body);
    int _startDate = int.parse(data[0].year![0][0]);
    int _endDate = int.parse(data[data.length - 1].year![0][0]);
    setState(() {
      selectedYear = median([_startDate, _endDate]);
      startDate = _startDate;
      endDate = _endDate;
      _selectedYear = _endDate;
      loading = false;
    });
  }

  String? season;

  loadData(Season selectedSeason) async {
    setState(() {
      _isLoading = true;
      showPapers = true;
    });

    String url =
        'https://papacambridge.com/api.php?main_folder=${widget.subject.parent}&papers=pastpapers&id=${widget.subject.id}&year=$selectedYear';
    print(url);

    http.Response res = await http.get(Uri.parse(url));

    print(res.body);
    List<Filtered> filteredL = filteredFromJson(res.body);
    print(filteredL.length);
    print('ledngggggggggggggggggggggggggg');
    if (filteredL != []) {
      print('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq');
      switch (selectedSeason) {
        case Season.summer:
          season = 'Summer';
          break;
        case Season.spring:
          season = 'Spring';
          break;
        case Season.winter:
          season = 'Winter';
          break;
        default:
      }

      int? id;
      for (var e in filteredL) {
        if (season == e.weather) {
          id = e.id;
        }
      }

      String url1 =
          'https://papacambridge.com/api.php?main_folder=${widget.subject.parent}&papers=pastpapers&id=$id&year=skip';
      print(url1);
      http.Response res1 = await http.get(Uri.parse(url1));
      print(res1.body);
      List<PdfModal> pdfModalL = pdfModalFromJson(res1.body);
      List<PdfModal> dataL = pdfModalL;
      for (var subject in dataL) {
        bool isFileAlreadyDownloaded = await PdfHelper.checkIfDownloaded(
            prettifySubjectName(subject.name!));
        if (isFileAlreadyDownloaded) {
          downloadedId.add(subject.id);
        }
      }
      setState(() {
        // check if data null or not []
        resCheck = res1.body;
        // check if data null or not []
        pdfModal = pdfModalL;
        if (Provider.of<multiViewProvider>(context, listen: false).multiView ==
            false) {
          debugPrint('set true');
        } else {
          selectedList = List.generate(resCheck!.length, (index) => false);
          multiItemname.clear();
          multiItemurl.clear();
        }
        _isLoading = false;
      });
      Scrollable.ensureVisible(dataKey2.currentContext!,
          duration: Duration(seconds: 1));
    }
  }

  List downloadedId = [];
  Widget multiViewBTN(BuildContext context, multiViewProvider multiProvider) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: () {
              if (Provider.of<multiViewProvider>(context, listen: false)
                      .multiView ==
                  false) {
                debugPrint('set true');
                multiProvider.setMultiViewTrue();
              } else {
                multiProvider.setMultiViewFalse();
                debugPrint('set false');
                selectedList =
                    List.generate(resCheck!.length, (index) => false);
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
                    : Colors.white),
          ),
        ),
      ],
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
            boarId:
                Provider.of<loadingProvider>(context, listen: false).getboardId,
            isOthers: false),
      ),
    );
  }

  List multiItemurl = [];
  List multiItemname = [];
  List selectedList = [];
  // check if data null or not []
  var resCheck;
  @override
  Widget build(BuildContext context) {
    final multiProvider = Provider.of<multiViewProvider>(context, listen: true);
    return Scaffold(
      key: _scaffoldKey,
      appBar: StudentoAppBar(
        title: "Past Paper",
        context: context,
        centerTitle: false,
        isFile: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [multiViewBTN(context, multiProvider)],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: Theme(
                      data: ThemeData(
                        primarySwatch: Colors.blue,
                        colorScheme: ColorScheme.light(primary: Colors.blue),
                      ),
                      child: Stepper(
                        physics: NeverScrollableScrollPhysics(),
                        steps: steps(),
                        currentStep: _currentStep,
                        controlsBuilder: (context, ControlsDetails controls) {
                          return stepperControls(context,
                              onStepContinue: controls.onStepContinue);
                        },
                        type: StepperType.vertical,
                        onStepTapped: changeStep,
                        onStepCancel: cancelStep,
                        onStepContinue: continueStep,
                      ),
                    ),
                  ),
                  if (showPapers)
                    Container(
                        key: dataKey2,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: type == 'QP'
                                          ? Colors.pink
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        type = 'QP';
                                        selectedPdf = null;
                                      });
                                    },
                                    child: Center(
                                      child: Text(
                                        '  QP  ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: type == 'MS'
                                          ? Colors.pink
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedPdf = null;
                                        type = 'MS';
                                      });
                                    },
                                    child: Center(
                                      child: Text(
                                        '  MS  ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: type == 'Others'
                                          ? Colors.pink
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        type = 'Others';
                                        selectedPdf = null;
                                      });
                                    },
                                    child: Center(
                                      child: Text(
                                        'Others',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            ),
                            type != 'Others'
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        top: 15.0,
                                        bottom: 30.0,
                                        left: 30,
                                        right: 30),
                                    child: Text(
                                      "Pick a number, any number... the component number!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: 10,
                                  ),
                            _isLoading
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : resCheck.toString() == '[]'
                                    ? Center(
                                        child: Text(
                                          'No Past Paper Founds!',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Wrap(
                                            direction: Axis.horizontal,
                                            alignment: WrapAlignment.center,
                                            children: pdfModal
                                                .map((e) {
                                                  int index =
                                                      pdfModal.indexOf(e);
                                                  log('my component index is ${e.paper}');
                                                  // type contain filter QP MS Or Others
                                                  if (type == e.paper) {
                                                    log("Comg Widget Called! is ${e.paper}");
                                                    return multiProvider
                                                            .multiView
                                                        ? SizedBox(
                                                            height: 40.0,
                                                            width: 100.0,
                                                            child:
                                                                RawMaterialButton(
                                                              onPressed: () {
                                                                Scrollable.ensureVisible(
                                                                    dataKey
                                                                        .currentContext!,
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1));

                                                                if (multiProvider
                                                                            .multiView ==
                                                                        true &&
                                                                    resCheck.length >=
                                                                        2) {
                                                                  if (selectedList[
                                                                          index] ==
                                                                      true) {
                                                                    multiItemurl
                                                                        .remove(
                                                                            e.urlPdf);
                                                                    multiItemname
                                                                        .remove(
                                                                            e.name);
                                                                    selectedList[
                                                                            index] =
                                                                        false;
                                                                    setState(
                                                                        () {});
                                                                  } else if (multiItemurl
                                                                          .length !=
                                                                      2) {
                                                                    multiItemurl
                                                                        .add(
                                                                      e.urlPdf,
                                                                    );
                                                                    multiItemname
                                                                        .add(
                                                                      e.name,
                                                                    );
                                                                    selectedList[
                                                                            index] =
                                                                        true;
                                                                    setState(
                                                                        () {});
                                                                    if (multiItemurl
                                                                            .length >=
                                                                        2) {
                                                                      openMultiPaperView();
                                                                    }
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text("Only Two Paper Supported in MultiView"),
                                                                        backgroundColor:
                                                                            Colors.red[900],
                                                                      ),
                                                                    );
                                                                  }
                                                                }
                                                                // PaperDetailsSelectionPage.of(
                                                                //             context)!
                                                                //         .selectedComponent =
                                                                //     widget
                                                                //         .component;
                                                                // PaperDetailsSelectionPage.of(
                                                                //             context)!
                                                                //         .selectedPdf =
                                                                //     widget.pdf;
                                                              },
                                                              child: Card(
                                                                elevation:
                                                                    (selectedList[index] ==
                                                                            true)
                                                                        ? 2
                                                                        : 4,
                                                                shape:
                                                                    StadiumBorder(),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      ShapeDecoration(
                                                                    color: (selectedList[index] ==
                                                                            true)
                                                                        ? Theme.of(context)
                                                                            .iconTheme
                                                                            .color
                                                                        : Colors
                                                                            .transparent,
                                                                    shape:
                                                                        StadiumBorder(),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Center(
                                                                        child:
                                                                            Text(
                                                                          e.keyword!,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16.0,
                                                                            // fontSize: 12.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: (selectedList[index] == true)
                                                                                ? Colors.blue
                                                                                : Theme.of(context).textTheme.bodyLarge!.color,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            child:
                                                                ComponentWidget(
                                                              index,
                                                              pdf: e,
                                                              type,
                                                            ),
                                                          );
                                                  } else if (type == 'Others' &&
                                                      e.paper != 'QP' &&
                                                      e.paper != 'MS') {
                                                    log("Comg Widget Called! is ${e.paper}");
                                                    return ListTile(
                                                      onTap: () {
                                                        if (funHelper()
                                                            .pdfFilter(
                                                                e.urlPdf)) {
                                                          if (multiProvider
                                                                      .multiView ==
                                                                  true &&
                                                              resCheck.length >=
                                                                  2) {
                                                            if (selectedList[
                                                                    index] ==
                                                                true) {
                                                              multiItemurl
                                                                  .remove(
                                                                      e.urlPdf);
                                                              multiItemname
                                                                  .remove(
                                                                      e.name);
                                                              selectedList[
                                                                      index] =
                                                                  false;
                                                              setState(() {});
                                                            } else if (multiItemurl
                                                                    .length !=
                                                                2) {
                                                              multiItemurl.add(
                                                                e.urlPdf,
                                                              );
                                                              multiItemname.add(
                                                                e.name,
                                                              );
                                                              selectedList[
                                                                  index] = true;
                                                              setState(() {});
                                                              if (multiItemurl
                                                                      .length >=
                                                                  2) {
                                                                openMultiPaperView();
                                                              }
                                                            } else {
                                                              BotToast.showText(
                                                                  text:
                                                                      'Only Two Paper Supported in MultiView');
                                                            }
                                                          } else {
                                                            openPaper2(
                                                                e.urlPdf!,
                                                                prettifySubjectName(
                                                                    e.name!));
                                                          }
                                                        } else {
                                                          push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  OtherFilesViewPage(
                                                                [
                                                                  e.urlPdf!,
                                                                ],
                                                                prettifySubjectName(
                                                                    e.name!),
                                                                e.id
                                                                    .toString()
                                                                    .replaceFirst(
                                                                        " ",
                                                                        " \n"),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                        // e.urlPdf
                                                        //         .toString()
                                                        //         .contains(
                                                        //             '.pdf')
                                                        //     ? openPaper2(
                                                        //         e.urlPdf!,
                                                        //         e.name!,
                                                        //       )
                                                        //     : push(
                                                        //         context,
                                                        //         MaterialPageRoute(
                                                        //           builder: (_) =>
                                                        //               OtherFilesViewPage(
                                                        //             [
                                                        //               e.urlPdf!,
                                                        //             ],
                                                        //             e.name!,
                                                        //             e.id.toString(),
                                                        //           ),
                                                        //         ),
                                                        //       );
                                                      },
                                                      leading: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Image.asset(e
                                                                .urlPdf
                                                                .toString()
                                                                .contains(
                                                                    '.pdf')
                                                            ? 'assets/icons/pdf.png'
                                                            : e.urlPdf
                                                                    .toString()
                                                                    .contains(
                                                                        '.doc')
                                                                ? 'assets/icons/doc.png'
                                                                : 'assets/icons/folder.png'),
                                                      ),
                                                      title: Text(
                                                        e.name ??
                                                            e.name ??
                                                            'fileName',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      trailing: selectedList[
                                                                  index] ==
                                                              true
                                                          ? Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          : downloadedId
                                                                  .contains(
                                                                      e.id)
                                                              ? Icon(
                                                                  Icons
                                                                      .verified,
                                                                  color: Colors
                                                                      .green)
                                                              : SizedBox
                                                                  .shrink(),
                                                    );
                                                  } else {
                                                    log("No Past paper Component Called!");
                                                    return Container(
                                                      width: 0,
                                                      height: 0,
                                                    );
                                                  }
                                                })
                                                .toList()
                                                .cast<Widget>()),
                                      ),
                            BannerAdmob(size: AdSize.banner),
                            if (selectedPdf != null &&
                                multiProvider.multiView == false)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: SizedBox(
                                  height: 50,
                                  width: 100,
                                  child: RawMaterialButton(
                                    onPressed: () => openPaper(
                                        selectedPdf!.urlPdf!,
                                        selectedPdf!.name),
                                    shape: StadiumBorder(),
                                    elevation: 6.0,
                                    fillColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0, vertical: 15.0),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'View',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 12.0,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(
                              key: dataKey,
                              height: 100,
                            ),
                          ],
                        ))
                ],
              ),
            ),
    );
  }

  void changeStep(int stepTapped) {
    setState(() {
      currentStep = stepTapped;
      print("Current step is $stepTapped!");
    });
  }

  void continueStep() {
    bool isAllDetailsSelected = (_selectedSeason != null &&
        // _selectedComponent != null &&
        _selectedYear != null);

    print(_selectedSeason);
    print('#########################');
    // if(_selectedSeason)
    bool isNotTheLastStep = _currentStep < steps().length - 1;

    if (isNotTheLastStep)
      setState(() => currentStep++);
    else if (isAllDetailsSelected) {
      loadData(_selectedSeason!);
      Future.delayed(
        Duration(milliseconds: 300),
        () {
          Scrollable.ensureVisible(dataKey.currentContext!,
              duration: Duration(seconds: 1));
        },
      );
    }
    // openPaper();
    else {
      if (_selectedSeason == null) changeStep(_seasonStepNo);
      // else if (_selectedComponent == null) changeStep(_componentStepNo);

      if (_selectedSeason == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Looks like you forgot to select an option!"),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    }
  }

  void cancelStep() {
    if (_currentStep > 0) {
      currentStep -= 1;
    } else {
      currentStep = 0;
    }
    print("Step cancelled, step is $_currentStep!");
  }

  String returnSeasonName(selectedSeason) {
    var find;
    switch (selectedSeason) {
      case Season.summer:
        find = 's';
        break;
      case Season.spring:
        find = 'spr';
        break;
      case Season.winter:
        find = 'w';
        break;
      default:
    }

    return find;
  }

  StepState getState(int stepNo) {
    if (_currentStep == stepNo) {
      return StepState.editing;
    }
    return StepState.indexed;
  }

  String get codeStr => widget.subject.folderCode.toString();
  String get seasonChar => returnSeasonName(selectedSeason);

  // selectedSeason == Season.summer
  //     ? 's'
  //     : Season.spring
  //         ? 'spr'
  //         : 'w';
  String get twoDigitYear => selectedYear.toString().substring(2, 4);
  String get componentStr => (selectedYear! >= 2018 && selectedComponent! < 10)
      ? "0$selectedComponent"
      : "$selectedComponent";

  String get fileName {
    var code = widget.subject.folderCode;
    String fileName = "${code}_$seasonChar$twoDigitYear$type$componentStr.pdf";
    return fileName;
  }

  String generateMainUrl(MainFolder subject) {
    return subject.urlPdf!;
  }

  Future<void> loadDisplayNames() async {
    var dataStr = await rootBundle.loadString('assets/json/display_names.json');
    Map data1 = json.decode(dataStr);
    var data2Str =
        await rootBundle.loadString('assets/json/display_names_2.json');
    Map data2 = json.decode(data2Str);

    setState(() {
      mirrorName = data1[level!.value][codeStr] as String;
      mirrorName2 = data2[level!.value][codeStr] as String;

      isLoaded = true;
    });
  }

  @override
  void dispose() {
    // ignore: todo
    // TODO: implement dispose
    _selectedPdf = null;
    _isLoading = true;
    showPapers = false;
    super.dispose();
  }

  String? generateMirror1Url() {
    if (mirrorName == null) return null;
    String serverDir = 'https://pastpapers.co/cie';

    String seasonWord;
    switch (selectedSeason!) {
      case Season.summer:
        seasonWord = (selectedYear! < 2018) ? 'Jun' : 'May-June';
        break;
      case Season.winter:
        seasonWord = (selectedYear! < 2018) ? 'Nov' : 'Oct-Nov';
        break;
      case Season.spring:
        seasonWord = (selectedYear! < 2018) ? 'March' : 'March';
        break;
    }

    String yearSeasonDir;
    if (selectedYear! < 2018)
      yearSeasonDir = "$selectedYear/$selectedYear $seasonWord";
    else
      yearSeasonDir = "$selectedYear-$seasonWord";

    var levelStr = "${level!.value}-Level";
    var url =
        "$serverDir/$levelStr/$mirrorName-$codeStr/$yearSeasonDir/$fileName";

    return Uri.encodeFull(url);
  }

  String? generateMirror2Url() {
    if (mirrorName2 == null) return null;
    String urlPrefix = 'https://papers.gceguide.com';
    var levelStr = "${level!.value} Levels";
    String url = "$urlPrefix/$levelStr/$mirrorName2 ($codeStr)/$fileName";

    return Uri.encodeFull(url);
  }

  /// Open the Paper in the PastPaperView.
  void openPaper(String url, fileName) async {
    push(
      context,
      MaterialPageRoute(
        builder: (_) => PastPaperViewCAIE(
          [
            url,
          ], //..retainWhere((url) => url != null),
          fileName,
          Provider.of<loadingProvider>(context, listen: false).getboardId,
          false,
          type == 'QP' ? true : false,
          true,
        ),
      ),
    );
  }

  void openPaper2(String url, fileName) async {
    // List<String> moreUrls = [];

    print("url file $url");
    // moreUrls.add(url);
    print('kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk');
    // print(moreUrls);
    print('lllllllllllllllllllllllllllllllllllllll');
    push(
      context,
      MaterialPageRoute(
        builder: (_) => PastPaperViewCAIE(
          [
            url,
          ],
          fileName,
          Provider.of<loadingProvider>(context, listen: false).getboardId,
          true,
          type == 'QP' ? true : false,
          true,
        ),
      ),
    );
  }

  Widget stepperControls(BuildContext context, {onStepContinue}) {
    return Container(
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildNextButton(onStepContinue, Icons.navigate_next, "Next"),
        ],
      ),
    );
  }
}

Widget buildNextButton(VoidCallback onPressed, IconData icon, String label) {
  return RawMaterialButton(
    onPressed: onPressed,
    shape: StadiumBorder(),
    elevation: 6.0,
    fillColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
    child: Row(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        Icon(
          icon,
          color: Colors.white,
          size: 20.0,
        )
      ],
    ),
  );
}

class ComponentWidget extends StatefulWidget {
  final PdfModal? pdf;
  final type;
  const ComponentWidget(this.component, this.type, {this.pdf});
  final int component;

  @override
  State<ComponentWidget> createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends State<ComponentWidget> {
  @override
  void initState() {
    checkifDownloaded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<multiViewProvider>(context, listen: false)
          .setMultiViewFalse();
    });
    super.initState();
  }

  bool isFileAlreadyDownloadedresult = false;
  checkifDownloaded() async {
    bool isFileAlreadyDownloaded = await PdfHelper.checkIfDownloaded(
        prettifySubjectName(widget.pdf!.name!));
    setState(() {
      isFileAlreadyDownloadedresult = isFileAlreadyDownloaded;
    });
    if (isFileAlreadyDownloaded) {
      print('exist');
    }
  }

  @override
  build(BuildContext context) {
    // ignore: unused_local_variable
    final multiProvider = Provider.of<multiViewProvider>(context, listen: true);

    Widget? mywidget = SizedBox.shrink();
    bool isComponentSelected =
        (PaperDetailsSelectionPage.of(context)!.selectedComponent ==
            widget.component);
    debugPrint("${widget.pdf!.keyword!} & ${widget.pdf!.name}");
    final shapeDeco = ShapeDecoration(
      color: (isComponentSelected)
          ? Theme.of(context).iconTheme.color
          : Colors.transparent,
      shape: StadiumBorder(),
    );

    final textStyle = TextStyle(
      fontSize: 16.0,
      // fontSize: 12.0,
      fontWeight: FontWeight.w600,
      color: (isComponentSelected)
          ? Colors.blue
          : Theme.of(context).textTheme.bodyLarge!.color,
    );

    // if (type == 'QP') {
    //   if (pdf!.name!.contains('_qp_')) {
    mywidget = widget.pdf!.keyword == ''
        ? SizedBox.shrink()
        : SizedBox(
            height: 40.0,
            width: 100.0,
            child: RawMaterialButton(
              onPressed: () {
                Scrollable.ensureVisible(dataKey.currentContext!,
                    duration: Duration(seconds: 1));
                PaperDetailsSelectionPage.of(context)!.selectedComponent =
                    widget.component;
                PaperDetailsSelectionPage.of(context)!.selectedPdf = widget.pdf;
              },
              child: Card(
                elevation: isComponentSelected ? 2 : 4,
                shape: StadiumBorder(),
                child: Container(
                  decoration: shapeDeco,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          widget.pdf!.keyword!,
                          style: textStyle,
                        ),
                      ),
                      isFileAlreadyDownloadedresult
                          ? Icon(Icons.verified, color: Colors.green)
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          );

    return mywidget;
  }
}
