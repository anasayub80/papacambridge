// import 'dart:convert';
// import 'dart:async';
// import 'dart:developer';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:studento/CAIE/subject_st_viewS.dart';
// import 'package:studento/UI/error_report_dialog.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:studento/UI/studento_app_bar.dart';
// import 'package:studento/model/MainFolder.dart';
// import 'package:studento/UI/loading_indicator.dart';
// import 'package:studento/UI/show_message_dialog.dart';
// import 'package:studento/utils/pdf_helper.dart';
// import '../UI/loading_page.dart';

// class SyllabusPageCAIE extends StatefulWidget {
//   @override
//   // ignore: library_private_types_in_public_api
//   _SyllabusPageCAIEState createState() => _SyllabusPageCAIEState();
// }

// class _SyllabusPageCAIEState extends State<SyllabusPageCAIE> {
//   @override
//   void initState() {
//     super.initState();
//     getData();
//   }

//   List? level;
//   List? levelid;
//   initLevel() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     level = prefs.getStringList('level');
//     levelid = prefs.getStringList('levelid');
//     print(level.toString());
//     return level;
//   }

//   var selectedlevel;
//   getData() async {
//     Future.delayed(
//       Duration.zero,
//       () async {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) {
//             return AlertDialog(
//               backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//               title: Text('Select Level'),
//               content: FutureBuilder<dynamic>(
//                 future: initLevel(),
//                 builder: (context, snapshot) {
//                   switch (snapshot.connectionState) {
//                     case ConnectionState.waiting:
//                       return Center(child: CircularProgressIndicator());

//                     default:
//                       if (snapshot.hasError) {
//                         return Text('Error');
//                       } else if (snapshot.data != null) {
//                         return ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: level!.length,
//                           itemBuilder: (context, index) {
//                             return ListTile(
//                               onTap: () {
//                                 Navigator.pop(context, index);
//                               },
//                               title: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(level![index]),
//                               ),
//                             );
//                           },
//                         );
//                       } else {
//                         return loadingPage();
//                       }
//                   }
//                 },
//               ),
//             );
//           },
//         ).then((indexFromDialog) {
//           // use the value as you wish
//           print(
//               "Level Name ${level![indexFromDialog]}, Level Id ${levelid![indexFromDialog]}");
//           setState(() {
//             selectedlevel = levelid![indexFromDialog];
//           });
//           _streamController.add(selectedlevel);
//         });
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _streamController.close();
//     // ignore: todo
//     // TODO: implement dispose
//     super.dispose();
//   }

//   StreamController _streamController = StreamController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: StudentoAppBar(
//         title: "Syllabus",
//         context: context,
//       ),
//       body: StreamBuilder(
//         stream: _streamController.stream,
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//               return Center(child: CircularProgressIndicator());
//             default:
//               if (snapshot.hasError) {
//                 return Text('Error');
//               } else if (selectedlevel != null) {
//                 log(selectedlevel);
//                 return SubjectsStaggeredListViewSCAIE(
//                     launchSyllabusViewCAIE, selectedlevel);
//               } else {
//                 return loadingPage();
//               }
//           }
//         },
//       ),
//     );
//   }

//   void launchSyllabusViewCAIE(MainFolder subject) {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => SyllabusPdfViewCAIE(subject),
//         ));
//   }
// }

// selectlevel(BuildContext context) {
//   List? level;

//   initLevel() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     level = prefs.getStringList('level');
//     print(level.toString());
//     return level;
//   }

//   return showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         content: FutureBuilder<dynamic>(
//           future: initLevel(),
//           builder: (context, snapshot) {
//             switch (snapshot.connectionState) {
//               case ConnectionState.waiting:
//                 return Center(child: CircularProgressIndicator());

//               default:
//                 if (snapshot.hasError) {
//                   return Text('Error');
//                 } else if (snapshot.data != null) {
//                   return ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: level!.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         title: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(level![index]),
//                         ),
//                       );
//                     },
//                   );
//                 } else {
//                   return loadingPage();
//                 }
//             }
//           },
//         ),
//       );
//     },
//   );
// }

// class SyllabusPdfViewCAIE extends StatefulWidget {
//   const SyllabusPdfViewCAIE(this.subject);

