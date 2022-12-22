import 'package:flutter/material.dart';

import '../UI/mainFilesList.dart';
import '../UI/studento_app_bar.dart';

// ignore: must_be_immutable
class OtherResources extends StatelessWidget {
  String domainId;
  OtherResources({required this.domainId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: StudentoAppBar(
          title: "Other Resources",
          context: context,
        ),
        body: mainFilesList(
          domainId: domainId,
          title: 'Other Resources',
        ));
  }
}
