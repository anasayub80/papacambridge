import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:studento/model/user_data.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:studento/pages/home_page.dart';
import 'package:studento/pages/splash_page.dart';
import '../UI/setup_page.dart';
import '../UI/subjects_list_select.dart';
import '../UI/show_message_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studento/Globals.dart' as globals;

import '../services/backend.dart';

List level = [];
List levelid = [];

class Setup extends StatefulWidget {
  final bool isEditingSideMenu;
  final bool isEditingSettings;
  const Setup(
      {Key? key,
      this.isEditingSettings = false,
      this.isEditingSideMenu = false})
      : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _SetupState createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  /// Error text that appears under the name [TextField] when there are issues.
  late String errorText;

  /// pageIndex to get, set, and track current [SetupPage] being
  /// shown from [setupPages] List.
  int pageIndex = 0;
  bool dataUpdated = false;

  hiveOpen() {
    if (!kIsWeb) UserData? userData = Hive.box<UserData>('userData').get(0);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hiveOpen();
  }

  @override
  Widget build(BuildContext context) {
    return setupPages()[pageIndex];
  }

  /// Returns the list of setupPages.
  List setupPages() {
    return [
      SetupPage(
        leadIcon: Icons.poll,
        caption: "Choose Your Board",
        body: _buildboardsBody(),
        onFloatingButtonPressed: validateAndPushBoardPage,
        issubject: false,
      ),
      SetupPage(
        leadIcon: Icons.poll,
        caption: "Which CAIE syllabus are you taking part in?",
        body: selectedboardid == null
            ? SizedBox()
            : _buildInfoBody(
                selectedboardid,
              ),
        onFloatingButtonPressed: validateAndPushSubjectsPage,
        issubject: true,
      ),
      if (!kIsWeb)
        SetupPage(
          leadIcon: Icons.lock,
          caption: "We need these permissions to be able to assist you:",
          issubject: false,
          body: _buildPermissionsBody(),
          onFloatingButtonPressed: () async {
            await requestPermissions();

            pushHomePage();
          },
        )
      else
        SetupPage(
          leadIcon: Icons.celebration,
          caption: "Let's Start Your Journey With PapaCambridge:",
          issubject: false,
          body: _buildWeb(),
          onFloatingButtonPressed: () {
            pushHomePage();
          },
        )
    ];
  }

  List<String> selected = [];

