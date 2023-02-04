import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String bodyMsg;
  final String altButtonLabel;
  final String redButtonLabel;
  final VoidCallback onAltPressed;
  final VoidCallback onRedPressed;

  const ConfirmDeleteDialog({
    required this.bodyMsg,
    this.redButtonLabel = "Delete",
    this.altButtonLabel = "Cancel",
    required this.onRedPressed,
    required this.onAltPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: Text(bodyMsg, style: Theme.of(context).textTheme.bodyLarge),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            backgroundColor: Colors.red[400],
          ),
          onPressed: onRedPressed,
          child: Text(
            redButtonLabel,
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          child: Text(
            altButtonLabel,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          onPressed: onAltPressed,
        ),
      ],
    );
  }
}
