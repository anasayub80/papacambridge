import 'package:flutter/material.dart';

Future<void> showMessageDialog(
  BuildContext context, {
  required String msg,
  required String title,
  String closeButtonText = "Okay",
}) =>
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
        ),
        content: Text(msg),
        actions: <Widget>[
          TextButton(
            child: Text(
              closeButtonText,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
