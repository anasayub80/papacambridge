import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:studento/pages/past_paper_view.dart';
import 'package:studento/pages/syllabus.dart';
import 'package:studento/services/backend.dart';
import 'package:url_launcher/url_launcher.dart';

import '../UI/studento_app_bar.dart';
import '../model/MainFolder.dart';
import 'other_fileView.dart';

class innerfileScreen extends StatefulWidget {
  final inner_file;
  final title;
  const innerfileScreen(
      {super.key, required this.inner_file, required this.title});

  @override
  State<innerfileScreen> createState() => _innerfileScreenState();
}

class _innerfileScreenState extends State<innerfileScreen> {
  // String returnfileName(String url) {
  //   var find = "";
  //   switch (widget.title) {
  //     case 'Past Papers':
  //       find =
  //           'https://pastpapers.papacambridge.com/directories/OCR/OCR-pastpapers/upload/';
  //       break;
  //     case 'E-Books':
  //       find =
  //           'https://ebooks.papacambridge.com/directories/OCR/OCR-ebooks/upload/';
  //       break;
  //     default:
  //   }
  //   final replaceWith = '';
  //   final fileName = url.replaceAll(find, replaceWith);
  //   return fileName;
  // }

  var mytotalAmount = '';

  var listUpdate = false;

  void updateList(List list) {
    setState(() {
      listUpdate = true;
      foodItems = list;
    });
  }

  List foodItems = [];

  var url;

  @override
  Widget build(BuildContext context) {
    /// Open the Paper in the PastPaperView.
    void openPaper(String url, fileName) async {
      // List<String> moreUrls = [];

      print("url file $url");
      // moreUrls.add(url);
      print('kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk');
      // print(moreUrls);
      print('lllllllllllllllllllllllllllllllllllllll');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PastPaperView(
            [
              url,
            ],
            fileName,
          ),
        ),
      );
    }

    // void launchSyllabusView(MainFolder subject) {
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (_) => SyllabusPdfView(subject, ''),
    //       ));
    // }

    return Scaffold(
      appBar: StudentoAppBar(
        title: widget.title,
        context: context,
      ),
      body: FutureBuilder<dynamic>(
        future: backEnd().fetchInnerFiles(widget.inner_file),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data == null) {
            return Center(
              child: Text(
                'No Data Found',
                style: Theme.of(context).textTheme.headline4,
              ),
            );
          } else if (snapshot.hasData) {
            // if (snapshot.data[0]['name'] != null) {

            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                // url = snapshot.data[0]['link'] == ""
                //     ? snapshot.data[1]['link']
                //     : snapshot.data[0]['link'];
                return ListTile(
                  onTap: () {
                    if (snapshot.data[index]['url_pdf'] == "") {
                      debugPrint('newScreen');
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return innerfileScreen(
                            inner_file: snapshot.data[index]['id'],
                            title: widget.title,
                          );
                        },
                      ));
                    } else {
                      if (widget.title == "Syllabus") {
                        // launchSyllabusView(subject)
                        log('Syllabus Inner file');
                      } else {
                        snapshot.data[index]['url_pdf']
                                .toString()
                                .contains('.pdf')
                            ? openPaper(snapshot.data[index]['url_pdf'],
                                snapshot.data[index]['name'] ?? 'fileName')
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OtherFilesViewPage(
                                    [
                                      snapshot.data[index]['url_pdf'],
                                    ],
                                    snapshot.data[index]['name'] ?? 'fileName',
                                    snapshot.data[index]['id'] ?? 'fileName',
                                  ),
                                ),
                              );

                        // snapshot.data[index]['url_pdf']
                        //         .toString()
                        //         .contains('.doc')
                        //     ? _launchURL(snapshot.data[index]['url_pdf'])
                        //     : 'assets/icons/folder.png';
                        // openPaper(snapshot.data[index]['url_pdf'],
                        //     snapshot.data[index]['name'] ?? 'fileName');
                      }
                    }
                  },
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(snapshot.data[index]['url_pdf']
                            .toString()
                            .contains('.pdf')
                        ? 'assets/icons/pdf.png'
                        : snapshot.data[index]['url_pdf']
                                .toString()
                                .contains('.doc')
                            ? 'assets/icons/doc.png'
                            : 'assets/icons/folder.png'),
                  ),
                  // subtitle: Text(snapshot.data[index]['id']),
                  title: Text(
                    snapshot.data[index]['name'] ??
                        snapshot.data[index]['name'] ??
                        'fileName',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            );

            // }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
