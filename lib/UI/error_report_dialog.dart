import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorReportDialog extends StatelessWidget {
  final String errorTitle;
  final String errorMsg;
  final String ctaButtonLabel;
  final String emailBody;

  const ErrorReportDialog({
    Key? key,
    required this.errorTitle,
    required this.errorMsg,
    required this.ctaButtonLabel,
    required this.emailBody,
  }) : super(key: key);

  String _mailToLink() => Uri.encodeFull(
      "mailto:contact@maskys.com?subject=Feedback for PapaCambridge: $errorTitle&body=$emailBody. Error message: $errorMsg");

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        errorTitle,
        textAlign: TextAlign.center,
      ),
      content: Text(errorMsg),
      actions: <Widget>[
        TextButton(
          child: Text("Close"),
          onPressed: () => Navigator.of(context)
            ..pop()
            ..pop(),
        ),
        TextButton(
          child: Text(ctaButtonLabel),
          onPressed: () async {
            // ignore: deprecated_member_use
            if (await canLaunch(_mailToLink())) {
              // ignore: deprecated_member_use
              await launch(_mailToLink());
            } else {
              throw 'Could not open email client.';
            }
          },
        )
      ],
    );
  }
}
