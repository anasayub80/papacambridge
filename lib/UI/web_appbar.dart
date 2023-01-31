import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:studento/pages/home_page.dart';
import '../provider/loadigProvider.dart';
import '../services/backend.dart';
import '../utils/theme_provider.dart';
import 'package:provider/provider.dart';

StreamController domainStream = BehaviorSubject();
var myres;

getDomain(BuildContext context) async {
  log('get appbar domain');
  myres = await backEnd().fetchDomains(
      Provider.of<loadingProvider>(context, listen: false).getboardId);
  domainStream.add(myres);
}

returnPushName(name) {
  var pushname = '';
  switch (name.toString().trim()) {
    case 'Past Papers':
      pushname = 'pastpapers';
      break;
    case 'Syllabus':
      pushname = 'syllabus';
      break;
    case 'E Books':
      pushname = 'e-books';
      break;
    case 'Notes':
      pushname = 'notes';
      break;
    case 'Others':
      pushname = 'others';
      break;
    case 'Timetables':
      pushname = 'timetables';
      break;
    default:
  }
  return pushname;
}

returnBoardName(name) {
  var pushname = '';
  print('return board name from board id $name');
  switch (name.toString().trim()) {
    case '1':
      pushname = 'caie';
      break;
    case '2':
      pushname = 'ocr';
      break;
    case '3':
      pushname = 'ccea';
      break;
    case '4':
      pushname = 'aqa';
      break;
    case '5':
      pushname = 'wjec';
      break;
    case '6':
      pushname = 'ib';
      break;
    case '7':
      pushname = 'pearson';
      break;
    default:
      pushname = 'ocr';
  }
  return pushname;
}

returnboardid(name) {
  var pushname = '';
  print('return board name from board id $name');
  switch (name.toString().trim()) {
    case 'caie':
      pushname = '1';
      break;
    case 'ocr':
      pushname = '2';
      break;
    case 'ccea':
      pushname = '3';
      break;
    case 'aqa':
      pushname = '4';
      break;
    case 'wjec':
      pushname = '5';
      break;
    case 'ib':
      pushname = '6';
      break;
    case 'pearson':
      pushname = '7';
      break;
    default:
      pushname = '2';
  }
  log(pushname);
  return pushname;
}

PreferredSize webAppBar(ThemeSettings themeProvider, BuildContext context) {
  getDomain(context);
  return PreferredSize(
    preferredSize: Size.fromHeight(55),
    child: SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: InkWell(
                onTap: () {
                  print('go to home');
                  GoRouter.of(context).pushNamed('home');
                },
                child: Image.asset(
                  themeProvider.currentTheme == ThemeMode.light
                      ? 'assets/icons/logo.png'
                      : 'assets/icons/Darklogo.png',
                  height: 50,
                  width: 175,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<dynamic>(
                  stream: domainStream.stream,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        if (snapshot.hasData) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return TextButton(
                                  onPressed: () {
                                    GoRouter.of(context).pushNamed(
                                        returnPushName(
                                            snapshot.data[index]['domain']),
                                        params: {
                                          'id': snapshot.data[index]['id']
                                        });
                                  },
                                  child: Text(snapshot.data[index]['domain']));
                            },
                          );
                        }
                    }
                    return Text('');
                  }),
            ),
            TextButton(
                onPressed: () {
                  GoRouter.of(context).pushNamed('setup');
                },
                child: Center(
                  child: Text(
                      'Change Exam - ${returnBoardName(Provider.of<loadingProvider>(context, listen: true).getboardId)}'),
                ))
          ],
        ),
        color: Theme.of(context).cardColor,
      ),
    ),
  );
}
