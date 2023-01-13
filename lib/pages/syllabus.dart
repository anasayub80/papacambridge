// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:developer';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:studento/UI/error_report_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:studento/UI/studento_app_bar.dart';
import 'package:studento/model/MainFolder.dart';
import 'package:studento/UI/loading_indicator.dart';
import 'package:studento/UI/show_message_dialog.dart';
import 'package:studento/utils/pdf_helper.dart';
import '../UI/mainFilesList.dart';
import '../services/backend.dart';
import '../utils/ads_helper.dart';

// List? level;

// ignore: must_be_immutable
class SyllabusPage extends StatefulWidget {
  String domainId;
  SyllabusPage({required this.domainId});
  @override
  _SyllabusPageState createState() => _SyllabusPageState();
}

class _SyllabusPageState extends State<SyllabusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: StudentoAppBar(
          title: "Syllabus",
          context: context,
        ),
        body: mainFilesList(domainId: widget.domainId, title: 'Syllabus'));
  }
}

class SyllabusPdfView extends StatefulWidget {
  const SyllabusPdfView(this.subject);

  final MainFolder subject;
  @override
  _SyllabusPdfViewState createState() => _SyllabusPdfViewState();
}

class _SyllabusPdfViewState extends State<SyllabusPdfView> {
  /// List of urls for accessing syllabus.
  Map? urlList;

  /// Whether urlList has been loaded.
  bool isUrlListLoaded = false;

  /// The percentage of the download completed.
  var progress = "0%";

  // String? url;

  // InterstitialAd _interstitialAd;

  /// Whether all data has been loaded.
  bool isLoaded = false;

  /// Whether the file to be displayed has been downloaded.
  bool isFileAlreadyDownloaded = false;

  /// Whether the file is currently being downloaded.
  bool downloading = false;

  // Whether the pdfView has finished rendering the pdf.
  bool isRendered = false;

  /// The path where the downloaded file is saved. Includes the file's name!
  String? filePath;

  bool shouldDownload = false;

  bool? _isPro;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Random random = Random();
  @override
  void initState() {
    super.initState();
    // PdfHelper.checkIfPro().then((isPro) {
    //   setState(() => _isPro = isPro);
    //   if (!_isPro!) {
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
    loadStuff();
  }

