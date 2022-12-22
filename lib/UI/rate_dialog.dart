// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';

class RateDialog extends StatelessWidget {
  late BuildContext buildContext;

  @override
  Widget build(BuildContext context) {
    buildContext = context;

    return AlertDialog(
      contentPadding: EdgeInsets.all(0.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: Color(0xFF5fbff9),
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Icon(Icons.shop, color: Colors.white, size: 48.0),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Text(
              'Rate the app?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Text(
                'You are one of the first people to download Papa Cambridge, and your feedback is very important.\n\nWould you mind giving it a rating on the Play Store?'),
          ),
          fiveStars(),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('MAYBE LATER.'),
          style:
              TextButton.styleFrom(textStyle: TextStyle(color: Colors.black38)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(color: Colors.white),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            backgroundColor: Colors.lightBlue,
            shape: StadiumBorder(),
          ),
          child: Text('RATE IT'),
          onPressed: () {
            Navigator.of(context).pop();
            showThankUDialog();
            LaunchReview.launch(androidAppId: 'com.MaskyS.studento');
          },
        ),
      ],
    );
  }

  /// Returns a row of five star shapes.
  Widget fiveStars() => Container(
        margin:
            EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.star_border),
            Icon(Icons.star_border),
            Icon(Icons.star_border),
            Icon(Icons.star_border),
            Icon(Icons.star_border),
          ],
        ),
      );

  void showThankUDialog() {
    showDialog(
      context: buildContext,
      builder: (_) => AlertDialog(
        titlePadding: EdgeInsets.only(bottom: 15.0),
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 30),
          color: Color(0xFFfc6dab),
          alignment: Alignment.center,
          child: Icon(
            Icons.favorite,
            color: Colors.white,
            size: 48.0,
          ),
        ),
        content: Text("Thank you, you are the absolute best."),
        actions: <Widget>[
          TextButton(
            child: Text("YOU BET I AM!"),
            onPressed: () {
              Navigator.of(buildContext).pop();
            },
          ),
        ],
      ),
    );
  }
}
