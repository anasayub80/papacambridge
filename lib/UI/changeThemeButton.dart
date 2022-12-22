import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:studento/utils/theme_provider.dart';
class ChangeThemeButton extends StatelessWidget {
  const ChangeThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSettings>(context);
    return Switch.adaptive(value: themeProvider.isDarkMode, onChanged: (value) {
      final provider = Provider.of<ThemeSettings>(context,listen: false);
      provider.toggleTheme(value);
    },);
  }
}