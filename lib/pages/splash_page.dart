import 'package:flutter/foundation.dart';
import 'package:studento/model/subject.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studento/model/user_data.dart';
import 'package:studento/pages/setup.dart';
import '../utils/theme_provider.dart';
import 'home_page.dart';
import 'intro.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool? isSetupComplete;

  bool timeUp = false;
  void checkifSetupComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('setup')) {
      bool? value = prefs.getBool('setup');
      setState(() {
        if (value!) {
          isSetupComplete = true;
        } else {
          isSetupComplete = false;
        }
      });
    } else {
      setState(() {
        isSetupComplete = false;
      });
    }

    Future.delayed(
      Duration(seconds: 3),
      () {
        if (kIsWeb) {
          isSetupComplete!
              ? GoRouter.of(context).pushReplacementNamed('home')
              : GoRouter.of(context).pushReplacementNamed('setup');
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return isSetupComplete! ? HomePage() : IntroPage();
            },
          ));
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initHive();
    checkifSetupComplete();
  }

  initHive() async {
    await Hive.initFlutter();
    // Hive.registerAdapter<UserData>(UserDataAdapter());
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter<UserData>(UserDataAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter<Level?>(LevelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter<Subject>(SubjectAdapter());
    }
    await Hive.openBox<UserData>('userData');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSettings>(context, listen: false);
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Image.asset(
              themeProvider.currentTheme == ThemeMode.light
                  ? 'assets/icons/logo.png'
                  : 'assets/icons/Darklogo.png',
              height: 125,
              fit: BoxFit.contain,
              width: kIsWeb ? 300 : MediaQuery.of(context).size.width * 0.85,
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
