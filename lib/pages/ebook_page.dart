import 'package:studento/UI/mainFilesList.dart';
import 'package:flutter/material.dart';

import 'package:studento/UI/studento_app_bar.dart';

import 'searchPage.dart';

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
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return SearchPage(
                        domainId: widget.domainId,
                        domainName: "E-Books",
                      );
                    },
                  ));
                },
                icon: Icon(Icons.search))
          ],
        ),
        body: mainFilesList(
          domainId: widget.domainId,
          title: 'E-Books',
          domainName: 'ebooks',
        )
        //  SubjectsStaggeredListView(openPastPapersDetailsSelect),
        );
  }
}
