import 'package:flutter/foundation.dart';
import 'package:studento/UI/mainFilesList.dart';
import 'package:flutter/material.dart';

import 'package:studento/UI/studento_app_bar.dart';

import '../provider/loadigProvider.dart';
import 'searchPage.dart';
import 'package:provider/provider.dart';

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
  void initState() {
    super.initState();
    if (kIsWeb) {
      Future.delayed(
        Duration.zero,
        () {
          Provider.of<loadingProvider>(context, listen: false)
              .changeDomainid(widget.domainId);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StudentoAppBar(
        title: "E-Books",
        context: context,
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.push(context, MaterialPageRoute(
        //           builder: (context) {
        //             return SearchPage(
        //               domainId: widget.domainId,
        //               domainName: "E-Books",
        //             );
        //           },
        //         ));
        //       },
        //       icon: Icon(Icons.search))
        // ],
      ),
      body: mainFilesList(
        domainId: 3,
        title: 'E-Books',
        domainName: 'ebooks',
      ),
      floatingActionButton: FloatingActionButton(
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
        child: Icon(Icons.search),
      ),
    );
  }
}
