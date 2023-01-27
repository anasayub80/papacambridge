import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color darkColor = Color(0xff1F2832);
// Color darkColor = Color(0xff14114D);
Color secColor = Color(0xffC42625);
// Color darkColor = Colors.black;

// class ThemeProvider with ChangeNotifier {
//   ThemeMode themeMode = ThemeMode.system;
//   bool get isDarkMode => themeMode == ThemeMode.dark;
//   void toggleTheme(bool isOn) {
//     themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
//     print(isOn ? 'Dark' : 'light');
//     notifyListeners();
//   }
// }
class ThemeSettings with ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.system;
  ThemeMode get currentTheme => _currentTheme;
  bool get isDarkMode => currentTheme == ThemeMode.dark;

  ThemeSettings(bool isDark) {
    if (isDark) {
      _currentTheme = ThemeMode.dark;
    } else {
      _currentTheme = ThemeMode.light;
    }
  }
  void toggleTheme(bool isOn) async {
    _currentTheme = isOn ? ThemeMode.dark : ThemeMode.light;
    if (isOn) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      sharedPreferences.setBool('is_dark', true);
    } else {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      sharedPreferences.setBool('is_dark', false);
    }
    print(isOn ? 'Dark' : 'light');
    notifyListeners();
  }
}

class MyTheme {
  final darkTheme = ThemeData(
    scaffoldBackgroundColor: darkColor,
    fontFamily: 'Montserrat',
    primaryColor: darkColor,
    iconTheme: IconThemeData(color: Colors.white),
    brightness: Brightness.dark,
    cardColor: Color(0xff262F3D),
    // cardColor: darkColor.withOpacity(0.4),
    appBarTheme: AppBarTheme(
      backgroundColor: darkColor,
    ),
    unselectedWidgetColor: Colors.white,
    textTheme: TextTheme(
      bodyText1: TextStyle(
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.dark(),
  );
  final lightTheme = ThemeData(
    scaffoldBackgroundColor: kIsWeb ? Color(0xfff1f2f7) : Colors.white,
    fontFamily: 'Montserrat',
    iconTheme: IconThemeData(color: Colors.black87),
    brightness: Brightness.light,
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
    ),
    unselectedWidgetColor: darkColor,
    textTheme: TextTheme(
      bodyText1: TextStyle(
        color: Colors.black,
      ),
    ),
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(),
  );
}
