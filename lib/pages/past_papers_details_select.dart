// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:developer';
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
import 'package:studento/pages/home_page.dart';
import 'package:studento/pages/past_paper_view.dart';
import 'package:studento/model/MainFolderInit.dart';
import 'package:http/http.dart' as http;

enum Season { spring, summer, winter }

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

class _PaperDetailsSelectionPageState extends State<PaperDetailsSelectionPage> {
  int _currentStep = 0;
  set currentStep(int currentStep) =>
      setState(() => _currentStep = currentStep);
  int get currentStep => _currentStep;

  int? _selectedComponent;
  set selectedComponent(int? componentNo) =>
      setState(() => _selectedComponent = componentNo);
  int? get selectedComponent => _selectedComponent;
  PdfModal? _selectedPdf;
  set selectedPdf(PdfModal? pdf) => setState(() => _selectedPdf = pdf);
  PdfModal? get selectedPdf => _selectedPdf;
  int? _selectedYear;
  set selectedYear(int? year) => setState(() => _selectedYear = year);
  int? get selectedYear => _selectedYear;

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
  bool isLoading = true;
  List<Filtered> filtered = [];
  bool isLoaded = false;
  List<PdfModal> pdfModal = [];
  bool singleSelect = false;
  List<Step> steps() => <Step>[
        Step(
          title: Text("Year"),
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
          title: Text("Season"),
          content: SeasonStep(),
          isActive: (_currentStep == _seasonStepNo),
          state: getState(_seasonStepNo),
        ),
        // Step(
        //   title: Text("Component"),
        //   content: ComponentStep(widget.subject,session: selectedSeason,year: selectedYear,),
        //   isActive: (_currentStep == _componentStepNo),
        //   state: getState(_componentStepNo),
        // ),
      ];

  @override
  void initState() {
    getPapersData();
    super.initState();
    //([widget.subject.startYear, widget.subject.endYear]);
    // var userData = Hive.box<UserData>('userData').get(0);
    // // level = userData.level;
    // loadDisplayNames();
  }

  int median(List<int> a) {
    int middle = a.length ~/ 2;
    if (a.length % 2 == 1) {
      return a[middle];
    } else {
      return (a[middle - 1] + a[middle]) ~/ 2.0;
    }
  }

  bool loading = true;
  int? startDate;
  int? endDate;
  getPapersData() async {
    String url =
        'https://myaccount.papacambridge.com/api.php?main_folder=${widget.subject.parent}&id=${widget.subject.id}';
    log('Url $url');
    http.Response res = await http.get(Uri.parse(url));
    List<MainFolderInit> data = mainFolderInitFromJson(res.body);
    int _startDate = int.parse(data[0].year![0][0]);
    int _endDate = int.parse(data[data.length - 1].year![0][0]);
    setState(() {
      selectedYear = median([_startDate, _endDate]);
      startDate = _startDate;
      endDate = _endDate;
      loading = false;
    });
  }

  String? season;

