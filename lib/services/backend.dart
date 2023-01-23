import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

const token = 'C8xWxGvIue37SwP2MEU7W5oKE32fm7Z3JxHfeK897a8eE0SdLl';
const boardApi =
    'https://pastpapers.papacambridge.com/api/api.php?page=select_board';
const domainApi =
    'https://pastpapers.papacambridge.com/api/api.php?page=domains';
const innerFileApi =
    'https://pastpapers.papacambridge.com/api/api.php?page=inner_file';
const mainFileApi =
    'https://pastpapers.papacambridge.com/api/api.php?page=main_file';
const searchSubjectApi =
    'https://pastpapers.papacambridge.com/api/api.php?page=search';
const levelApi =
    'https://pastpapers.papacambridge.com/api/api.php?page=inner_file';
const caeiAPI = 'https://api.papacambridge.com/api-caie.php';
// const subjectApi =
//     'https://papacambridge.redrhinoz.com/api.php?page=inner_file';

class backEnd {
  fetchBoard() async {
    http.Response res = await http.post(Uri.parse(boardApi), body: {
      'token': token,
    });
    if (res.statusCode == 200) {
      if (res.body.isNotEmpty) {
        var response = jsonDecode(res.body.toString());
        print(response);
        return response;
      } else {
        print('Something Wrong');
      }
    }
  }

  fetchLevels(boardId) async {
    debugPrint('Board Id $boardId');

    http.Response res = await http.post(Uri.parse(levelApi), body: {
      'token': token,
      'domain': boardId ?? 'none',
    });
    if (res.statusCode == 200) {
      if (res.body.isNotEmpty) {
        var response = jsonDecode(res.body.toString());
        print(response);
        return response;
      } else {
        print('Something Wrong');
      }
    }
  }

  fetchDomains(boardId) async {
    debugPrint('board id is $boardId');
    http.Response res = await http.post(Uri.parse(domainApi), body: {
      'token': token,
      'board': boardId,
    });
    if (res.statusCode == 200) {
      if (res.body.isNotEmpty) {
        if (res.body.length <= 64) {
          // no data found
          return null;
        } else {
          var response = jsonDecode(res.body.toString());
          debugPrint("innerFile Response $response");
          return response;
        }
      } else {
        print('Something Wrong');
      }
    }
  }

  fetchMainFiles(domainId) async {
    debugPrint('domainId is $domainId');
    http.Response res = await http.post(Uri.parse(mainFileApi), body: {
      'token': token,
      'domain': domainId,
    });
    if (res.statusCode == 200) {
      if (res.body.isNotEmpty) {
        var response = jsonDecode(res.body.toString());
        debugPrint("domain Response $response");
        return response;
      } else {
        print('Something Wrong');
      }
    }
  }

  fetchInnerFiles(fileid) async {
    debugPrint('fileid is $fileid');
    http.Response res = await http.post(Uri.parse(innerFileApi), body: {
      'token': token,
      'fileid': fileid,
    });
    if (res.statusCode == 200) {
      if (res.body.isNotEmpty) {
        log(res.body.length.toString());
        if (res.body.length <= 64) {
          // no data found
          return null;
        } else {
          var response = jsonDecode(res.body.toString());
          debugPrint("innerFile Response $response");
          return response;
        }
      } else {
        print('Something Wrong');
      }
    }
  }
}
