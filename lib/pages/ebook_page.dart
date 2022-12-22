import 'package:studento/UI/mainFilesList.dart';
import 'package:flutter/material.dart';

import 'package:studento/UI/studento_app_bar.dart';

// ignore: must_be_immutable
class EBooksPage extends StatefulWidget {
  String domainId;
  EBooksPage({required this.domainId});
  @override
  // ignore: library_private_types_in_public_api
  _EBooksPageState createState() => _EBooksPageState();
}

class _EBooksPageState extends State<EBooksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: StudentoAppBar(
          title: "E-Books",
          context: context,
        ),
        body: mainFilesList(
          domainId: widget.domainId,
          title: 'E-Books',
        )
        //  SubjectsStaggeredListView(openPastPapersDetailsSelect),
        );
  }
}
