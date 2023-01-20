// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:studento/UI/error_report_dialog.dart';
import 'package:studento/UI/show_message_dialog.dart';
import 'package:studento/UI/studento_app_bar.dart';
import 'package:studento/utils/pdf_helper.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import 'package:dio/dio.dart';
import 'package:studento/UI/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/ads_helper.dart';

class OtherFilesViewPage extends StatefulWidget {
  final List<String> urls;
  final String fileId;
  const OtherFilesViewPage(this.urls, this.fileName, this.fileId);
  final String fileName;

  @override
  _OtherFilesViewPageState createState() => _OtherFilesViewPageState();
}

class _OtherFilesViewPageState extends State<OtherFilesViewPage> {
  /// Whether all data has been loaded.
  bool isLoaded = false;

  /// Whether the file to be displayed has been downloaded.
  bool isFileAlreadyDownloaded = false;

  /// Whether the file is currently being downloaded.
  bool downloading = false;

  /// The percentage of the download completed.
  var progress = "0%";

  // Whether the pdfView has finished rendering the pdf.
  bool isRendered = false;

  // Error message from the pdfViewer log
  String errorMessage = "";

  /// The path where the downloaded file is saved. Includes the file's name!
  String? filePath;

  /// Whether the file we're loading is a question paper
  /// or a marking scheme. Set to true at the start as first the QP is opened.
  /// This value will be toggled when the switch button is pressed.
  bool isQP = true;

  // InterstitialAd _interstitialAd;
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  String? urlInUse;
  String? msUrlInUse;

  late String _fileName;
  GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  // late bool _isPro;
  Random random = Random();
  @override
  void initState() {
    print("other file view ${widget.urls}");
    super.initState();
    print(widget.fileName);
    _fileName = prettifySubjectName(widget.fileName);
    // PdfHelper.checkIfPro().then((isPro) {
    //   setState(() => _isPro = isPro);
    //   if (!_isPro) {
    int randomNumber = random.nextInt(5);
    switch (randomNumber) {
      case 2:
        _interstitialAd?.dispose();
        createInterstitialAd();
        break;
      case 4:
        _interstitialAd?.dispose();
        createInterstitialAd();
        break;
      default:
    }
    //   }
    // });
    initPapers();
    // loadDocs();
  }

  String prettifySubjectName(String subjectName) {
    return subjectName.replaceFirst("\r\n", "");
  }

  // hello.PDFDocument document;
  // loadDocs() async {
  //   document = await hello.PDFDocument.fromURL(
  //       "http://conorlastowka.com/book/CitationNeededBook-Sample.pdf");
  // }

