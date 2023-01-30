import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seo_renderer/renderers/text_renderer/text_renderer_style.dart';
import 'package:seo_renderer/renderers/text_renderer/text_renderer_vm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studento/Globals.dart';
import 'package:studento/UI/rate_dialog.dart';
import 'package:studento/UI/studento_drawer.dart';
import 'package:studento/pages/notes_page.dart';
import 'package:studento/pages/otherres_page.dart';
import 'package:studento/pages/schedule.dart';
import 'package:studento/pages/timetable_page.dart';
import 'package:studento/pages/todo_list.dart';
import 'package:studento/provider/loadigProvider.dart';
import 'package:studento/responsive/responsive_layout.dart';
import 'package:studento/utils/funHelper.dart';
import 'package:studento/utils/sideAdsWidget.dart';
import 'package:studento/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../UI/customDelgate.dart';
import '../UI/web_appbar.dart';
import '../responsive/dimensions.dart';
import '../services/backend.dart';
import '../utils/pdf_helper.dart';
import 'ebook_page.dart';
import 'past_papers.dart';
import 'syllabus.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  // static final beamLocation = BeamPage(page: HomePage(), key: ValueKey('home'));
  // static final path = '/';
  static const ishomelaunch = "ishomeshowcaselaunch";
  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage> {
  @override
  void afterFirstLayout(BuildContext context) {
    if (!kIsWeb) {
      bool isLuckyDay = decideWhetherToShowRatingDialog();
      if (isLuckyDay) showRatingDialog();
    }
  }

  StreamController _domainStream = BehaviorSubject();

  @override
  void initState() {
    // Future.delayed(
    //   Duration.zero,
    //   () {},
    // );
    super.initState();
    getDomains();
  }

  getDomains() async {
    print(
        'get Domain Call DomainsData${Provider.of<loadingProvider>(context, listen: false).getboardId}');
    final prefs = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    Provider.of<loadingProvider>(context, listen: false)
        .changeBoardId(prefs.getString('board')!);
    var isConnected = await PdfHelper.checkIfConnected();
    if (isConnected) {
      var res = await funHelper().checkifDataExist(
          // ignore: use_build_context_synchronously
          'DomainsData${Provider.of<loadingProvider>(context, listen: false).getboardId}');
      if (res != null) {
        var myres = await backEnd().fetchDomains(
            // ignore: use_build_context_synchronously
            Provider.of<loadingProvider>(context, listen: false).getboardId);
        if (myres.length <= res.length) {
          print('equal');
          _domainStream.add(res);
        } else {
          print('not equal update');
          prefs.remove('DomainsData');
        }
      } else {
        var res = await backEnd()
            // ignore: use_build_context_synchronously
            .fetchDomains(Provider.of<loadingProvider>(context, listen: false)
                .getboardId);
        var response = jsonEncode(res);
        await prefs.setString('DomainsData', response);
        debugPrint(res.toString());
        _domainStream.add(res);
      }
    } else {
      var res = await funHelper().checkifDataExist(
          // ignore: use_build_context_synchronously
          'DomainsData${Provider.of<loadingProvider>(context, listen: false).getboardId}');
      if (res != null) {
        _domainStream.add(res);
      } else {
        _domainStream.add('NetworkError');
      }
    }
  }

  bool decideWhetherToShowRatingDialog() {
    var randomObj = Random();
    int luckyNum = 10;
    int randomNum = randomObj.nextInt(12);
    if (randomNum == luckyNum) return true;
    return false;
  }

  void showRatingDialog() {
    showDialog(
      context: context,
      builder: (_) => RateDialog(),
    );
  }

// Use for stop snapshot list from updating
  bool updated = false;
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSettings>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _key, // Assign the key to Scaffold.

      drawer: studentoDrawer(),
      appBar: (kIsWeb && size.width >= mobileWidth)
          ? webAppBar(themeProvider, context)
          : AppBar(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  themeProvider.currentTheme == ThemeMode.light
                      ? 'assets/icons/logo.png'
                      : 'assets/icons/Darklogo.png',
                  height: 50,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
              leading: IconButton(
                  onPressed: () {
                    _key.currentState!.openDrawer();
                  },
                  icon: Icon(
                    Icons.menu,
                  )),
              iconTheme: Theme.of(context).iconTheme,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ResponsiveLayout(
        mobileBody: mobileBody(),
        webBody: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              child: mobileBody(),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: ListView(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Card(
                      child: ClipPath(
                        child: Container(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/launcher-icon.png',
                                  height: 75,
                                  width: 75,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                    'Download PapaCambridge App From PlayStore'),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          'https://play.google.com/store/apps/details?id=com.MaskyS.papaCambridge'));
                                    },
                                    child: Text('Download from Play Store'))
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: secColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        clipper: ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      color: Theme.of(context).cardColor,
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide.none,
                      ),
                    ),
                    height: 300,
                    width: 250,
                  ),
                  SizedBox(
                      // height: 500,
                      width: 400,
                      height: 500,
                      child: sideAdsWidget())
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<dynamic> mobileBody() {
    return StreamBuilder<dynamic>(
        // future: backEnd().fetchDomains(boardId),
        stream: _domainStream.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.data == 'NetworkError') {
                return Text('No Internet Connection');
              } else if (snapshot.data == null) {
                return Center(
                  child: Text(
                    'No Data Found',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                );
              } else if (snapshot.hasData) {
                List snap = snapshot.data;
                print("*****$snap**** ${snapshot.data}");
                if (!updated && !kIsWeb) {
                  // Merging Static data with api requested data
                  snap.addAll([
                    {'id': 'static', 'domain': 'Schedule'},
                    {'id': 'static', 'domain': 'Todo List'},
                  ]);
                  updated = true;
                }
                return GridView.builder(
                  // physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    crossAxisCount:
                        2, // HERE YOU CAN ADD THE NO OF ITEMS PER LINE
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                    height: kIsWeb
                        ? (MediaQuery.of(context).size.width < mobileWidth)
                            ? 200
                            : 250
                        : 175.0,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HomePageButton(
                        label: snap[index]['domain'],
                        iconFileName: returnfileName(snap[index]['domain']),
                        routeToBePushedWhenTapped: 'ignorethisline',
                        domainId: snap[index]['id'],
                      ),
                    );
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
          }
        });
  }

  String returnfileName(name) {
    var asset;
    switch (name.trim()) {
      case 'Past Papers':
        asset = 'exam.png';
        break;
      case 'E Books':
        asset = 'e-book.png';
        break;
      case 'Syllabus':
        asset = 'syllabus.png';
        break;
      case 'Notes':
        asset = 'notes.png';
        break;
      case 'Others':
        asset = 'descriptor.png';
        break;
      case 'Timetables':
        asset = 'time-table.png';
        break;
      case 'Schedule':
        asset = 'schedule.png';
        break;
      case 'Todo List':
        asset = 'todo-list.png';
        break;
      default:
        asset = 'logo.png';
    }

    return asset;
  }
}

