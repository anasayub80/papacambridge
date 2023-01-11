import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studento/UI/rate_dialog.dart';
import 'package:studento/UI/studento_drawer.dart';
import 'package:studento/pages/notes_page.dart';
import 'package:studento/pages/otherres_page.dart';
import 'package:studento/pages/schedule.dart';
import 'package:studento/pages/timetable_page.dart';
import 'package:studento/pages/todo_list.dart';
import 'package:studento/utils/theme_provider.dart';
import 'package:provider/provider.dart';

import '../CAIE/syllabusPage.dart';
import '../UI/customDelgate.dart';
import '../services/backend.dart';
import 'ebook_page.dart';
import 'past_papers.dart';
import 'syllabus.dart';

var boardId;

class HomePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage> {
  @override
  void afterFirstLayout(BuildContext context) {
    bool isLuckyDay = decideWhetherToShowRatingDialog();
    if (isLuckyDay) showRatingDialog();
  }

  StreamController _domainStream = StreamController();

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getDomains();
  }

  getDomains() async {
    final prefs = await SharedPreferences.getInstance();
    boardId = prefs.getString('board')!;
    var res = await backEnd().fetchDomains(boardId);
    debugPrint(res.toString());
    _domainStream.add(res);
  }

  // ignore: todo
  // TODO Store in Shared prefs if user has rated the app.
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSettings>(context, listen: false);

    return Scaffold(
      drawer: studentoDrawer(),
      appBar: AppBar(
        title:
            // Text(
            //   'Papa Cambridge',
            //   style: TextStyle(
            //     color: Theme.of(context).textTheme.bodyText1!.color,
            //   ),
            // ),
            Padding(
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
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        // titleStyle: TextStyle(
        //   fontSize: 25,
        //   fontWeight: FontWeight.w400,
        //   color: Theme.of(context).textTheme.bodyText1!.color,
        // ),
      ),
      backgroundColor: Theme.of(context).cardColor,
      body: StreamBuilder<dynamic>(
        // future: backEnd().fetchDomains(boardId),
        stream: _domainStream.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List snap = snapshot.data;
            if (!updated) {
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
                crossAxisCount: 2,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
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
        },
      ),
    );
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
    buttonsContainer() => SizedBox(
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
        onTap: () => widget.domainId == ''
            ? pushsimpleRoutes(context)
            : pushRoute(context, widget.label, widget.domainId),
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
        if (boardId != '1') {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return PastPapersPage(domainId: domaindId);
            },
          ));
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
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return SyllabusPage(domainId: domaindId);
          },
        ));
        // } else {
        //   Navigator.push(context, MaterialPageRoute(
        //     builder: (context) {
        //       return SyllabusPageCAIE();
        //     },
        //   ));
        // }
        break;

      case 'E Books':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return EBooksPage(domainId: domaindId);
          },
        ));
        break;
      case 'Notes':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return NotesPage(domainId: domaindId);
          },
        ));
        break;
      case 'Others':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return OtherResources(domainId: domaindId);
          },
        ));
        break;
      case 'Timetables':
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
