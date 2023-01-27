import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/setup.dart';
import '../utils/theme_provider.dart';
import 'changeThemeButton.dart';

PreferredSize webAppBar(ThemeSettings themeProvider, BuildContext context) {
  return PreferredSize(
    preferredSize: Size.fromHeight(55),
    child: SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: InkWell(
                onTap: () {
                  print('go to home');
                  GoRouter.of(context).pushNamed('home');
                },
                child: Image.asset(
                  themeProvider.currentTheme == ThemeMode.light
                      ? 'assets/icons/logo.png'
                      : 'assets/icons/Darklogo.png',
                  height: 50,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (_) => Setup(
                      //           isEditingSideMenu: true,
                      //         )));
                      GoRouter.of(context).pushNamed('setup');
                    },
                    child: Text('Exams')),
                SizedBox(
                  width: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.light_mode,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    ChangeThemeButton(),
                    Icon(
                      Icons.dark_mode,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        color: Theme.of(context).cardColor,
      ),
    ),
  );
}
