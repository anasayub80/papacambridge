import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

getBoardName(BuildContext context) async {
  // var board =
  //     await Provider.of<loadingProvider>(context, listen: false).boardname();
  // selectedboard = board;
}

List<String> boards = ['CAIE', 'OCR', 'CCEA', 'AQA', 'WJEC', 'IB', 'PEARSON'];
PreferredSize webAppBar(ThemeSettings themeProvider, BuildContext context) {
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
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      GoRouter.of(context).pushNamed(
                        returnPushName('Past Papers'),
                      );
                    },
                    child: Text("Past Papers")),
                TextButton(
                    onPressed: () {
                      GoRouter.of(context).pushNamed(
                        returnPushName('Notes'),
                      );
                    },
                    child: Text("Notes")),
                TextButton(
                    onPressed: () {
                      GoRouter.of(context).pushNamed(
                        returnPushName('E Books'),
                      );
                    },
                    child: Text("Ebooks")),
                TextButton(
                    onPressed: () {
                      GoRouter.of(context).pushNamed(
                        returnPushName('Syllabus'),
                      );
                    },
                    child: Text("Syllabus")),
                TextButton(
                    onPressed: () {
                      GoRouter.of(context).pushNamed(
                        returnPushName('Others'),
                      );
                    },
                    child: Text("Others")),
                TextButton(
                    onPressed: () {
                      GoRouter.of(context).pushNamed(
                        returnPushName('Timetable'),
                      );
                    },
                    child: Text("Timetable")),
                DropdownButton<String>(
                  items: boards.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem));
                  }).toList(),
                  value: Provider.of<loadingProvider>(context, listen: true)
                              .selectedboard !=
                          'none'
                      ? Provider.of<loadingProvider>(context, listen: true)
                          .selectedboard
                      : null,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  alignment: Alignment.center,
                  onChanged: (value) {
                    Provider.of<loadingProvider>(context, listen: false)
                        .saveBoard(returnboardid(value), value, true);
                  },
                )
              ],
            )
          ],
        ),
        color: Theme.of(context).cardColor,
      ),
    ),
  );
}
