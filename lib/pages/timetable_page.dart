import 'package:flutter/material.dart';

import '../UI/mainFilesList.dart';
import '../UI/studento_app_bar.dart';

// ignore: must_be_immutable
class TimeTablePage extends StatelessWidget {
  String domainId;
  TimeTablePage({required this.domainId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: StudentoAppBar(
          title: "Time Table",
          context: context,
        ),
        body: mainFilesList(
          domainId: domainId,
          title: 'Time Table',
        ));
  }
}
