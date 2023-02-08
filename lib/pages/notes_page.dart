import 'package:flutter/material.dart';
import '../UI/mainFilesList.dart';
import '../UI/studento_app_bar.dart';
import 'searchPage.dart';

// ignore: must_be_immutable
class NotesPage extends StatefulWidget {
  String domainId;
  NotesPage({required this.domainId});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: StudentoAppBar(
          title: "Notes",
          context: context,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return SearchPage(
                        domainId: widget.domainId,
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
