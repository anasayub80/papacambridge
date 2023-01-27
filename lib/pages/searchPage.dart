import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:studento/pages/inner_files_screen.dart';
import '../model/MainFolder.dart';
import 'package:http/http.dart' as http;
import '../services/backend.dart';

// ignore: must_be_immutable
class SearchPage extends StatefulWidget {
  String domainId;
  String domainName;

  SearchPage({super.key, required this.domainId, required this.domainName});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<MainFolder> allItem = [];
  StreamController _streamController = BehaviorSubject();
  @override
  void dispose() {
    _streamController.close();
    allItem = [];
    _searchController.clear();
    super.dispose();
  }

  String prettifySubjectName(String subjectName) {
    return subjectName.replaceFirst("\r\n", "");
  }

  void initSubjects() async {
    _streamController.add('loading');
    allItem.clear();
    log(_searchController.text);
    http.Response res = await http.post(Uri.parse(searchSubjectApi), body: {
      'token': token,
      'domain': widget.domainId,
      'keyword': _searchController.text.trim(),
    });
    debugPrint(res.body);
    if (res.statusCode == 200) {
      if (res.body.isNotEmpty) {
        if (res.body.length <= 64) {
          print('Something Wrong');
        } else {
          List<MainFolder> dataL = mainFolderFromJson(res.body);
          setState(() {
            allItem = dataL;
          });
        }
      } else {
        print('Something Wrong');
      }
    }

    _streamController.add('event');
  }

  @override
  Widget build(BuildContext context) {
    print(widget.domainId);
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          style: Theme.of(context).textTheme.bodyText1,
          controller: _searchController,
          // onChanged: _onSearchFieldChanged,
          autocorrect: false,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter Subject Code",
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
        ),
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
              onPressed: () {
                if (_searchController.text.isNotEmpty &&
                    _searchController.text.trim().isNotEmpty) initSubjects();
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: StreamBuilder<dynamic>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.data == 'loading') {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Search result will appear here!',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            );
          } else if (allItem.isEmpty) {
            return Center(
              child: Text(
                'No Data Found',
                style: Theme.of(context).textTheme.headline4,
              ),
            );
          } else {
            return ListView.builder(
              itemCount: allItem.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    // if (widget.title != 'Syllabus') {
                    Navigator.push(
                        context,
                        innerfileScreen.getRoute(allItem[index].name!,
                            allItem[index].id, "widget.title", false));
                  },
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/icons/folder.png',
                    ),
                  ),
                  title: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(0),
                    child: Text(
                      prettifySubjectName(allItem[index].name!),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // subtitle: Text(allItem[index].id),
                );
              },
            );
          }
        },
      ),
    );
  }
}
