import 'dart:async';

import 'package:studento/model/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class GetProPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _GetProPageState createState() => _GetProPageState();
}

class _GetProPageState extends State<GetProPage> {
  CustomerInfo? _purchaserInfo;
  Offerings? _offerings;

  Future<void> initPlatformState() async {
    Purchases.setDebugLogsEnabled(true);
    CustomerInfo purchaserInfo = await Purchases.getCustomerInfo();
    Offerings offerings = await Purchases.getOfferings();
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _purchaserInfo = purchaserInfo;
      _offerings = offerings;
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    if (_purchaserInfo == null || _offerings == null) {
      return Container(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    var isPro = _purchaserInfo!.entitlements.active.containsKey("pro");

    if (isPro) {
      return AlreadyPro();
    }
    return PayWallPage(_offerings);
  }
}

class PayWallPage extends StatelessWidget {
  final Offerings? offerings;

  PayWallPage(
    this.offerings, {
    Key? key,
  }) : super(key: key);

  final _baseBorder =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: <Widget>[
            Spacer(flex: 3),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: Colors.blueGrey.shade100,
                ),
              ),
            ),
            Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Let us help you better.\nGet Pro🚀",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
            Spacer(flex: 5),
            FeatureTile(
              titleLabel: "No Ads",
              subtitleLabel:
                  "Stay focused by removing pesky banner and video ads.",
            ),
            Spacer(flex: 1),
            FeatureTile(
              titleLabel: "Offline Syllabus",
              subtitleLabel:
                  "Skip long download times and check your syllabus anytime.",
            ),
            Spacer(flex: 1),
            FeatureTile(
              titleLabel: "Share Papers",
              subtitleLabel:
                  "Easily share papers with your friends or open them in other apps.",
            ),
            Spacer(flex: 1),
            FeatureTile(
              titleLabel: "Premium Features",
              subtitleLabel:
                  "Unlock upcoming pro features like dark mode, printing papers and more!",
            ),
            Spacer(flex: 1),
            FeatureTile(
              titleLabel: "Faster Updates",
              subtitleLabel:
                  "Your contributions will motivate me to provide better features & the latest papers.",
            ),
            Spacer(flex: 4),
            Text(
              "Your first week is free– on us.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            Spacer(flex: 3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                YearlyGradientButton(
                    baseBorder: _baseBorder,
                    onPressed: () =>
                        purchasePackage(offerings!.current!.annual!, context)),
                SizedBox(height: 10),
                MonthlyButton(
                    baseBorder: _baseBorder,
                    onPressed: () =>
                        purchasePackage(offerings!.current!.monthly!, context)),
                SizedBox(height: 5),
                Text(
                  "Cancel anytime﹡",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
              ],
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Future<void> purchasePackage(Package package, context) async {
    try {
      CustomerInfo purchaserInfo = await Purchases.purchasePackage(package);
      var isPro = purchaserInfo.entitlements.all["pro"]!.isActive;
      if (isPro) {
        UserData? userData = Hive.box<UserData>('userData').get(0);
        userData!
          ..isPro = true
          ..save();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AlreadyPro()));
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        _showError("You cancelled the purchase.", context);
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        _showError("You weren't allowed to purchase this item", context);
      } else {
        _showError("Please report error: $errorCode", context);
      }
    }
  }

  _showError(msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: StadiumBorder(),
      ),
    );
  }
}

class MonthlyButton extends StatelessWidget {
  const MonthlyButton({
    Key? key,
    required this.baseBorder,
    required this.onPressed,
  }) : super(key: key);

  final RoundedRectangleBorder baseBorder;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.blue,
          side: BorderSide(width: 2, color: Colors.blue),
          shape: baseBorder,
        ),
        onPressed: onPressed as void Function()?,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 15),
            Text(
              "\$2.5 per month",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15)
          ],
        ),
      ),
    );
  }
}

class AlreadyPro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Spacer(flex: 3),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "👑🚀",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 50),
                  ),
                  Text(
                    "You're Officially a Pro!\n",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Spacer(
              flex: 1,
            ),
            Text(
              "Ads: Cancelled.\nCool Features: Unlocked.\nDeveloper Morale: Boosted.\n",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 20, height: 1.3),
            ),
            Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Thank you for supporting Papa Cambridge. Every penny goes towards serving you better.\n\nIf you ever need to talk with a human, I'm just one email away. \n\nEnjoy using Studento!",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Spacer(flex: 2),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                style: TextButton.styleFrom(
                    textStyle: TextStyle(
                  color: Colors.white,
                )),
                onPressed: () => Navigator.pop(context, true),
                child: Ink(
                  decoration: ShapeDecoration(
                    shape: StadiumBorder(),
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 90, vertical: 15.0),
                    child: Text(
                      "AWESOME!",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class YearlyGradientButton extends StatelessWidget {
  const YearlyGradientButton(
      {Key? key, required this.baseBorder, required this.onPressed})
      : super(key: key);

  final RoundedRectangleBorder baseBorder;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        shape: baseBorder,
      ),
      onPressed: onPressed as void Function()?,
      child: Ink(
        decoration: ShapeDecoration(
          shape: baseBorder,
          gradient: LinearGradient(
              colors: [Colors.deepPurpleAccent, Colors.lightBlueAccent]),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 15),
                Text(
                  "\$2.0 per month",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.5),
                Text(
                  "Billed Yearly",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 12),
                ),
                SizedBox(height: 15)
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: ShapeDecoration(
                  color: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(5),
                    ),
                  ),
                ),
                padding: EdgeInsets.all(5),
                child: Text(
                  "Save 20%",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  const FeatureTile({
    Key? key,
    required this.titleLabel,
    required this.subtitleLabel,
  }) : super(key: key);

  final String titleLabel;
  final String subtitleLabel;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.check_circle,
        color: Colors.deepPurpleAccent,
      ),
      title: Text(
        titleLabel,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitleLabel),
    );
  }
}
