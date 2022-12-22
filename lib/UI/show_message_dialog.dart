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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
        content: Text(msg),
        actions: <Widget>[
          TextButton(
            child: Text(closeButtonText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
