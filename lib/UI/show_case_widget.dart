import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:studento/provider/loadigProvider.dart';
import 'package:studento/utils/theme_provider.dart';
import 'package:provider/provider.dart';

class CustomShowcaseWidget extends StatelessWidget {
  final Widget child;
  final String description;
  final String title;
  final GlobalKey globalKey;

  const CustomShowcaseWidget({
    required this.description,
    required this.title,
    required this.child,
    required this.globalKey,
  });

  @override
  Widget build(BuildContext context) => Showcase(
        key: globalKey,
        // showcaseBackgroundColor: Colors.pink.shade400,
        // tooltipBackgroundColor: ,
        blurValue: 1,
        // contentPadding: EdgeInsets.all(12),
        showArrow: false,
        // disableAnimation: true,
        title: title,
        titleTextStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 18),
        description: description,
        descTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyText1!.color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        overlayColor: darkColor,

        overlayOpacity: 0.7,
        child: child,
      );
}
