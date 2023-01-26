import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/setup.dart';
import '../utils/newHelper.dart';
import '../utils/theme_provider.dart';
import 'changeThemeButton.dart';
import 'package:provider/provider.dart';

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

// ignore: must_be_immutable
class studentoDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSettings>(context, listen: false);
    final creditsFooter = Align(
      alignment: Alignment.bottomCenter,
      child: ListTile(
        onTap: () {
          const url = 'https://papacambridge.com/home/index.html';
          NewHelper().launchInBrowser(Uri.parse(url));
        },
        title: Image.asset(
          themeProvider.currentTheme == ThemeMode.light
              ? 'assets/icons/logo.png'
              : 'assets/icons/Darklogo.png',
          height: 25,
          width: 75,
          fit: BoxFit.contain,
        ),
      ),
    );
    // var currentTime = TimeOfDay.now();
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(children: <Widget>[
        ListView(
          children: <Widget>[
            timeHeader('PapaCambridge', context),

            // getProFragment,
            ListTile(
              leading: Container(
                  width: 20,
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.menu_book)),
              title: Text(
                "EXAMS",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              subtitle: Text(
                'Change your board/subjects',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              onTap: () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => Setup(
                          isEditingSideMenu: true,
                        ))),
              },
            ),
            // settingsFragment,
            sendFeedbackFragment,
            shareFragment,
          ],
        ),
        creditsFooter,
      ]),
    );
  }

  Widget timeHeader(String time, BuildContext context) => DrawerHeader(
        decoration: BoxDecoration(color: Color(0xFF24243e)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Center(
            //   child: Text(
            //     time,
            //     style: TextStyle(
            //         fontSize: 20.0,
            //         color: Colors.white,
            //         fontWeight: FontWeight.w400),
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Light',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.white),
                ),
                ChangeThemeButton(),
                Text(
                  'Dark',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      );

  // final getProFragment = DrawerFragment(
  //   icon: Icons.card_membership,
  //   title: "Get Pro 🌟🚀",
  //   subtitle: "Get rid of ads and unlock cool features!",
  //   routeName: 'get_pro_page',
  // );

  // final settingsFragment = DrawerFragment(
  //   icon: Icons.settings,
  //   title: "Settings",
  //   subtitle: "Configure your app settings.",
  //   routeName: 'settings_page',
  // );
  final sendFeedbackFragment = ListTile(
    leading: Container(
        width: 20,
        alignment: Alignment.centerLeft,
        child: Icon(Icons.feedback)),
    title: Text(
      "SEND FEEDBACK",
      style: TextStyle(
        fontSize: 12,
      ),
    ),
    subtitle: Text(
      "Report a nasty bug or send awesome ideas our way.",
      style: TextStyle(
        fontSize: 12,
      ),
    ),
    onTap: () {
      print("You're a good user, thanks for reporting bugs.");

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'support@papacambridge.com',
        query: encodeQueryParameters(<String, String>{
          'subject': 'Feedback for PapaCambridge!',
        }),
      );

      launchUrl(emailLaunchUri);
    },
  );
  final shareFragment = ListTile(
    leading: Container(
        width: 20, alignment: Alignment.centerLeft, child: Icon(Icons.share)),
    title: Text(
      "SHARE APP",
      style: TextStyle(
        fontSize: 12,
      ),
    ),
    subtitle: Text(
      "Share app with a friend.",
      style: TextStyle(
        fontSize: 12,
      ),
    ),
    onTap: () {
      Share.share(
        "Hey! I think you'll find PapaCambridge useful. It's a student assistant app for O/A Level students, with past papers, syllabus, schedule, and more. Link: https://play.google.com/store/apps/details?id=com.MaskyS.papaCambridge",
        subject: "Check out this amazing app",
      );
    },
  );
}

class DrawerFragment extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String routeName;

  const DrawerFragment({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.routeName,
  });

  void _onTap(String routeName, BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
          width: 20, alignment: Alignment.centerLeft, child: Icon(icon)),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () => _onTap(routeName, context),
    );
  }
}
