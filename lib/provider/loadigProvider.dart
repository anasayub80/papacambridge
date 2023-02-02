import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class loadingProvider with ChangeNotifier {
  bool _loading = true;
  bool _showcaseDismiss = false;
  var _boardId = 'none';
  String selectedboard = 'none';
  get getselectedboard => selectedboard;

  var _domainId = 'none';
  get getboardId => _boardId;
  get getdomainId => _domainId;
  bool get loading => _loading;
  bool get showcaseDissmiss => _showcaseDismiss;
  void changeDomainid(id) {
    print('change domain id $id');
    _domainId = id;
    notifyListeners();
  }

  // Future<bool> getSaveBoard() async {
  //   debugPrint('get saved data');
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   _boardId = prefs.getString('board') ?? 'none';
  //   selectedboard = prefs.getString('boardName') ?? 'none';
  //   if (_boardId == 'none') {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  Future getLocalStorage() async {
    _boardId = html.window.localStorage['boardId'] ?? 'none';
    selectedboard = html.window.localStorage['boardName'] ?? 'none';
    print('get local storage $_boardId & $selectedboard');
    notifyListeners();
  }

  Future saveBoard(String id, name, bool isAppBar) async {
    html.window.localStorage['boardId'] = id;
    html.window.localStorage['boardName'] = name;
    _boardId = id;
    selectedboard = name;
    if (isAppBar) {
      html.window.location.reload();
    }
  }

  void changeBoardId(id, String? name, bool isAppBar) async {
    print('selected board id $id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('boardName', name!);
    prefs.setString('board', id!);
    _boardId = id;
    selectedboard = name;
    notifyListeners();
  }

  void setLoadingFalse() {
    _loading = false;
    notifyListeners();
  }

  void setshowCasedismiss() {
    _showcaseDismiss = true;
    print('**dismiss**');
    notifyListeners();
  }
}