//   final MainFolder subject;

//   @override
//   // ignore: library_private_types_in_public_api
//   _SyllabusPdfViewCAIEState createState() => _SyllabusPdfViewCAIEState();
// }

// class _SyllabusPdfViewCAIEState extends State<SyllabusPdfViewCAIE> {
//   /// List of urls for accessing syllabus.
//   Map? urlList;

//   /// Whether urlList has been loaded.
//   bool isUrlListLoaded = false;

//   /// The percentage of the download completed.
//   var progress = "0%";

//   String? url;

//   // InterstitialAd _interstitialAd;

//   /// Whether all data has been loaded.
//   bool isLoaded = false;

//   /// Whether the file to be displayed has been downloaded.
//   bool isFileAlreadyDownloaded = false;

//   /// Whether the file is currently being downloaded.
//   bool downloading = false;

//   // Whether the pdfView has finished rendering the pdf.
//   bool isRendered = false;

//   /// The path where the downloaded file is saved. Includes the file's name!
//   String? filePath;

//   bool shouldDownload = false;

//   bool? _isPro;

//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//     // PdfHelper.checkIfPro().then((isPro) {
//     //   setState(() => _isPro = isPro);
//     //   if (!_isPro!) {
//     //     // _interstitialAd?.dispose();
//     //     // _interstitialAd = createInterstitialAd()..load();
//     //   }
//     // });
//     loadStuff();
//   }

//   Future<void> loadStuff() async {
//     var isLoadedSuccess = await loadSyllabusUrl();
//     if (!isLoadedSuccess) {
//       handleNotFoundError();
//       return;
//     }

//     var path =
//         await PdfHelper.getFilePath("${widget.subject.name}_syllabus.pdf");
//     setState(() => filePath = path);

//     isFileAlreadyDownloaded = await PdfHelper.checkIfDownloaded(
//         "${widget.subject.name}_syllabus.pdf");
//     if (isFileAlreadyDownloaded) {
//       Future.delayed(
//         Duration(milliseconds: 500),
//         () {
//           if (mounted)
//             setState(() {
//               shouldDownload = true;
//               isLoaded = true;
//             });
//         },
//       );
//     } else {
//       var isConnected = await PdfHelper.checkIfConnected();
//       if (isConnected) {
//         await downloadSyllabus();
//       } else {
//         // ignore: use_build_context_synchronously
//         PdfHelper.handleNoConnection(context);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!isLoaded || !isFileAlreadyDownloaded
//         //  || _isPro == null
//         )
//       return LoadingIndicator(
//         progress,
//         loadingText: (downloading) ? "Downloading: " : "Loading: ",
//       );

//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: StudentoAppBar(
//         centerTitle: false,
//         context: context,
//         title: "${widget.subject.name} Syllabus",
//         actions: <Widget>[
//           Stack(
//             children: <Widget>[
//               Container(
//                 alignment: Alignment.center,
//                 padding: EdgeInsets.symmetric(horizontal: 20),
//                 child: IconButton(
//                   color: shouldDownload ? Colors.blue : Colors.blueGrey,
//                   icon: Visibility(
//                     visible: shouldDownload,
//                     child: Icon(Icons.cloud_done),
//                     replacement: Icon(Icons.cloud_download),
//                   ),
//                   onPressed: () async {
//                     if (_isPro!)
//                       setState(() => shouldDownload = !shouldDownload);
//                     else {
//                       var isNowPro =
//                           await Navigator.pushNamed(context, 'get_pro_page') ??
//                               false;
//                       if (isNowPro as bool) {
//                         setState(() {
//                           _isPro = isNowPro;
//                           shouldDownload = !shouldDownload;
//                         });
//                       }
//                     }
//                   },
//                 ),
//               )
//             ],
//           )
//         ],
//       ),
//       body: Stack(
//         children: <Widget>[
//           PDFView(
//             filePath: filePath,
//             pageFling: false,
//             pageSnap: false,
//             onRender: (x) => setState(() => isRendered = true),
//             onError: (error) {
//               handlePdfLoadError(
//                   "Pdf load failed. Please report the issue: ${error.toString().substring(0, 50)}...");
//             },
//             onPageError: (page, error) {
//               handlePdfLoadError(
//                   "Pdf load failed. Please report the issue: ${error.toString().substring(0, 50)}...");
//             },
//           ),
//           if (!isRendered) LoadingIndicator(progress, loadingText: "Loading: "),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // _interstitialAd?.dispose();
//     if (isFileAlreadyDownloaded && !shouldDownload)
//       PdfHelper.deleteFile(filePath!);
//     super.dispose();
//   }