  @override
  Widget build(BuildContext context) {
    if (isLoaded) {
      //&& _isPro != null
      return Scaffold(
        key: _scaffoldKey,
        appBar: StudentoAppBar(
          context: context,
          isFile: true,
          centerTitle: false,
          title: (isQP) ? widget.fileName : "Marking Scheme",
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                PdfHelper.shareFile(filePath!, "paper");
              },
            ),
          ],
        ),
        // appBar: AppBar(
        //   title: Text(
        //     (isQP) ? _fileName : "Marking Scheme",
        //     style: TextStyle(
        //       fontWeight: FontWeight.w400,
        //       // fontSize: 20.0,
        //       color: Theme.of(context).textTheme.bodyText1!.color,
        //     ),
        //     // textScaleFactor: 1.2,
        //   ),
        //   centerTitle: false,
        //   actions: <Widget>[
        //     IconButton(
        //       icon: Icon(Icons.share),
        //       onPressed: () async {
        //         // if (_isPro)
        //         PdfHelper.shareFile(filePath!, "paper");
        //       },
        //     ),
        //   ],
        // ),
        body: Stack(
          children: <Widget>[
            // hello.PDFViewer(
            //   document: document,
            //   zoomSteps: 1,
            // ),
            // if (isRendered)

            Center(
              child: TextButton(
                onPressed: () async {
                  var res = await OpenFilex.open(filePath);
                  print("print something ${res.message}");
                  if (res.message != 'done') {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          title: Text(
                            'No App Found',
                            textAlign: TextAlign.center,
                          ),
                          content: Text('No APP found to open this file'),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Close"),
                              onPressed: () => Navigator.of(context)
                                ..pop()
                                ..pop(),
                            ),
                            TextButton(
                              child: Text('Download'),
                              onPressed: () async {
                                if (widget.fileName.contains('zip')) {
                                  _launchUrl(Uri.parse(
                                      'https://play.google.com/store/apps/details?id=ru.zdevs.zarchiver'));
                                } else if (widget.fileName.contains('mp4')) {
                                  _launchUrl(Uri.parse(
                                      'https://play.google.com/store/apps/details?id=com.mxtech.videoplayer.ad'));
                                } else {
                                  _launchUrl(Uri.parse(
                                      'https://play.google.com/store/apps/details?id=cn.wps.moffice_eng'));
                                }
                              },
                            )
                          ],
                        );
                      },

                      //  ErrorReportDialog(
                      //   errorTitle: "404 Not Found! 😔",
                      //   errorMsg:
                      //       "This subject either doesn't have a syllabi or we don't have a copy of it. Please report an issue if you really need it, and we'll try our best to get it to you.",
                      //   ctaButtonLabel: 'Request Syllabus',
                      //   emailBody:
                      //       "Hi, I'd like to access the syllabus for ${widget.subject.folderCode}",
                      // ),
                    );
                  }
                },
                child: const Text('Tap to open file'),
              ),
            ),
            // PDFView(
            //   filePath: filePath,
            //   pageFling: false,
            //   pageSnap: false,
            //   onRender: (x) {
            //     setState(() => isRendered = true);
            //   },
            //   onError: (error) {
            //     handlePdfLoadError(error.toString());
            //   },
            //   onPageError: (page, error) {
            //     handlePdfLoadError(error.toString());
            //   },
            // ),
            if (!isRendered)
              LoadingIndicator(progress, loadingText: "Loading: "),
          ],
        ),
      );
    }

    return LoadingIndicator(
      progress,
      loadingText: (isFileAlreadyDownloaded) ? "Loading: " : "Downloading: ",
    );
  }

  InterstitialAd? _interstitialAd;

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  /// Check if papers are already downloaded, and download if not.
  void initPapers() async {
    // ignore: no_leading_underscores_for_local_identifiers
    var _path = await PdfHelper.getFilePath(_fileName);
    setState(() => filePath = _path);
    print('ppppppppppppppppppppppppppppp');
    print(_path);
    isFileAlreadyDownloaded = await PdfHelper.checkIfDownloaded(_fileName);
    if (isFileAlreadyDownloaded) {
      // The setState is wrapped in a [Future.delayed] so as to give enough
      // time for the pdf viewer to close. If this isn't done, the pdf viewer
      // wouldn't close before the widget is rebuilt, and would get stuck
      // on an infinite loading loop.
      Future.delayed(
        Duration(milliseconds: 500),
        () {
          if (mounted) {
            setState(() => {isLoaded = true, isRendered = true});
          }
        },
      );
    } else {
      var isConnected = await PdfHelper.checkIfConnected();
      if (isConnected) {
        await downloadFile(filePath!);
      } else {
        // ignore: use_build_context_synchronously
        PdfHelper.handleNoConnection(context);
      }
    }
  }

  Future<bool> filterInvalidUrls() async {
    Dio dio = Dio(PdfHelper.pdfDownloadOpt);
    int p = 0;

    for (var url in widget.urls) {
      p++;
      setState(() => progress = "$p%");

      try {
        await dio.head(url);
        return true;
      } catch (e) {
        debugPrint('Invalid url ${e.toString()}');
      }
    }

    return false;
  }
  // Future<bool> filterInvalidUrls() async {
  //   Dio dio = Dio(PdfHelper.pdfDownloadOpt);
  //   int p = 0;

  //   for (var url in widget.urls) {
  //     p++;
  //     setState(() => progress = "$p%");

  //     if (!isQP) {
  //       url = url.replaceFirst("_qp_", "_ms_");
  //     }
  //     Response response = await dio.head(url).catchError((Object error) {});

  //     if (response.statusCode == 200 &&
  //         response.headers.value(Headers.contentTypeHeader) ==
  //             "application/pdf") {
  //       setState(() => (isQP) ? urlInUse = url : msUrlInUse = url);
  //       return true;
  //     }
  //   }

  //   return false;
  // }

  Future<void> downloadFile(String filePath) async {
    setState(() => downloading = true);
    Dio dio = Dio(PdfHelper.pdfDownloadOpt);
    if (urlInUse == null || msUrlInUse == null) {
      // if (isQP && urlInUse == null || !isQP && msUrlInUse == null) {
      bool fileAvailable = await filterInvalidUrls();
      if (!fileAvailable) {
        await handleNotFoundError();
        return;
      }
    }
    // if (isQP && urlInUse == null || !isQP && msUrlInUse == null) {
    //   bool fileAvailable = await filterInvalidUrls();
    //   if (!fileAvailable) {
    //     await handleNotFoundError();
    //     return;
    //   }
    // }

    await dio.download(
      // (isQP) ? urlInUse! : msUrlInUse!,
      widget.urls[0],
      filePath,
      // onReceiveProgress: (received, total) {
      //   var percentage = ((received / total) * 100);

      //   setState(() {
      //     downloading = true;
      //     if (percentage >= 0) {
      //       progress = "${percentage.toStringAsFixed(0)}%";
      //     }
      //   });
      //   // if (int.parse(percentage.toStringAsFixed(0)) >= 100.0) {
      //   //   setState(() => isRendered = true);
      //   // }
      // },
      onReceiveProgress: (received, total) {
        var percentage = ((received / total) * 100);
        setState(() {
          downloading = true;
          if (percentage >= 0) {
            progress = "${percentage.toStringAsFixed(0)}%";
          }
        });
        if (int.parse(percentage.toStringAsFixed(0)) >= 100) {
          setState(() => isRendered = true);
        }
      },
    ).catchError(
      // ignore: invalid_return_type_for_catch_error
      (Object error) => handlePdfLoadError(
          "Looks like a network error occured. Please try again"),
    );

    if (mounted) {
      setState(() {
        isFileAlreadyDownloaded = true;
        downloading = false;
        isLoaded = true;
      });
    }
  }

  /// Depending on what's currently shown, switch to
  /// the past paper/marking scheme view.
  void switchToPaperOrMS(BuildContext context) {
    if (isQP) {
      _fileName = _fileName.replaceFirst("qp_", "ms_");
    } else {
      _fileName = _fileName.replaceFirst("ms_", "qp_");
    }

    setState(() {
      isQP = !isQP;
      isLoaded = false;
      isFileAlreadyDownloaded = false;
      isRendered = false;
      initPapers();
    });
  }

  void handlePdfLoadError(String errorMsg) async {
    await showMessageDialog(
      context,
      msg: errorMsg,
      title: "Load Failed",
    ).then((v) => Navigator.pop(context));
    PdfHelper.deleteFile(filePath!);
  }

  Future<void> handleNotFoundError() async {
    const String errorMsg =
        """Looks like digital bookworms ate our copy of this File 😢.

You can file an issue if you really need it, and we'll try our best to get it to you.""";

    final emailBody = "Hi, I'd like to access the following paper: $_fileName";
    await showDialog(
      context: context,
      builder: (_) => ErrorReportDialog(
        errorTitle: "Paper Not Found!",
        errorMsg: errorMsg,
        ctaButtonLabel: "Request File",
        emailBody: emailBody,
      ),
    );
  }

  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            // _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            _interstitialAd!.show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            // _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (numInterstitialLoadAttempts < 3) {
              createInterstitialAd();
            }
          },
        ));
  }
}
