import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:studento/model/todo/todo_list_model.dart';
import 'package:studento/pages/home_page.dart';
import 'package:studento/pages/setup.dart';
import 'package:studento/pages/splash_page.dart';
import 'package:studento/provider/loadigProvider.dart';
import 'package:studento/provider/multiViewhelper.dart';
import 'package:studento/routes.dart';
import 'package:studento/services/navigate_observe.dart';
import 'package:studento/utils/backbuttondispatcher.dart';
import 'package:studento/utils/go_routes.dart';
import 'package:studento/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_strategy/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:studento/pages/past_papers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    setPathUrlStrategy();
  } else {
    MobileAds.instance.initialize();
  }
  PurchasesConfiguration("AuXGxOAwTbgrcvIVwCYYAPoHhcRHUdLa");
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final isDark = sharedPreferences.getBool('is_dark') ?? false;
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await runZonedGuarded(() async {
    runApp(Studento(
      isDark: isDark,
    ));
  }, (error, stackTrace) {});
}

// if you facing build issue while genrating apk used this command
// flutter build apk --no-tree-shake-icons
// https://myaccount.papacambridge.com/api.php?main_folder=32494
// PAST PAPERS
class Studento extends StatefulWidget {
  final bool isDark;
  const Studento({super.key, required this.isDark});

  @override
  // ignore: library_private_types_in_public_api
  _StudentoState createState() => _StudentoState();
}

class _StudentoState extends State<Studento> {
  @override
  void initState() {
    // checkifSetupComplete();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        return kIsWeb ? webBody(themeProvider) : mobileBody(themeProvider);
        // );
      },
    );
    return ScopedModel<TodoListModel>(
      model: TodoListModel(),
      child: app,
    );
  }

  MaterialApp webBody(ThemeSettings themeProvider) {
    return MaterialApp.router(
      // routerConfig: MyGoRouter().router,
      routeInformationParser: MyGoRouter().router.routeInformationParser,
      routerDelegate: MyGoRouter().router.routerDelegate,
      builder: BotToastInit(),
      themeMode: themeProvider.currentTheme,
      theme: MyTheme().lightTheme,
      darkTheme: MyTheme().darkTheme,
      color: Colors.red,
      debugShowCheckedModeBanner: false,
    );
  }

  MaterialApp mobileBody(ThemeSettings themeProvider) {
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
      home: SplashPage(),
      // home: TestPage(),
      routes: routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
