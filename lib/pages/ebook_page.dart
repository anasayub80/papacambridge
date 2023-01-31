import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:studento/UI/mainFilesList.dart';
import 'package:flutter/material.dart';
import 'package:studento/UI/studento_app_bar.dart';
import '../UI/web_appbar.dart';
import '../provider/loadigProvider.dart';
import '../services/backend.dart';
import '../utils/theme_provider.dart';
import 'searchPage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class EBooksPage extends StatelessWidget {
  String? domainId;
  EBooksPage({this.domainId});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSettings>(context, listen: false);
    return Scaffold(
        appBar: kIsWeb
            ? webAppBar(themeProvider, context)
            : StudentoAppBar(
                title: "E-Books",
                context: context,
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return SearchPage(
                              domainId: domainId!,
                              domainName: "E-Books",
                            );
                          },
                        ));
                      },
                      icon: Icon(Icons.search))
                ],
              ),
        body: kIsWeb ? webBody() : mobileBody(domainId: domainId)
        //  SubjectsStaggeredListView(openPastPapersDetailsSelect),
        );
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
      log('get notes data board is 1,');
      http.Response res =
          await http.post(Uri.parse("$webAPI?page=domains"), body: {
        'board': provider.getboardId,
        'websiteurl': 'ebooks.papacambridge.com',
        'token': token
      });
      var response = jsonDecode(res.body);
      log('res get ${response[0]["id"]}');
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
              title: 'E-Books',
              isPastPapers: true,
              domainName: 'ebooks',
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
      title: 'E-Books',
      domainName: 'ebooks',
    );
  }
}
