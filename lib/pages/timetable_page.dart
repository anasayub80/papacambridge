import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../UI/mainFilesList.dart';
import '../UI/studento_app_bar.dart';
import '../UI/web_appbar.dart';
import '../provider/loadigProvider.dart';
import '../services/backend.dart';
import '../utils/theme_provider.dart';
import 'searchPage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class TimeTablePage extends StatelessWidget {
  String? domainId;
  TimeTablePage({this.domainId});

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
                              domainId: domainId!,
                              domainName: "Past Papers",
                            );
                          },
                        ));
                      },
                      icon: Icon(Icons.search))
                ],
              ),
        body: kIsWeb ? webBody() : mobileBody(domainId: domainId));
  }
}

class webBody extends StatefulWidget {
  const webBody({
    Key? key,
  }) : super(key: key);

  @override
  State<webBody> createState() => _webBodyState();
}

class _webBodyState extends State<webBody> {
  void getDomainIdformainfile(provider) async {
    // get domain id according to board
    if (provider.getboardId == 'none') {
      // if board id is stored in cache bcz user was a new visitor
      provider.changeBoardId(returnboardid('ocr'));
      http.Response res =
          await http.post(Uri.parse("$webAPI?page=domains"), body: {
        'board': provider.getboardId,
        'websiteurl': 'timetable.papacambridge.com',
        'token': token
      });
      var response = jsonDecode(res.body);
      _streamController.add(response);
      // return res;
    }
  }

  StreamController _streamController = BehaviorSubject();
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () {
        getDomainIdformainfile(
            Provider.of<loadingProvider>(context, listen: false));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return mainFilesList(
              domainId: snapshot.data[0]["id"],
              title: 'TimeTables',
              isPastPapers: true,
              domainName: 'timetable',
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class mobileBody extends StatelessWidget {
  const mobileBody({
    Key? key,
    required this.domainId,
  }) : super(key: key);

  final String? domainId;

  @override
  Widget build(BuildContext context) {
    return mainFilesList(
      domainId: domainId,
      title: 'Time Table',
      domainName: 'timetable',
    );
  }
}
