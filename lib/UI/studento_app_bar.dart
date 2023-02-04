import 'package:flutter/material.dart';

/// Contains the custom Studento AppBar.
class StudentoAppBar extends AppBar {
  StudentoAppBar(
      {Key? key,
      required BuildContext context,
      String title = '',
      bool centerTitle = true,
      bool isFile = false,
      double elevation = 4,
      PreferredSizeWidget? bottom,
      Widget? leading,
      // Color backgroundColor = Colors.white,
      // IconThemeData iconTheme = const IconThemeData(color: Colors.black87),
      List<Widget>? actions})
      : super(
            key: key,
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20.0,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              textScaleFactor: isFile ? 1.0 : 1.2,
            ),
            actions: actions,
            iconTheme: Theme.of(context).iconTheme,
            centerTitle: centerTitle,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            bottom: bottom,
            leading: leading,
            elevation: elevation);
}
