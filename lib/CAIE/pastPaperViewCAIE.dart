// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studento/UI/error_report_dialog.dart';
import 'package:studento/UI/show_message_dialog.dart';
import 'package:studento/utils/ads_helper.dart';
import 'package:studento/utils/pdf_helper.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:studento/UI/loading_indicator.dart';

import '../UI/studento_app_bar.dart';

class PastPaperViewCAIE extends StatefulWidget {
  final List<String> urls;

  const PastPaperViewCAIE(this.urls, this.fileName, this.boarId, this.isOthers,
      this.type, this.ispastPaper);
  final String fileName;
  final bool isOthers;
  final bool ispastPaper;
  final bool type;
  final String boarId;
  @override
  _PastPaperViewCAIEState createState() => _PastPaperViewCAIEState();
}

class _PastPaperViewCAIEState extends State<PastPaperViewCAIE> {
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
  InterstitialAd? _interstitialAd;
  Random random = Random();
  @override
  void initState() {
    print("past paper view fileName ${widget.fileName}  ${widget.urls}");
    super.initState();
    print(widget.fileName);
    _fileName = widget.fileName;
    isQP = widget.type;
    initPapers();

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
    if (Platform.isAndroid) {
      platform = TargetPlatform.android;
    } else {
      platform = TargetPlatform.iOS;
    }
    checkFileDownloaded();
    // loadDocs();
  }

  bool isFullScreen = false;

  // hello.PDFDocument document;
  // loadDocs() async {
  //   document = await hello.PDFDocument.fromURL(
  //       "http://conorlastowka.com/book/CitationNeededBook-Sample.pdf");
  // }
  int? QPcurrentPage = 0;
  int? MScurrentPage = 0;
  bool isDownloaded = false;
  void checkFileDownloaded() async {
    // ignore: no_leading_underscores_for_local_identifiers
    var _path = await PdfHelper.getexternalFilePath(_fileName);
    isFileAlreadyDownloaded =
        await PdfHelper.checkIfDownloadedButton(_fileName);
    if (isFileAlreadyDownloaded) {
      Future.delayed(
        Duration(milliseconds: 500),
        () {
          if (mounted) {
            setState(() => isDownloaded = true);
          }
        },
      );
    } else {
      print('not exist $_path');
    }
  }

  late String _localPath;
  late TargetPlatform? platform;

  /// Check if papers are already downloaded, and download if not.
  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    print(_localPath);
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    if (platform == TargetPlatform.android) {
      return "/storage/emulated/0/Download";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return '${directory.path}${Platform.pathSeparator}Download';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaded) {
      //&& _isPro != null
      return Scaffold(
        key: _scaffoldKey,
        appBar: isFullScreen
            ? PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: SizedBox.shrink(),
              )
            : StudentoAppBar(
                context: context,
                isFile: true,
                actions: <Widget>[
                  widget.boarId == '1'
                      ? widget.ispastPaper == true
                          ? widget.isOthers == true
                              ? SizedBox.shrink()
                              : Padding(
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
                          : SizedBox.shrink()
                      : SizedBox.shrink(),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () async {
                      // PdfHelper.shareFile(filePath!, "paper");
                      PdfHelper.shareFile(filePath!, "paper");
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isDownloaded ? Icons.verified : Icons.download,
                      color: isDownloaded
                          ? Colors.green
                          : Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () async {
                      if (isDownloaded) {
                        BotToast.showText(
                            text: 'Already Downloaded!',
                            contentColor: Colors.green);
                      } else {
                        BotToast.showText(
                            text: 'Downloading Start!',
                            contentColor: Colors.green);
                        await _prepareSaveDir();
                        var path =
                            await PdfHelper.getexternalFilePath(_fileName);
                        await downloadFile(path);
                        BotToast.showText(
                            text: 'Downloaded', contentColor: Colors.green);
                      }
                    },
                  ),
                ],
              ),
        body: Stack(
          children: <Widget>[
            PDFView(
              filePath: filePath,
              pageFling: false,
              pageSnap: false,
              defaultPage: (isQP) ? QPcurrentPage! : MScurrentPage!,
              onRender: (x) {
                setState(() => isRendered = true);
              },
              onPageChanged: (int? page, int? total) {
                print('page change: $page/$total');
                if (isQP) {
                  setState(() {
                    QPcurrentPage = page;
                  });
                } else {
                  setState(() {
                    MScurrentPage = page;
                  });
                }
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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (isFullScreen) {
              FullScreen.exitFullScreen();
              setState(() {
                isFullScreen = false;
              });
              debugPrint('exit fullScreen ${isFullScreen.toString()}');
            } else {
              FullScreen.enterFullScreen(FullScreenMode.EMERSIVE);
              setState(() {
                isFullScreen = true;
              });
              debugPrint('enter fullScreen ${isFullScreen.toString()}');
            }
          },
          child: Icon(
            isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            color: Theme.of(context).iconTheme.color,
          ),
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
    if (isFullScreen) {
      debugPrint('exist fullScreen');
      FullScreen.exitFullScreen();
    }
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
        url = url.replaceFirst("qp", "ms");
      }
      Response response = await dio.head(url);

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
      checkFileDownloaded();
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
