import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studento/pages/ebook_page.dart';
import 'package:studento/pages/error_page.dart';
import 'package:studento/pages/inner_files_screen.dart';
import 'package:studento/pages/notes_page.dart';
import 'package:studento/pages/otherres_page.dart';
import 'package:studento/pages/syllabus.dart';
import 'package:studento/pages/timetable_page.dart';

import '../../pages/home_page.dart';
import '../../pages/past_papers.dart';
import '../../pages/setup.dart';
import '../../pages/splash_page.dart';
import '../../services/navigate_observe.dart';

/// The route configuration.
class MyGoRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    observers: [
      BotToastNavigatorObserver(),
      NavigatorObserver(),
      AppNavigatorObserver(),
    ],
    routes: [
      // GoRoute(
      //   name: 'splash',
      //   path: '/',
      //   builder: (BuildContext context, GoRouterState state) {
      //     return SplashPage();
      //   },
      // ),
      GoRoute(
        name: 'home',
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return HomePage();
        },
      ),
      // GoRoute(
      //   name: 'setup',
      //   path: '/setup',
      //   builder: (BuildContext context, GoRouterState state) {
      //     return Setup();
      //   },
      // ),
      GoRoute(
        name: 'pastpapers',
        path: '/pastpapers/:id',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return MaterialPage(
            child: PastPapersPage(
              domainId: state.params["id"]!,
            ),
          );
        },
      ),
      GoRoute(
        name: 'notes',
        path: '/notes/:id',
        builder: (BuildContext context, GoRouterState state) {
          return NotesPage(
            domainId: state.params["id"]!,
          );
        },
      ),
      GoRoute(
        name: 'syllabus',
        path: '/syllabus/:id',
        builder: (BuildContext context, GoRouterState state) {
          return SyllabusPage(
            domainId: state.params["id"]!,
          );
        },
      ),
      GoRoute(
        name: 'e-books',
        path: '/e-books/:id',
        builder: (BuildContext context, GoRouterState state) {
          return EBooksPage(
            domainId: state.params["id"]!,
          );
        },
      ),
      GoRoute(
        name: 'others',
        path: '/others/:id',
        builder: (BuildContext context, GoRouterState state) {
          return OtherResources(
            domainId: state.params["id"]!,
          );
        },
      ),
      GoRoute(
        name: 'timetables',
        path: '/timetables/:id',
        builder: (BuildContext context, GoRouterState state) {
          return TimeTablePage(
            domainId: state.params["id"]!,
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