class HomePageButton extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _HomePageButtonState createState() => _HomePageButtonState();

  const HomePageButton({
    required this.domainId,
    required this.label,
    required this.iconFileName,
    required this.routeToBePushedWhenTapped,
  });

  final String label;

  final String iconFileName;
  final String domainId;

  final String routeToBePushedWhenTapped;
}

class _HomePageButtonState extends State<HomePageButton> {
  Widget icon() => Image.asset(
        "assets/icons/${widget.iconFileName}",
        height: 75,
        width: 75,
        fit: BoxFit.fill,
      );

  @override
  Widget build(BuildContext context) {
    debugPrint('**my domain id is ${widget.domainId}**');
    final TextStyle labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).textTheme.bodyText1!.color,
    );

    Widget labelText() => Text(
          widget.label,
          textScaleFactor: 1.2,
          style: labelStyle,
          textAlign: TextAlign.center,
        );
    buttonsContainer() => Container(
          constraints: BoxConstraints(
            maxWidth: 20.0,
          ),
          child: Card(
            child: ClipPath(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(),
                    icon(),
                    labelText(),
                  ],
                ),
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(20),
                  border: Border(
                    right: BorderSide(
                      color: secColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            color: Theme.of(context).cardColor,
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide.none,
            ),
          ),
          height: 200,
        );

    return Tooltip(
      verticalOffset: 5.0,
      message: widget.label,
      child: InkWell(
        onTap: () {
          widget.domainId == ''
              ? pushsimpleRoutes(context)
              : pushRoute(context, widget.label, widget.domainId);
        },
        child: buttonsContainer(),
      ),
    );
  }

  void pushsimpleRoutes(BuildContext context) {
    Navigator.of(context).pushNamed(widget.routeToBePushedWhenTapped);
  }

  void pushRoute(BuildContext context, String domainName, var domaindId) {
    // Navigator.of(context).pushNamed(widget.routeToBePushedWhenTapped);
    debugPrint(domainName.toString());
    switch (domainName.trim()) {
      case 'Past Papers':
        if (Provider.of<loadingProvider>(context, listen: false).getboardId !=
            '1') {
          if (kIsWeb) {
            GoRouter.of(context)
                .pushNamed('pastpapers', params: {'id': widget.domainId});
          } else {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return PastPapersPage(
                  domainId: domaindId,
                );
              },
            ));
          }
        } else {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return PastPapersPageCAIE();
            },
          ));
        }
        break;
      case 'Syllabus':
        // if (boardId != '1') {
        if (kIsWeb) {
          GoRouter.of(context)
              .pushNamed('syllabus', params: {'id': widget.domainId});
        } else {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return SyllabusPage(domainId: domaindId);
            },
          ));
        }
        break;

      case 'E Books':
        if (kIsWeb) {
          GoRouter.of(context)
              .pushNamed('e-books', params: {'id': widget.domainId});
        } else
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return EBooksPage(domainId: domaindId);
            },
          ));
        break;
      case 'Notes':
        if (kIsWeb) {
          GoRouter.of(context)
              .pushNamed('notes', params: {'id': widget.domainId});
        } else {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return NotesPage(domainId: domaindId);
            },
          ));
        }
        break;
      case 'Others':
        if (kIsWeb)
          GoRouter.of(context)
              .pushNamed('others', params: {'id': widget.domainId});
        else
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return OtherResources(domainId: domaindId);
            },
          ));
        break;
      case 'Timetables':
        if (kIsWeb)
          GoRouter.of(context)
              .pushNamed('timetables', params: {'id': widget.domainId});
        else
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return TimeTablePage(domainId: domaindId);
            },
          ));
        break;
      case 'Schedule':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return SchedulePage();
          },
        ));
        break;
      case 'Todo List':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return TodoListPage();
          },
        ));
        break;
      default:
        debugPrint('Something Wrong');
        break;
    }
  }
}
