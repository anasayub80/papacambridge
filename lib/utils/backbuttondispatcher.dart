import 'package:flutter/material.dart';

class backButtonDispatcher extends RootBackButtonDispatcher {
  final RouterDelegate _routerDelegate;
  final _settings;

  backButtonDispatcher(this._routerDelegate, this._settings) : super();

  @override
  Future<bool> didPopRoute() async {
    //Can user leave the page?
    if (!_settings.canLeavePage) {
      //no, as the webview widget has flagged canLeavePage as false
      _settings.goBackToPreviousWebsite();
      return true;
    } else {
      //yes, perform standard popRoute call
      return _routerDelegate.popRoute();
    }
  }
}