  loadData(Season selectedSeason) async {
    setState(() {
      showPapers = true;
    });
    String url =
        'https://myaccount.papacambridge.com/api.php?main_folder=${widget.subject.parent}&id=${widget.subject.id}&year=$selectedYear';
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
      // String season = selectedSeason == Season.summer
      //     ? 'Summer'
      //     : Season.spring
      //         ? 'Spring'
      //         : 'Winter';
      print('My Season $season');
      int? id;
      for (var e in filteredL) {
        if (season == e.weather) {
          id = e.id;
        }
      }
      print('iddddddddddddddddddddddddd');
      String url1 =
          'https://myaccount.papacambridge.com/api.php?main_folder=${widget.subject.parent}&id=$id&year=skip';
      print(url1);
      http.Response res1 = await http.get(Uri.parse(url1));
      print(res1.body);

      List<PdfModal> pdfModalL = pdfModalFromJson(res1.body);
      setState(() {
        pdfModal = pdfModalL;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: StudentoAppBar(
          title: "Past Paper Details",
          context: context,
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: loading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
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
                    if (showPapers)
                      Container(
                          child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: 15.0, bottom: 30.0, left: 30, right: 30),
                            child: Text(
                              "Pick a number, any number... the component number!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          isLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  width: MediaQuery.of(context).size.width,
                                  child: Wrap(
                                      direction: Axis.horizontal,
                                      children: pdfModal
                                          .map((e) {
                                            int index = pdfModal.indexOf(e);
                                            if (!isLoading &&
                                                pdfModal.isEmpty) {
                                              return Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'No Past Paper Founds!',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1!
                                                        .copyWith(
                                                            color: Colors.grey),
                                                  ),
                                                ),
                                              );
                                            }
                                            // else {
                                            //   log('Get DATA');
                                            //   return Center(
                                            //     child: Padding(
                                            //       padding:
                                            //           const EdgeInsets.all(8.0),
                                            //       child: Text(
                                            //         'No Past Paper Founds!',
                                            //         style: Theme.of(context)
                                            //             .textTheme
                                            //             .bodyText1!
                                            //             .copyWith(
                                            //                 color: Colors.grey),
                                            //       ),
                                            //     ),
                                            //   );
                                            // }
                                            // // String weather = selectedSeason == Season.summer
                                            //     ? 'Summer'
                                            //     : 'Winter';
                                            // return Container(width: 100,height: 40,color: Colors.red,);
                                            else if (e.paper == 'QP') {
                                              log("Comg Widget Called!");
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ComponentWidget(index,
                                                    pdf: e),
                                              );
                                            } else {
                                              log("No Past paper Called!");
                                              return Container(
                                                width: 0,
                                                height: 0,
                                              );
                                              // return Center(
                                              //   child: Text(
                                              //     'No Past Paper Founds!',
                                              //     style: Theme.of(context)
                                              //         .textTheme
                                              //         .bodyText1!
                                              //         .copyWith(
                                              //             color: Colors.grey),
                                              //   ),
                                              // );
                                            }
                                          })
                                          .toList()
                                          .cast<Widget>()),
                                ),
                          // GridView.builder(
                          //     itemCount: filtered.length,
                          //     physics: NeverScrollableScrollPhysics(),
                          //     padding: EdgeInsets.symmetric(vertical: 30.0),
                          //     gridDelegate:
                          //         SliverGridDelegateWithFixedCrossAxisCount(
                          //       childAspectRatio: 2.5,
                          //       crossAxisCount: 3,
                          //       mainAxisSpacing: 10.0,
                          //     ),
                          //     shrinkWrap: true,
                          //     itemBuilder: (_, i) {
                          //       String weather=selectedSeason==Season.summer?'Summer':'Winter';
                          //       if(filtered[i].weather==weather)return ComponentWidget(i);
                          // //  return ComponentWidget(i);
                          // return Container();

