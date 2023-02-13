import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../UI/mainFilesList.dart';
import '../UI/studento_app_bar.dart';
import '../provider/loadigProvider.dart';
import 'searchPage.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TimeTablePage extends StatefulWidget {
  String domainId;
  TimeTablePage({required this.domainId});

  @override
  State<TimeTablePage> createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StudentoAppBar(
        title: "Time Table",
        context: context,
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.push(context, MaterialPageRoute(
        //           builder: (context) {
        //             return SearchPage(
        //               domainId: widget.domainId,
        //               domainName: "Past Papers",
        //             );
        //           },
        //         ));
        //       },
        //       icon: Icon(Icons.search))
        // ],
      ),
      body: mainFilesList(
        domainId: widget.domainId,
        title: 'TimeTable',
        domainName: 'timetable',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return SearchPage(
                domainId: widget.domainId,
                domainName: "TimeTable",
              );
            },
          ));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
