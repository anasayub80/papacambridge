// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:scoped_model/scoped_model.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:studento/model/todo/todo_list_model.dart';
import 'package:studento/pages/splash_page.dart';
import 'package:studento/provider/loadigProvider.dart';
import 'package:studento/provider/multiViewhelper.dart';
import 'package:studento/routes.dart';
import 'package:studento/services/navigate_observe.dart';
import 'package:studento/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  PurchasesConfiguration("AuXGxOAwTbgrcvIVwCYYAPoHhcRHUdLa");
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final isDark = sharedPreferences.getBool('is_dark') ?? false;
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await runZonedGuarded(() async {
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(Studento(
      isDark: isDark,
    ));
  }, (error, stackTrace) {
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

// if you facing build issue while genrating apk used this command
// flutter build apk --no-tree-shake-icons
// https://myaccount.papacambridge.com/api.php?main_folder=32494
// PAST PAPERS
class Studento extends StatefulWidget {
  final bool isDark;
  const Studento({super.key, required this.isDark});

  @override
  _StudentoState createState() => _StudentoState();
}

class _StudentoState extends State<Studento> {
  // bool isSetupComplete;
  // firebase removed
  // static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // final FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);
  // firebase removed

  // bool timeUp = false;
  // void checkifSetupComplete() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int timesUpStamp = DateTime.now().millisecondsSinceEpoch;
  //   if (timesUpStamp > 1617993701458) {
  //     setState(() {
  //       timeUp = true;
  //       isSetupComplete = false;
  //     });
  //   } else if (prefs.containsKey('setup')) {
  //     bool value = prefs.getBool('setup');
  //     setState(() {
  //       if (value) {
  //         isSetupComplete = true;
  //       } else {
  //         isSetupComplete = false;
  //       }
  //     });
  //   } else {
  //     setState(() {
  //       isSetupComplete = false;
  //     });
  //   }

  //   // var box = Hive.box<UserData>('userData');
  //   // UserData userData =
  //   //     box.get(0, defaultValue: UserData(false, null, [], isPro: false));
  //   // userData.isInBox ? userData.save() : box.put(0, userData);
  //   // isSetupComplete = userData.isSetupComplete;
  // }

  @override
  void initState() {
    // checkifSetupComplete();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Lock app orientation to Portrait so rotating doesn't break the design.
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    var app = MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeSettings(widget.isDark)),
        ChangeNotifierProvider(create: (_) => loadingProvider()),
        ChangeNotifierProvider(create: (_) => multiViewProvider()),
      ],
      builder: (context, child) {
        final themeProvider = Provider.of<ThemeSettings>(context);
        return MaterialApp(
          title: 'PapaCambridge',
          builder: BotToastInit(), //1. call BotToastInit
          navigatorObservers: [
            BotToastNavigatorObserver(),
            NavigatorObserver(),
            AppNavigatorObserver(),
          ],
          // navigatorObservers: <NavigatorObserver>[observer],
          themeMode: themeProvider.currentTheme,
          theme: MyTheme().lightTheme,
          darkTheme: MyTheme().darkTheme,
          color: Colors.red,
          home: ShowCaseWidget(
              builder: Builder(builder: (context) => SplashPage())
              // Builder(builder: (context) {
              //   return SplashPage();
              // }),
              ),
          // home: TestPage(),
          routes: routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
    return ScopedModel<TodoListModel>(
      model: TodoListModel(),
      child: app,
    );
  }
}

// class TimesUp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text('Times Up'),
//       ),
//     );
//   }
// }
