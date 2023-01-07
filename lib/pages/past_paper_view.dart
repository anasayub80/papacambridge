// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:studento/UI/error_report_dialog.dart';
import 'package:studento/UI/show_message_dialog.dart';
import 'package:studento/utils/pdf_helper.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:studento/UI/loading_indicator.dart';

import '../UI/studento_app_bar.dart';

class PastPaperView extends StatefulWidget {
  final List<String> urls;

  const PastPaperView(this.urls, this.fileName, this.boarId);
  final String fileName;
  final String boarId;
  @override
  _PastPaperViewState createState() => _PastPaperViewState();
}

class _PastPaperViewState extends State<PastPaperView> {
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

  String? urlInUse;
  String? msUrlInUse;

  late String _fileName;
  GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  // late bool _isPro;

  @override
  void initState() {
    print("past paper view fileName ${widget.fileName}");
    super.initState();
    print(widget.fileName);
    _fileName = widget.fileName;

    initPapers();
    // loadDocs();
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
          centerTitle: false,
          title: (isQP) ? widget.fileName : "Marking Scheme",
          actions: <Widget>[
            widget.boarId == '1'
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: StadiumBorder(),
                      ),
                      icon: Icon(
                        Icons.swap_horiz,
                        color: Colors.white,
                      ),
                      label: Text(
                        (isQP) ? "Open MS" : "Open QP",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => switchToPaperOrMS(context),
                    ),
                  )
                : SizedBox.shrink(),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                // PdfHelper.shareFile(filePath!, "paper");
                PdfHelper.shareFile(filePath!, "paper");
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            // hello.PDFViewer(
            //   document: document,
            //   zoomSteps: 1,
            // ),
            // if (isRendered)
            PDFView(
              filePath: filePath,
              pageFling: false,
              pageSnap: false,
              onRender: (x) {
                setState(() => isRendered = true);
              },
              onError: (error) {
                handlePdfLoadError(error.toString());
              },
              onPageError: (page, error) {
                handlePdfLoadError(error.toString());
              },
            ),
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

  @override
  void dispose() {
    // _interstitialAd?.dispose();
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
            setState(() => isLoaded = true);
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

      if (!isQP) {
        url = url.replaceFirst("_qp_", "_ms_");
      }
      Response response = await dio.head(url).catchError((Object error) {});

      if (response.statusCode == 200 &&
          response.headers.value(Headers.contentTypeHeader) ==
              "application/pdf") {
        setState(() => (isQP) ? urlInUse = url : msUrlInUse = url);
        return true;
      }
    }

    return false;
  }

  Future<void> downloadFile(String filePath) async {
    setState(() => downloading = true);
    Dio dio = Dio(PdfHelper.pdfDownloadOpt);
    if (isQP && urlInUse == null || !isQP && msUrlInUse == null) {
      bool fileAvailable = await filterInvalidUrls();
      if (!fileAvailable) {
        await handleNotFoundError();
        return;
      }
    }

    await dio.download(
      (isQP) ? urlInUse! : msUrlInUse!,
      filePath,
      onReceiveProgress: (received, total) {
        var percentage = ((received / total) * 100);
        setState(() {
          downloading = true;
          if (percentage >= 0) {
            progress = "${percentage.toStringAsFixed(0)}%";
          }
        });
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
        """Looks like digital bookworms ate our copy of this PDF 😢.

You can file an issue if you really need it, and we'll try our best to get it to you.""";

    final emailBody = "Hi, I'd like to access the following paper: $_fileName";
    await showDialog(
      context: context,
      builder: (_) => ErrorReportDialog(
        errorTitle: "Paper Not Found!",
        errorMsg: errorMsg,
        ctaButtonLabel: "Request Paper",
        emailBody: emailBody,
      ),
    );
  }

  // InterstitialAd createInterstitialAd() => InterstitialAd(
  //       adUnitId: ads.interstitialAdUnitId,
  //       targetingInfo: ads.targetingInfo,
  //       listener: (event) {
  //         if (event == MobileAdEvent.loaded) {
  //           _scaffoldKey.currentState.showSnackBar(SnackBar(
  //             content: Text(
  //               "Showing ad...",
  //               textAlign: TextAlign.center,
  //             ),
  //             behavior: SnackBarBehavior.floating,
  //             backgroundColor: Colors.grey.shade800,
  //           ));
  //           _interstitialAd.show();
  //         }
  //       },
  //     );
}