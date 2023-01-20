import 'package:flutter/material.dart';

class multiViewProvider with ChangeNotifier {
  bool _multiView = false;
  bool get multiView => _multiView;
  void setMultiViewTrue() {
    _multiView = true;
    print('multiView true');
    notifyListeners();
  }

  void setMultiViewFalse() {
    _multiView = false;
    print('multiView false');
    notifyListeners();
  }
}
