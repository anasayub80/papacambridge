import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../UI/mainFilesList.dart';
import '../UI/studento_app_bar.dart';
import '../UI/web_appbar.dart';
import '../utils/theme_provider.dart';
import 'searchPage.dart';

// ignore: must_be_immutable
class NotesPage extends StatelessWidget {
  String domainId;
  NotesPage({required this.domainId});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSettings>(context, listen: false);
    return Scaffold(
        appBar: kIsWeb
            ? webAppBar(themeProvider, context)
            : StudentoAppBar(
                title: "Notes",
                context: context,
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return SearchPage(
                              domainId: domainId,
                              domainName: "Notes",
                            );
                          },
                        ));
                      },
                      icon: Icon(Icons.search))
                ],
              ),
        body: mainFilesList(
          domainId: domainId,
          title: 'Notes',
          domainName: 'notes',
        ));
  }
}