                          //     },
                          //   ),
                          if (selectedPdf != null)
                            InkWell(
                                onTap: () {
                                  // print(selectedComponent);
                                  // Filtered item =
                                  //     filtered.elementAt(selectedComponent);
                                  // print(item.id);
                                  // return;
                                  openPaper(selectedPdf!);
                                },
                                child: Container(
                                  height: 50,
                                  width: 100,
                                  margin: EdgeInsets.only(
                                      top: 25, bottom: 25, left: 40),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      boxShadow: [
                                        BoxShadow(color: Colors.grey)
                                      ],
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Show',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 12,
                                      )
                                    ],
                                  ),
                                ))
                        ],
                      ))
                  ],
                ),
              ));
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
    else if (isAllDetailsSelected)
      loadData(_selectedSeason!);
    // openPaper();
    else {
      if (_selectedSeason == null) changeStep(_seasonStepNo);
      // else if (_selectedComponent == null) changeStep(_componentStepNo);

      if (_selectedSeason == null) {
        _scaffoldKey.currentState!.showSnackBar(
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
    String fileName = "${code}_$seasonChar${twoDigitYear}_qp_$componentStr.pdf";
    return fileName;
  }

  String generateMainUrl(MainFolder subject) {
    return subject.urlPdf!;
    // String subjectLabel = subject.name
    //     .replaceFirst(" Language", " - Language")
    //     .replaceFirst("(AS)", " (AS Level only)")
    //     .replaceFirst("(A Level)", " (A Level only)")
    //     .replaceFirst("&", "and");
    // switch (subject.folderCode) {
    //   case '8281':
    //     subjectLabel = subjectLabel.replaceFirst(
    //         "Japanese - Language", "Japanese Language");
    //     break;

    //   case '3248':
    //     subjectLabel =
    //         subjectLabel.replaceFirst("Second - Language", "Second Language");
    //     break;

    //   case '8291':
    //     subjectLabel =
    //         subjectLabel.replaceFirst("(AS Level only)", "(AS only)");
    //     break;

    //   case '8058':
    //     subjectLabel = subjectLabel.replaceFirst("Level", "level");
    //     break;

    //   case '9686':
    //     subjectLabel = subjectLabel.replaceFirst("Pakistan", "Pakistan only");
    //     break;

    //   case '4037':
    //     subjectLabel = subjectLabel.replaceFirst(
    //         "Additional Mathematics", "Mathematics - Additional");
    //     break;

    //   default:
    //     if (subject.folderCode == '9479' || subject.folderCode == '9483')
    //       subjectLabel = subjectLabel.replaceAll("(New)", '');

    //     if (subject.folderCode == '8665' || subject.folderCode == '3247')
    //       subjectLabel =
    //           subjectLabel.replaceFirst("First - Language", "First Language");
    // }

    // var serverDir = "https://papers.xtremepape.rs/CAIE";
    // var levelStr = level == Level.O ? "O Level" : "AS and A Level";
    // var subjectDir = "$subjectLabel (${subject.folderCode})";

    // var url = "$serverDir/$levelStr/$subjectDir/$fileName";
    // return Uri.encodeFull(url);
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
  void openPaper(PdfModal id) async {
    List<String> moreUrls = [];
    print(id.urlPdf);
    moreUrls.add(id.urlPdf!);
// return;
    // pdfModal.forEach((e) => moreUrls.add(e.urlPdf));
    //
    // widget.subject.urlPdf;

    /// Extra URLs for components with inconsistent naming, e.g qp_02
    // if (selectedComponent < 10) {
    //   moreUrls = [
    //     generateMainUrl(widget.subject),
    //     generateMirror1Url(),
    //     generateMirror2Url()
    //   ]
    //     ..retainWhere((element) => element != null)
    //     ..map(
    //       (s) => s.replaceFirst(
    //         'qp_$componentStr',
    //         "qp_$selectedComponent",
    //       ),
    //     ).toList();
    // }
    print('kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk');
    print(moreUrls);
    print('lllllllllllllllllllllllllllllllllllllll');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PastPaperView(
          [
            // generateMainUrl(widget.subject),
            // generateMirror1Url(),
            // generateMirror2Url(),
            ...moreUrls,
          ], //..retainWhere((url) => url != null),
          fileName,
          boardId,
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
          style: TextStyle(color: Colors.white),
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

class ComponentWidget extends StatelessWidget {
  final PdfModal? pdf;

  const ComponentWidget(this.component, {this.pdf});
  final int component;

  @override
  Widget build(BuildContext context) {
    bool isComponentSelected =
        (PaperDetailsSelectionPage.of(context)!.selectedComponent == component);

    final shapeDeco = ShapeDecoration(
      color: (isComponentSelected)
          ? Theme.of(context).iconTheme.color
          : Colors.transparent,
      shape: StadiumBorder(),
    );

    final textStyle = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: (isComponentSelected)
          ? Colors.blue
          : Theme.of(context).textTheme.bodyText1!.color,
    );

    return SizedBox(
      height: 40.0,
      width: 100.0,
      child: InkWell(
        onTap: () {
          // var route=MaterialPageRoute(builder: (context)=>PdfDemo());

          PaperDetailsSelectionPage.of(context)!.selectedComponent = component;
          PaperDetailsSelectionPage.of(context)!.selectedPdf = pdf;
        },
        child: Card(
          elevation: isComponentSelected ? 2 : 4,
          shape: StadiumBorder(),
          child: Container(
            decoration: shapeDeco,
            child: Center(
              child: Text(
                pdf!.keyword!,
                style: textStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
