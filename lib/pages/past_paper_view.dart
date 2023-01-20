// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:studento/UI/error_report_dialog.dart';
import 'package:studento/UI/show_message_dialog.dart';
import 'package:studento/UI/studento_app_bar.dart';
import 'package:studento/utils/pdf_helper.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:studento/UI/loading_indicator.dart';

import '../utils/ads_helper.dart';

class PastPaperView extends StatefulWidget {
  final List<String> urls;

  const PastPaperView(this.urls, this.fileName, this.boarId, this.isOthers);
  final String fileName;
  final bool isOthers;
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
  // bool isQP = true;

  // InterstitialAd _interstitialAd;

  String? urlInUse;
  String? msUrlInUse;

  late String _fileName;
  GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  // late bool _isPro;
  Random random = Random();
  @override
  void initState() {
    print("past paper view fileName ${widget.fileName}");
    super.initState();
    print(widget.fileName);
    _fileName = prettifySubjectName(widget.fileName);

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
    initPapers();
    // loadDocs();
  }

  String prettifySubjectName(String subjectName) {
    return subjectName.replaceFirst("\r\n", "");
  }

  InterstitialAd? _interstitialAd;

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
          isFile: true,
          title: widget.fileName,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                // PdfHelper.shareFile(filePath!, "paper");
                PdfHelper.shareFile(filePath!, "paper");
              },
            ),
          ],
        ),
        // appBar: AppBar(
        //   title: Text(
        //     _fileName,
        //     style: TextStyle(
        //       fontWeight: FontWeight.w400,
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
        // StudentoAppBar(
        //   context: context,
        //   centerTitle: false,
        //   title: _fileName,
        //   // title: (isQP) ? widget.fileName : "Marking Scheme",
        //   actions: <Widget>[
        //     IconButton(
        //       icon: Icon(Icons.share),
        //       onPressed: () async {
        //         // PdfHelper.shareFile(filePath!, "paper");
        //         PdfHelper.shareFile(filePath!, "paper");
        //       },
        //     ),
        //   ],

        body: Stack(
          children: <Widget>[
            PDFView(
              filePath: filePath,
              pageFling: false,
              pageSnap: false,
              onRender: (x) {
                debugPrint('rendering');
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
      // if (!isQP) {
      // url = url.replaceFirst("_qp_", "_ms_");
      // log('my invalid url checker $url');
      // }
      try {
        await dio.head(url);
        return true;
      } catch (e) {
        debugPrint('Invalid url ${e.toString()}');
      }

      // if (response.statusCode == 200 &&
      //     response.headers.value(Headers.contentTypeHeader) ==
      //         "application/pdf") {
      //   setState(() => (isQP) ? urlInUse = url : msUrlInUse = url);
      //   return true;
      // }
    }

    return false;
  }

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

    await dio.download(
      // (isQP) ? urlInUse! : msUrlInUse!,
      widget.urls[0],
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
  // void switchToPaperOrMS(BuildContext context) {
  //   if (isQP) {
  //     _fileName = _fileName.replaceFirst("qp_", "ms_");
  //   } else {
  //     _fileName = _fileName.replaceFirst("ms_", "qp_");
  //   }

  //   setState(() {
  //     isQP = !isQP;
  //     isLoaded = false;
  //     isFileAlreadyDownloaded = false;
  //     isRendered = false;
  //     initPapers();
  //   });
  // }

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
