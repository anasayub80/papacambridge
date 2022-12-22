import 'package:flutter/material.dart';

import '../UI/mainFilesList.dart';
import '../UI/studento_app_bar.dart';

// ignore: must_be_immutable
class NotesPage extends StatelessWidget {
  String domainId;
  NotesPage({required this.domainId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: StudentoAppBar(
          title: "Notes",
          context: context,
        ),
        body: mainFilesList(
          domainId: domainId,
          title: 'Notes',
        ));
  }
}
