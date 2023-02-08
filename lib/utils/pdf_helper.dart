// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:studento/UI/show_message_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class PdfHelper {
  /// Check if file downloaded, and load the file if so.
  static Future<bool> checkIfDownloaded(String fileName) async {
    var filePath = await getFilePath(fileName);
    var file = File(filePath);
    return await file.exists();
  }

  static checkIfDownloadeds(String fileName) {
    var filePath = getFilePath(fileName);
    var file = File(filePath.toString());
    return file.exists();
  }

  static Future<bool> checkIfDownloadedButton(String fileName) async {
    var filePath = await getexternalFilePath(fileName);
    var file = File(filePath);
    return await file.exists();
  }

  static Future<Future<FileSystemEntity>> deleteFile(String filePath) async {
    return File(filePath).delete();
  }

  // static Future<String> getFilePath(String fileName) async {
  //   var dir = await getExternalStorageDirectory();
  //   var knockDir =
  //       await Directory('${dir!.path}/PapaCambridge').create(recursive: true);
  //   return "${knockDir.path}/$fileName";
  // }

  static Future<String> getFilePath(String fileName) async {
    var dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/$fileName";
  }

  static Future<String> getexternalFilePath(String fileName) async {
    if (Platform.isAndroid) {
      return "/storage/emulated/0/Download/$fileName";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return '${directory.path}${Platform.pathSeparator}Download$fileName';
    }
    // return '${dir.path}${Platform.pathSeparator}Download/$fileName';
  }

  static void shareFile(String filePath, String pdfType) {
    Share.shareXFiles([XFile(filePath)],
        text: "Hi, here's the $pdfType", subject: "Share PDF");
  }

  // static Future<bool?> checkIfPro() async {
  //   var purchaserInfo = await Purchases.getCustomerInfo();
  //   UserData? userData = Hive.box<UserData>('userData').get(0);

  //   if (purchaserInfo != null) {
  //     userData!
  //       ..isPro = purchaserInfo.entitlements.active.containsKey("pro")
  //       ..save();
  //   }

  //   return userData!.isPro;
  // }

  /// Check if device has internet access.
  /// Note: will return a false positive if connected to a hotspot without
  /// internet.
  static Future<bool> checkIfConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    print("${connectivityResult.name != ConnectionState.none}");
    return (connectivityResult != ConnectivityResult.none);
  }

  static void handleNoConnection(BuildContext context) async {
    String errorMsg =
        "Houston, we have a problem.\n\nDownloading this file requires an internet connection. Please connect and try again.";
    await showMessageDialog(
      context,
      title: "No internet 😬",
      msg: errorMsg,
    );
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  static get pdfDownloadOpt => BaseOptions(
        connectTimeout: 6000,
        validateStatus: (statusCode) => statusCode == 200,
        receiveTimeout: 60000,
        receiveDataWhenStatusError: false,
      );
}
