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
import '../pages/home_page.dart';
import '../pages/past_papers.dart';
import '../pages/splash_page.dart';
import '../services/navigate_observe.dart';

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
      GoRoute(
        name: 'splash',
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return SplashPage();
        },
      ),
      GoRoute(
        name: 'home',
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return HomePage();
        },
      ),
      GoRoute(
        name: 'pastpapers',
        path: '/pastpapers',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return MaterialPage(
            child: PastPapersPage(),
          );
        },
      ),
      GoRoute(
        name: 'notes',
        path: '/notes',
        builder: (BuildContext context, GoRouterState state) {
          return NotesPage();
        },
      ),
      GoRoute(
        name: 'syllabus',
        path: '/syllabus',
        builder: (BuildContext context, GoRouterState state) {
          return SyllabusPage();
        },
      ),
      GoRoute(
        name: 'e-books',
        path: '/e-books',
        builder: (BuildContext context, GoRouterState state) {
          return EBooksPage();
        },
      ),
      GoRoute(
        name: 'others',
        path: '/others',
        builder: (BuildContext context, GoRouterState state) {
          return OtherResources();
        },
      ),
      GoRoute(
        name: 'timetables',
        path: '/timetables',
        builder: (BuildContext context, GoRouterState state) {
          return TimeTablePage();
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
