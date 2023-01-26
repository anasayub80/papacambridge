import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:studento/model/todo/todo_list_model.dart';
import 'package:studento/pages/splash_page.dart';
import 'package:studento/provider/loadigProvider.dart';
import 'package:studento/provider/multiViewhelper.dart';
import 'package:studento/routes.dart';
import 'package:studento/services/navigate_observe.dart';
import 'package:studento/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
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
          home: SplashPage(),
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
