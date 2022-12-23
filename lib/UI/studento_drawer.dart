import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/setup.dart';
import '../utils/newHelper.dart';

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

class studentoDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentTime = TimeOfDay.now();
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(children: <Widget>[
        ListView(
          children: <Widget>[
            timeHeader(currentTime.format(context)),
            // getProFragment,
            ListTile(
              leading: Container(
                  width: 20,
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.menu_book)),
              title: Text("Change Board"),
              subtitle: Text('Change your board'),
              onTap: () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => Setup(
                          isEditingSideMenu: true,
                        ))),
              },
            ),
            settingsFragment,
            sendFeedbackFragment,
            shareFragment,
          ],
        ),
        creditsFooter,
      ]),
    );
  }

  Widget timeHeader(String time) => DrawerHeader(
        decoration: BoxDecoration(color: Color(0xFF24243e)),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
                fontSize: 50.0,
                color: Colors.white,
                fontWeight: FontWeight.w100),
          ),
        ),
      );

  // final getProFragment = DrawerFragment(
  //   icon: Icons.card_membership,
  //   title: "Get Pro 🌟🚀",
  //   subtitle: "Get rid of ads and unlock cool features!",
  //   routeName: 'get_pro_page',
  // );

  final settingsFragment = DrawerFragment(
    icon: Icons.settings,
    title: "Settings",
    subtitle: "Configure your app settings.",
    routeName: 'settings_page',
  );
  final sendFeedbackFragment = ListTile(
    leading: Container(
        width: 20,
        alignment: Alignment.centerLeft,
        child: Icon(Icons.feedback)),
    title: Text("Send Feedback"),
    subtitle: Text("Report a nasty bug or send awesome ideas our way."),
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
    title: Text("Share App"),
    subtitle: Text("Share Papa Cambridge with a friend."),
    onTap: () {
      Share.share(
        "Hey! I think you'll find Papa Cambridge useful. It's a student assistant app for O/A Level students, with past papers, syllabus, schedule, and more. Link: https://play.google.com/store/apps/details?id=com.MaskyS.studento",
        subject: "Check out this amazing app",
      );
    },
  );
  final creditsFooter = Align(
    alignment: Alignment.bottomCenter,
    child: ListTile(
      onTap: () {
        const url = 'https://maskys.com';
        NewHelper().launchInBrowser(Uri.parse(url));
      },
      title: Text(
        "Made with 💖 by MaskyS",
        textAlign: TextAlign.center,
      ),
    ),
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