  void updateChosenLevel(bool isSelected, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (selectedItem.contains(level[index]) &
          selectedlevelid.contains(levelid[index])) {
        selectedItem.remove(level[index]);
        selectedlevelid.remove(levelid[index]);
        // globals.selectedG.remove(level[index]);
        selected.remove(level[index].toString());
      } else {
        selectedItem.add(level[index]);
        selectedlevelid.add(levelid[index]);
        // globals.selectedG.add(level[index]);
        selected.add(level[index].toString());
      }
      prefs.setStringList('level', selectedItem);
      prefs.setStringList('levelid', selectedlevelid);
    });
    Future.delayed(
      Duration(seconds: 3),
      () {
        BotToast.closeAllLoading();
        log("Bot Remove");
      },
    );
  }

  void removeChosenLevel(bool isSelected, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (selectedItem.contains(level[index])) {
        selectedItem.remove(level[index]);
        // globals.selectedG.remove(level[index]);
        selected.remove(level[index].toString());
      }
      prefs.setStringList('level', selectedItem);
      prefs.setStringList('levelid', selectedlevelid);
    });
    Future.delayed(
      Duration(seconds: 3),
      () {
        BotToast.closeAllLoading();
        log("Bot Remove");
      },
    );
  }

  @override
  void dispose() {
    levelid = [];
    level = [];
    selectedboardid = null;
    selectedboard = null;
    selectedItem = [];
    selectedlevelid = [];
    // ignore: todo
    // TODO: implement dispose
    super.dispose();
  }

  String? selectedboardid;
  var selectedboard;
  List<String> selectedItem = [];
  List<String> selectedlevelid = [];
  List<String> levelid = [];
  Level? levelG;
  getLevel(boardId) async {
    var res = await backEnd().fetchMainFiles(boardId);
    // ignore: unused_local_variable
    var resp = res.toString().replaceAll("\n", "");
    debugPrint("checking response ${res.toString()}");
    if (dataUpdated == false) {
      for (var i = 0; i < res.length; i++) {
        level.add(res[i]['name'].replaceAll("\n", ""));
        levelid.add(res[i]['id'].replaceAll("\n", ""));
        log(res[i]['name'].replaceAll("\n", ""));
      }
      dataUpdated = true;
    }
    _levelController.add(res);
  }

  StreamController _levelController = BehaviorSubject();
  StreamController _boardController = BehaviorSubject();
  _buildInfoBody(boardId) {
    // save from auto refresh data in setState
    getLevel(boardId);
    return StreamBuilder<dynamic>(
        // get Data for CAIE
        // future: backEnd().fetchMainFiles(boardId),
        stream: _levelController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
                padding: EdgeInsets.only(bottom: 50),
                // itemCount: level.length,
                itemCount: snapshot.data.length,
                itemBuilder: (_, int index) {
                  return CheckboxListTile(
                      activeColor: Colors.blue,
                      value: selectedItem.contains(level[index]),
                      selected: selectedItem.contains(level[index]),
                      title: Text(
                        level[index].toString(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      // secondary: Text(subjectCode),
                      onChanged: (bool? isSelected) async {
                        // bool res = await pushSubjectsPage();
                        bool res =
                            await Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return SubjectsList(
                              levelid: levelid[index],
                              name: level[index],
                              onFloatingButtonPressed2: () {
                                List subjects = globals.selectedG;
                                bool isChosenListValid = subjects.isNotEmpty;
                                if (isChosenListValid) {
                                  BotToast.showLoading();
                                  log("Bot Call");
                                  Navigator.pop(context, true);
                                } else {
                                  showMessageDialog(
                                    context,
                                    title: "Insufficient subjects",
                                    msg:
                                        "You need to select at least 1 or more subjects",
                                  );
                                }
                              },
                            );
                          },
                        ));
                        if (res) {
                          updateChosenLevel(
                            isSelected!,
                            index,
                          );
                        } else {
                          removeChosenLevel(
                            false,
                            index,
                          );
                        }
                      });
                });
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  getBoard() async {
    var res = await backEnd().fetchBoard();
    _boardController.add(res);
  }

  _buildboardsBody() {
    getBoard();
    Widget buildLevelRadioListTile(board, id) => RadioListTile(
          title: Text(board.toString()),
          value: board,
          groupValue: selectedboard,
          selected: false,
          onChanged: (board) async {
            log("selected board is $board & $id");
            setState(() {
              selectedboard = board;
              selectedboardid = id;
              log('my board is $selectedboard');
              // userData
              //   ..level = _level
              //   ..save();
            });
          },
        );

    return mobileBody(buildLevelRadioListTile);
  }

  StreamBuilder<dynamic> mobileBody(
      Widget Function(dynamic board, dynamic id) buildLevelRadioListTile) {
    return StreamBuilder<dynamic>(
      // future: backEnd().fetchBoard(),
      stream: _boardController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            padding: EdgeInsets.all(0),
            itemBuilder: (context, index) {
              return buildLevelRadioListTile(
                  snapshot.data[index]['name'], snapshot.data[index]['id']);
              // return Text(snapshot.data[index]['name']);
            },
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildPermissionsBody() {
    return Column(children: <Widget>[
      ListTile(
        isThreeLine: true,
        leading: Icon(Icons.storage),
        title: Text("Storage"),
        subtitle: Column(children: <Widget>[
          SizedBox(height: 5),
          Text(
            "For storing past papers, icons and more",
            textScaleFactor: 0.9,
            style: TextStyle(),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildWeb() {
    return Column(children: <Widget>[
      ListTile(
        isThreeLine: true,
        leading: Icon(Icons.book),
        title: Text("Past Papers"),
        subtitle: Column(children: <Widget>[
          SizedBox(height: 5),
          Text(
            "Access past papers anytime, anywhere, just a couple taps away.",
            textScaleFactor: 0.9,
            style: TextStyle(),
          ),
        ]),
      ),
    ]);
  }

  void validateAndPushSubjectsPage() {
    if (selected.isNotEmpty) {
      // pushSubjectsPage();
      validateAndCheckPermissions();
    } else {
      Flushbar(
        messageText: Text(
          "Please select level!",
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.red[400]!,
        duration: Duration(seconds: 3),
      ).show(context);
    }
  }

  void validateAndCheckPermissions() {
    List subjects = globals.selectedG;
    var isChosenListValid = subjects.isNotEmpty;

    if (isChosenListValid) {
      if (widget.isEditingSideMenu) {
        returnToHomePage();
      } else if (widget.isEditingSettings) {
        returnToSettingsPage();
      } else {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        deviceInfo.androidInfo.then((androidInfo) {
          // ignore: no_leading_underscores_for_local_identifiers
          bool _isAndroidVersion6OrHigher = androidInfo.version.sdkInt >= 23;

          if (_isAndroidVersion6OrHigher) // must request permission for these.
            pushPermissionsPage();
          else
            pushHomePage();
        });
      }
    } else {
      showMessageDialog(
        context,
        title: "Insufficient subjects",
        msg: "You need to select at least 1 or more subjects",
      );
    }
  }

  void returnToHomePage() {
    // Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return SplashPage();
      },
    ));

    Flushbar(
      message: "Your subjects and level have been updated!",
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ).show(context);
  }

  void returnToSettingsPage() {
    Navigator.popUntil(context, ModalRoute.withName("settings_page"));
    Flushbar(
      message: "Your subjects and level have been updated!",
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ).show(context);
  }

  /// If Android version is Marshmello or above, we need to request permissions
  /// first, then we push the HomePage.
  Future<void> requestPermissions() async {
    // Map<Permission, PermissionStatus> permissions;
    // permissions =
    //     await Permission([PermissionGroup.storage]);
// You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    PermissionStatus? result = statuses[Permission.storage];

    print("$result");
  }

  void validateAndPushBoardPage() async {
    if (selectedboard != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('board', selectedboardid!);
      pushBoardPage();
    } else {
      Flushbar(
        messageText: Text(
          "Please Select Board !",
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.red[400]!,
        duration: Duration(seconds: 3),
      ).show(context);
    }
  }

  // pushSubjectsPage() => pushNextPage(1);
  // void pushPermissionsPage() => pushNextPage(1);
  void pushBoardPage() => pushNextPage(selectedboardid != '1' ? 2 : 1);
  // void pushSubjectsPage() => pushNextPage(2);
  void pushPermissionsPage() => pushNextPage(selectedboardid != '1' ? 1 : 2);
  void pushHomePage() async {
    levelid = [];
    level = [];
    selectedboardid = null;
    selectedboard = null;
    selectedItem = [];
    selectedlevelid = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('setup', true);
    if (kIsWeb) {
      // ignore: use_build_context_synchronously
      GoRouter.of(context).pushNamed('home');
    } else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).popUntil((route) => route.isFirst);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ));
    }
  }

  /// Pushes the [SetupPage] which is found at [pageIndex] in the [List]
  /// returned by [setupPages()]
  pushNextPage(int pageIndex) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => setupPages()[pageIndex]),
      );
}
