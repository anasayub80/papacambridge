import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:studento/UI/changeThemeButton.dart';

import 'package:studento/pages/terms_of_use.dart';
import 'package:studento/pages/privacy_policy.dart';
import 'package:studento/pages/setup.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          studentoLogo(),
          SectionHeader("Settings"),
          SettingsTile(
            title: "Level & Subjects",
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => Setup(
                        isEditingSettings: true,
                      )));
            },
          ),
          SettingsTile(
            title: "Change Theme",
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => Setup(
                        isEditingSettings: true,
                      )));
            },
            trailing: ChangeThemeButton(),
          ),
          Padding(padding: EdgeInsets.all(10)),
          SectionHeader("About"),
          SettingsTile(
            enabled: false,
            title: "Version",
            trailing: FutureBuilder(
              future: getVersionNumber(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
                  Text(
                snapshot.hasData ? snapshot.data! : "Loading ...",
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .color!
                        .withOpacity(0.6),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SettingsTile(
            title: "Buy Me a Coffee",
            // ignore: deprecated_member_use
            onTap: () => launch("https://www.buymeacoffee.com/7eqkIcK"),
          ),
          SettingsTile(
            title: "Terms of Use",
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TermsOfUsePage(),
              ),
            ),
          ),
          SettingsTile(
            title: "Privacy Policy",
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PrivacyPolicyPage(),
              ),
            ),
          ),
          SettingsTile(
            title: "Third-party software",
            onTap: () => showLicensePage(
              context: context,
              applicationName: "Papa Cambridge",
              applicationLegalese:
                  "Papa Cambridge is made possible only through the power of open-source software.",
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    return version;
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
        ),
        Divider(),
      ],
    );
  }
}

class studentoLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      child: Text(
        "studento",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final bool enabled;
  final Widget trailing;
  final VoidCallback? onTap;
  const SettingsTile({
    required this.title,
    this.enabled = true,
    this.onTap,
    this.trailing = const Icon(Icons.arrow_right),
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: trailing,
      enabled: enabled,
      onTap: onTap,
    );
  }
}
