// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:studento/UI/error_report_dialog.dart';
import 'package:studento/UI/show_message_dialog.dart';
import 'package:studento/utils/pdf_helper.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:studento/UI/loading_indicator.dart';
import '../utils/ads_helper.dart';

// ignore: must_be_immutable
class MultiPaperView extends StatefulWidget {
  final String url1;
  String url2;

  MultiPaperView(
      {required this.url1,
      required this.fileName1,
      required this.url2,
      required this.fileName2,
      required this.boarId,
      required this.isOthers});
  final String fileName1;
  final String fileName2;
  final bool isOthers;
  final String boarId;
  @override
  _MultiPaperViewState createState() => _MultiPaperViewState();
}

class _MultiPaperViewState extends State<MultiPaperView> {
  /// Whether all data has been loaded.
  bool isLoaded = false;

  /// Whether the file to be displayed has been downloaded.
  bool isFileAlreadyDownloaded1 = false;
  bool isFileAlreadyDownloaded2 = false;

  /// Whether the file is currently being downloaded.
  bool downloading1 = false;
  bool downloading2 = false;

  /// The percentage of the download completed.
  var progress = "0%";

  // Whether the pdfView has finished rendering the pdf.
  bool isRendered1 = false;
  bool isRendered2 = false;

  // Error message from the pdfViewer log
  String errorMessage = "";

  /// The path where the downloaded file is saved. Includes the file's name!
  String? filePath1;
  String? filePath2;

  /// Whether the file we're loading is a question paper
  /// or a marking scheme. Set to true at the start as first the QP is opened.
  /// This value will be toggled when the switch button is pressed.
  // bool isQP = true;

  // InterstitialAd _interstitialAd;

  String? urlInUse;
  String? msUrlInUse;
  showMyDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return LoadingIndicator(progress, loadingText: "Loading: ");
      },
    );
  }

  late String _fileName1;
  late String _fileName2;
  GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  // late bool _isPro;
  Random random = Random();
  @override
  void initState() {
    super.initState();
    print("File name 1${widget.fileName1} & ${widget.url1}");
    print("File name 2${widget.fileName2} & ${widget.url2}");
    _fileName1 = prettifySubjectName(widget.fileName1);
    _fileName2 = prettifySubjectName(widget.fileName2);

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
  }

  String prettifySubjectName(String subjectName) {
    return subjectName.replaceFirst("\r\n", "");
  }

  InterstitialAd? _interstitialAd;

  // int? currentPage = 0;
  double _firstContainerHeight = 0.5;
  double _secondContainerHeight = 0.5;

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    Size size = MediaQuery.of(context).size;
    if (isLoaded) {
      //&& _isPro != null
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.fileName1,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.0,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: (_firstContainerHeight * 100).round(),
              child: PDFView(
                filePath: filePath1,
                pageFling: false,
                pageSnap: false,
                onPageChanged: (int? page, int? total) {
                  print('page change: $page/$total');
                },
                onRender: (x) {
                  debugPrint('rendering');
                  setState(() => isRendered1 = true);
                },
                onError: (error) {
                  handlePdfLoadError(error.toString());
                },
                onPageError: (page, error) {
                  handlePdfLoadError(error.toString());
                },
              ),
            ),
            Expanded(
              flex: (_secondContainerHeight * 100).round(),
              child: Column(
                children: [
                  Container(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          prettifySubjectName(widget.fileName2),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    height: 48,
                    color: Color(0xff6C63FF),
                  ),
                  Expanded(
                    child: PDFView(
                      filePath: filePath2,
                      pageFling: false,
                      pageSnap: false,
                      fitEachPage: true,
                      enableSwipe: true,
                      onPageChanged: (int? page, int? total) {
                        print('page change: $page/$total');
                      },
                      onRender: (x) {
                        debugPrint('rendering');
                        setState(() => isRendered2 = true);
                        // Navigator.pop(context);
                      },
                      onError: (error) {
                        handlePdfLoadError(error.toString());
                      },
                      onPageError: (page, error) {
                        handlePdfLoadError(error.toString());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return LoadingIndicator(
      progress,
      loadingText: (isFileAlreadyDownloaded1 && isFileAlreadyDownloaded2)
          ? "Loading: "
          : "Downloading: ",
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  /// Check if papers are already downloaded, and download if not.
  void initPapers() async {
    var path1 = await PdfHelper.getFilePath(_fileName1);
    var path2 = await PdfHelper.getFilePath(_fileName2);
    setState(() => {filePath1 = path1, filePath2 = path2});

    print("$path1 & $path2");
    isFileAlreadyDownloaded1 = await PdfHelper.checkIfDownloaded(_fileName1);
    isFileAlreadyDownloaded2 = await PdfHelper.checkIfDownloaded(_fileName2);
    if (isFileAlreadyDownloaded1 && isFileAlreadyDownloaded2) {
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
        await downloadFile(filePath1!, filePath2!);
      } else {
        // ignore: use_build_context_synchronously
        PdfHelper.handleNoConnection(context);
      }
    }
  }

  Future<bool> filterInvalidUrls() async {
    Dio dio = Dio(PdfHelper.pdfDownloadOpt);
    int p = 0;

    // for (var url in widget.url1) {
    p++;
    setState(() => progress = "$p%");

    try {
      await dio.head(widget.url1);
      await dio.head(widget.url2);
      return true;
    } catch (e) {
      debugPrint('Invalid url ${e.toString()}');
    }

    return false;
  }

  Future<void> downloadFile(String filePath1, String filePath2) async {
    setState(() => {downloading1 = true, downloading2 = true});
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
      widget.url1,
      filePath1,
      onReceiveProgress: (received, total) {
        var percentage = ((received / total) * 100);
        setState(() {
          downloading1 = true;
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
    await dio.download(
      // (isQP) ? urlInUse! : msUrlInUse!,
      widget.url2,
      filePath2,
      onReceiveProgress: (received, total) {
        var percentage = ((received / total) * 100);
        setState(() {
          downloading2 = true;
          if (percentage >= 0) {
            // progress = "${percentage.toStringAsFixed(0)}%";
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
        isFileAlreadyDownloaded1 = true;
        isFileAlreadyDownloaded2 = true;
        downloading1 = false;
        downloading2 = false;
        isLoaded = true;
      });
    }
  }

  void handlePdfLoadError(String errorMsg) async {
    await showMessageDialog(
      context,
      msg: errorMsg,
      title: "Load Failed",
    ).then((v) => Navigator.pop(context));
    PdfHelper.deleteFile(filePath1!);
    PdfHelper.deleteFile(filePath2!);
  }

  Future<void> handleNotFoundError() async {
    const String errorMsg =
        """Looks like digital bookworms ate our copy of this PDF 😢.

You can file an issue if you really need it, and we'll try our best to get it to you.""";

    final emailBody = "Hi, I'd like to access the following paper: $_fileName1";
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
