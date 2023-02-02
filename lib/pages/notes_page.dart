import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../UI/mainFilesList.dart';
import '../UI/studento_app_bar.dart';
import '../UI/web_appbar.dart';
import '../provider/loadigProvider.dart';
import '../utils/theme_provider.dart';
import 'searchPage.dart';

// ignore: must_be_immutable
class NotesPage extends StatefulWidget {
  String? domainId;
  NotesPage({this.domainId});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
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
                title: "Notes",
                context: context,
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return SearchPage(
                              domainId: widget.domainId!,
                              domainName: "Notes",
                            );
                          },
                        ));
                      },
                      icon: Icon(Icons.search))
                ],
              ),
        body: mainFilesList(
          domainId: widget.domainId,
          title: 'Notes',
          domainName: 'notes',
        ));
  }
}
