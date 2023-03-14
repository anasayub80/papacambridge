import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class funHelper {
  String fileLogoAssets(String url) {
    log("my filter logo assets ${url.toString()}");
    if (url == '') {
      return 'assets/icons/folder.png';
    } else if (url.contains('.pdf')) {
      return 'assets/icons/pdf.png';
    } else if (url.contains('.doc')) {
      return 'assets/icons/doc.png';
    } else if (url.contains('.ppt')) {
      return 'assets/icons/ppt.png';
    } else if (url.contains('.mp3')) {
      return 'assets/icons/mp3.png';
    } else if (url.contains('.mp4')) {
      return 'assets/icons/mp4.png';
    } else if (url.contains('.zip')) {
      return 'assets/icons/zip.png';
    } else if (url.contains('.txt')) {
      return 'assets/icons/txt-file.png';
    } else if (url.contains('.xlsx')) {
      return 'assets/icons/xlsx.png';
    } else {
      return 'assets/icons/folder.png';
    }
  }

  bool heartFilter(var url) {
    // this is created for stop heart show in file
    if (url == '') {
      return true;
    } else {
      return false;
    }
  }

  bool pdfFilter(var url) {
    // this is created for stop heart show in file
    if (url.contains('.pdf')) {
      return true;
    } else {
      return false;
    }
  }

  checkifDataExist(String keyName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var res = prefs.getString(keyName);
    if (res != null) {
      debugPrint('Data Exist');
      var response = jsonDecode(res);
      return response;
    } else {
      debugPrint('Data not Exist');
      return null;
    }
  }

  updateApiData(int ApiData, int StoreData) {
    if (ApiData <= StoreData) {
      // no need to update
      return false;
    } else {
      // need to update
      return true;
    }
  }
}
