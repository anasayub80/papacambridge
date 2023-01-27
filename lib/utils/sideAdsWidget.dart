import 'package:flutter/material.dart';

import 'theme_provider.dart';

class sideAdsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 500,
            height: MediaQuery.of(context).size.height,
            child: Image.asset('assets/illustrations/sampleAds.jpg'),
            decoration: BoxDecoration(),
          ),
        ),
      ),
    );
  }
}

SizedBox navBar(ThemeSettings themeProvider, BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Image.asset(
              themeProvider.currentTheme == ThemeMode.light
                  ? 'assets/icons/logo.png'
                  : 'assets/icons/Darklogo.png',
              height: 50,
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(onPressed: () {}, child: Text('Advertise')),
              SizedBox(
                width: 10,
              ),
              TextButton(onPressed: () {}, child: Text('Contact')),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ],
      ),
      color: Theme.of(context).cardColor,
    ),
  );
}
