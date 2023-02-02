import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../UI/mainFilesList.dart';
import '../UI/studento_app_bar.dart';
import '../UI/web_appbar.dart';
import '../provider/loadigProvider.dart';
import '../utils/theme_provider.dart';
import 'searchPage.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TimeTablePage extends StatefulWidget {
  String? domainId;
  TimeTablePage({this.domainId});

  @override
  State<TimeTablePage> createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
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
    final themeProvider = Provider.of<ThemeSettings>(context, listen: false);

    return Scaffold(
        appBar: kIsWeb
            ? webAppBar(themeProvider, context)
            : StudentoAppBar(
                title: "Time Table",
                context: context,
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return SearchPage(
                              domainId: widget.domainId!,
                              domainName: "Past Papers",
                            );
                          },
                        ));
                      },
                      icon: Icon(Icons.search))
                ],
              ),
        body: mainFilesList(
          domainId: widget.domainId,
          title: 'Time Table',
          domainName: 'timetable',
        ));
  }
}
