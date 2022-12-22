import 'package:flutter/material.dart';

class loadingProvider with ChangeNotifier {
  bool _loading = true;
  bool get loading => _loading;
  void setLoadingFalse() {
    _loading = false;
    notifyListeners();
  }
}