//   /// Load subject's url frop local syllabus urlList.
//   Future<bool> loadSyllabusUrl() async {
//     var assetPath = 'assets/json/subjects_syllabus_urls.json';
//     String dataStr = await rootBundle.loadString(assetPath);
//     urlList = json.decode(dataStr);

//     String syllabusUrlPrefix = "http://www.cambridgeinternational.org/Images";
//     String uniqueSubjectUrlPath;
//     log('Folder Code ${widget.subject.folderCode}');
//     try {
//       uniqueSubjectUrlPath = urlList!["${widget.subject.folderCode}"]['url'];
//       setState(() {
//         url = "$syllabusUrlPrefix$uniqueSubjectUrlPath";
//         isUrlListLoaded = true;
//       });
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<bool> downloadSyllabus() async {
//     log('download syllabus CAIE called!~! $url');

//     Dio dio = Dio(PdfHelper.pdfDownloadOpt);

//     setState(() {
//       downloading = true;
//       progress = "2%";
//     });
//     // Response response =
//     //       await dio.head(url!).catchError((Object error) => handleNotFoundError());
//     try {
//       Response response = await dio.head(url!);
//       if (response.statusCode == 200 &&
//           response.headers.value(Headers.contentTypeHeader) ==
//               "application/pdf") {
//         await dio.download(
//           url!,
//           filePath,
//           onReceiveProgress: (received, total) {
//             var percentage = ((received / total) * 100);
//             setState(() {
//               downloading = true;
//               if (percentage >= 0) {
//                 progress = "${percentage.toStringAsFixed(0)}%";
//               }
//             });
//           },
//         ).catchError(
//           // ignore: invalid_return_type_for_catch_error
//           (Object error) => handlePdfLoadError(
//               "Looks like a network error occured. Please try again"),
//         );

//         if (mounted) {
//           setState(() {
//             isFileAlreadyDownloaded = true;
//             downloading = false;
//             isLoaded = true;
//           });
//         }

//         return true;
//       } else
//         handleNotFoundError();
//     } catch (e) {
//       log('try ${e.toString()}');
//       handleNotFoundError();
//     }

//     return false;
//   }

//   void handleNotFoundError() {
//     showDialog(
//       context: context,
//       builder: (_) => ErrorReportDialog(
//         errorTitle: "404 Not Found! 😔",
//         errorMsg:
//             "This subject either doesn't have a syllabi or we don't have a copy of it. Please report an issue if you really need it, and we'll try our best to get it to you.",
//         ctaButtonLabel: 'Request Syllabus',
//         emailBody:
//             "Hi, I'd like to access the syllabus for ${widget.subject.folderCode}",
//       ),
//     );
//   }

//   void handlePdfLoadError(String errorMsg) {
//     showMessageDialog(
//       context,
//       msg: errorMsg,
//       title: "Load Failed",
//     ).then((v) => Navigator.pop(context));
//     PdfHelper.deleteFile(filePath!);
//   }

//   // InterstitialAd createInterstitialAd() => InterstitialAd(
//   //       adUnitId: ads.interstitialAdUnitId,
//   //       targetingInfo: ads.targetingInfo,
//   //       listener: (event) {
//   //         if (event == MobileAdEvent.loaded) {
//   //           _scaffoldKey.currentState.showSnackBar(SnackBar(
//   //             content: Text(
//   //               "Showing ad...",
//   //               textAlign: TextAlign.center,
//   //             ),
//   //             behavior: SnackBarBehavior.floating,
//   //             backgroundColor: Colors.grey.shade800,
//   //           ));
//   //           _interstitialAd.show();
//   //         }
//   //       },
//   //     );
// }
