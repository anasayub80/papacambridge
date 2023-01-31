import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studento/pages/error_page.dart';
import 'package:studento/pages/inner_files_screen.dart';
import 'package:studento/pages/notes_page.dart';
import '../../services/navigate_observe.dart';

/// The route configuration.
class NotesRoute {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    observers: [
      BotToastNavigatorObserver(),
      NavigatorObserver(),
      AppNavigatorObserver(),
    ],
    routes: [
      GoRoute(
        name: 'notes',
        path: '/',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return MaterialPage(
            child: NotesPage(
                // domainId: state.params["id"]!,
                ),
          );
        },
      ),
      GoRoute(
        name: 'innerfile',
        path: '/:domainName/:boardName/:url',
        builder: (BuildContext context, GoRouterState state) {
          return innerfileScreen(
            url_structure: state.params["url"]!,
            boardName: state.params["boardName"],
            domainName: state.params["domainName"],
            title: 'title',
            iscomeFromMainFiles: true,
          );
        },
      ),
    ],
    redirect: (context, state) {},
    errorPageBuilder: (context, state) {
      return MaterialPage(child: ErrorPage());
    },
  );
}