  Future<void> loadStuff() async {
    var isLoadedSuccess = await loadSyllabusUrl();
    if (!isLoadedSuccess) {
      handleNotFoundError();
      return;
    }

    var path = await PdfHelper.getFilePath("${pdfName}_syllabus.pdf");

    setState(() => filePath = path);

    isFileAlreadyDownloaded =
        await PdfHelper.checkIfDownloaded("${pdfName}_syllabus.pdf");
    if (isFileAlreadyDownloaded) {
      // The setState is wrapped in a [Future.delayed] so as to give enough
      // time for the pdf viewer to close. If this isn't done, the pdf viewer
      // wouldn't close before the widget is rebuilt, and would get stuck
      // on an infinite loading loop.
      Future.delayed(
        Duration(milliseconds: 500),
        () {
          if (mounted)
            setState(() {
              shouldDownload = true;
              isLoaded = true;
            });
        },
      );
    } else {
      var isConnected = await PdfHelper.checkIfConnected();
      if (isConnected) {
        await downloadSyllabus();
      } else {
        // ignore: use_build_context_synchronously
        PdfHelper.handleNoConnection(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (!isLoaded || !isFileAlreadyDownloaded || _isPro == null)
    if (!isLoaded || !isFileAlreadyDownloaded)
      return LoadingIndicator(
        progress,
        loadingText: (downloading) ? "Downloading: " : "Loading: ",
      );

    return Scaffold(
      key: _scaffoldKey,
      appBar: StudentoAppBar(
        centerTitle: false,
        context: context,
        title: "$pdfName Syllabus",
        // title: "${widget.subject.name} Syllabus",
        actions: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: IconButton(
                  color: shouldDownload ? Colors.blue : Colors.blueGrey,
                  icon: Visibility(
                    visible: shouldDownload,
                    child: Icon(Icons.cloud_done),
                    replacement: Icon(Icons.cloud_download),
                  ),
                  onPressed: () async {
                    if (_isPro!)
                      setState(() => shouldDownload = !shouldDownload);
                    else {
                      var isNowPro =
                          await Navigator.pushNamed(context, 'get_pro_page') ??
                              false;
                      if (isNowPro as bool) {
                        setState(() {
                          _isPro = isNowPro;
                          shouldDownload = !shouldDownload;
                        });
                      }
                    }
                  },
                ),
              )
            ],
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: filePath,
            pageFling: false,
            pageSnap: false,
            onRender: (x) => setState(() => isRendered = true),
            onError: (error) {
              handlePdfLoadError(
                  "Pdf load failed. Please report the issue: ${error.toString().substring(0, 50)}...");
            },
            onPageError: (page, error) {
              handlePdfLoadError(
                  "Pdf load failed. Please report the issue: ${error.toString().substring(0, 50)}...");
            },
          ),
          if (!isRendered) LoadingIndicator(progress, loadingText: "Loading: "),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    if (isFileAlreadyDownloaded && !shouldDownload)
      PdfHelper.deleteFile(filePath!);
    super.dispose();
  }

  InterstitialAd? _interstitialAd;

  String? pdfurl;
  String? pdfName;

  /// Load subject's url frop local syllabus urlList.
  Future<bool> loadSyllabusUrl() async {
    // var assetPath = 'assets/json/subjects_syllabus_urls.json';
    // String dataStr = await rootBundle.loadString(assetPath);
    // urlList = json.decode(dataStr);

    // String syllabusUrlPrefix = "http://www.cambridgeinternational.org/Images";
    // String uniqueSubjectUrlPath;
    print(widget.subject.id);
    var res = await backEnd().fetchInnerFiles(widget.subject.id);
    print('Syllabus Url res = $res');
    try {
      // uniqueSubjectUrlPath = urlList!["${widget.subject.folderCode}"]['url'];
      setState(() {
        pdfurl = res[0]['url_pdf'];
        pdfName = res[0]['name'];
        print("$pdfurl & $pdfName");
        isUrlListLoaded = true;
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> downloadSyllabus() async {
    print('download syllabus called!~! $pdfurl');
    Dio dio = Dio(PdfHelper.pdfDownloadOpt);
    // print("my pdfurl ${widget.subject.link!}");
    setState(() {
      downloading = true;
      progress = "2%";
    });
    // Response response =
    //       await dio.head(url!).catchError((Object error) => handleNotFoundError());
    try {
      // Response response = await dio.head(widget.subject.link!);
      Response response = await dio.head(pdfurl!);
      if (response.statusCode == 200 &&
          response.headers.value(Headers.contentTypeHeader) ==
              "application/pdf") {
        await dio.download(
          // widget.subject.link!,
          pdfurl!,
          filePath,
          onReceiveProgress: (received, total) {
            var percentage = ((received / total) * 100);
            print('increase progress ${percentage.toString()}');
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
            print('already downloded!!');
            isFileAlreadyDownloaded = true;
            downloading = false;
            isLoaded = true;
          });
        }
        return true;
      } else {
        print('status code error');
        handleNotFoundError();
      }
    } catch (e) {
      print('try error ${e.toString()}');
      handleNotFoundError();
    }

    return false;
  }

  void handleNotFoundError() {
    showDialog(
      context: context,
      builder: (_) => ErrorReportDialog(
        errorTitle: "404 Not Found! 😔",
        errorMsg:
            "This subject either doesn't have a syllabi or we don't have a copy of it. Please report an issue if you really need it, and we'll try our best to get it to you.",
        ctaButtonLabel: 'Request Syllabus',
        emailBody:
            "Hi, I'd like to access the syllabus for ${widget.subject.folderCode}",
      ),
    );
  }

  void handlePdfLoadError(String errorMsg) {
    showMessageDialog(
      context,
      msg: errorMsg,
      title: "Load Failed",
    ).then((v) => Navigator.pop(context));
    PdfHelper.deleteFile(filePath!);
  }

  void createInterstitialAd() {
    print('init created for Syllabus');
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
