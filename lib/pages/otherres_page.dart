import 'package:flutter/material.dart';

import '../UI/mainFilesList.dart';
import '../UI/studento_app_bar.dart';
import 'searchPage.dart';

// ignore: must_be_immutable
class OtherResources extends StatefulWidget {
  String domainId;
  OtherResources({required this.domainId});

  @override
  State<OtherResources> createState() => _OtherResourcesState();
}

class _OtherResourcesState extends State<OtherResources> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StudentoAppBar(
        title: "Other",
        context: context,
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.push(context, MaterialPageRoute(
        //           builder: (context) {
        //             return SearchPage(
        //               domainId: widget.domainId,
        //               domainName: "Others",
        //             );
        //           },
        //         ));
        //       },
        //       icon: Icon(Icons.search))
        // ],
      ),
      body: mainFilesList(
        domainId: widget.domainId,
        title: 'Other',
        domainName: 'other-resources',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return SearchPage(
                domainId: widget.domainId,
                domainName: "Others",
              );
            },
          ));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
