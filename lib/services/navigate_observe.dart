import 'dart:developer';

import 'package:flutter/material.dart';

List<Route> routeStack = [];

class AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route? route, Route? previousRoute) {
    super.didPush(route!, previousRoute);
    log('push');
    routeStack.add(route);
  }

  @override
  void didPop(Route? route, Route? previousRoute) {
    super.didPop(route!, previousRoute);
    log('pop');
    routeStack.remove(route);
  }

  @override
  void didRemove(Route? route, Route? previousRoute) {
    super.didRemove(route!, previousRoute);
    log('remove');
    routeStack.remove(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final index = routeStack.indexOf(oldRoute!);
    log('replace');
    routeStack[index] = newRoute!;
  }
}
