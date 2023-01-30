import 'package:flutter/material.dart';

class loadingProvider with ChangeNotifier {
  bool _loading = true;
  bool _showcaseDismiss = false;
  var _boardId = 'none';
  var _domainId = '2';
  get getboardId => _boardId;
  get getdomainId => _domainId;
  bool get loading => _loading;
  bool get showcaseDissmiss => _showcaseDismiss;
  void changeDomainid(id) {
    print('selected domain id $id');
    _domainId = id;
    notifyListeners();
  }

  void changeBoardId(id) {
    print('selected board id $id');
    _boardId = id;
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
