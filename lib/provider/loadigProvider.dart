import 'package:flutter/material.dart';

class loadingProvider with ChangeNotifier {
  bool _loading = true;
  bool _showcaseDismiss = false;
  bool get loading => _loading;
  bool get showcaseDissmiss => _showcaseDismiss;
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
