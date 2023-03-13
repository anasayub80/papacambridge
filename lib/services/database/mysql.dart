import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:studento/model/MainFolder.dart';
import 'dart:developer' as dv;

import '../../model/mainFolderRes.dart';

class Mysql {
  static String host = '190.2.136.152',
      user = 'pc-my-account',
      password = 'beqjen-Temcaw-gesso4',
      db = 'papacambridge_myaccount';
  static int portid = 3306;

  Future<MySqlConnection> getConnection() async {
    var settings = ConnectionSettings(
      host: host,
      port: portid,
      user: user,
      password: password,
      db: db,
    );
    return await MySqlConnection.connect(settings);
  }

  fetchDomainds(boardid) async {
    try {
      var conn = await getConnection();
      String sql =
          // ignore: use_build_context_synchronously
          "SELECT * from setting where board_id='$boardid'";
      print(sql);
      var result = await conn.query(sql);
      if (result.isNotEmpty) {
        var data = result.toList().map((e) => e.fields).toList();
        dv.log("response ${data.toString()}");
        await conn.close();
        return data;
      } else {
        dv.log("null data");
      }
    } catch (e) {
      dv.log(e.toString());
    }
  }

  // fetchMainFile(domain) async {
  //   try {
  //     var conn = await getConnection();
  //     String sql =
  //         // ignore: use_build_context_synchronously
  //         "SELECT id, alias,url_structure from files where domain='$domain' and parent=0  and folder=1 and active=1 Limit 2";
  //     print(sql);
  //     var result = await conn.query(sql);
  //     if (result.isNotEmpty) {
  //       // var data = result.toList().map((e) => e.fields).toList();
  //       // debugPrint("response $data");
  //       final mainFolderResList = result.map((row) {
  //         return MainFolderRes.fromJson({
  //           'id': row['id'],
  //           'alias': row['alias'],
  //           'url_structure': row['url_structure'],
  //         });
  //       }).toList();
  //       await conn.close();
  //       return mainFolderResList;
  //     } else {
  //       dv.log("null data");
  //     }
  //   } catch (e) {
  //     dv.log(e.toString());
  //   }
  // }
  Future<List<MainFolderRes>> fetchMainFolderRes(var domain) async {
    try {
      var conn = await getConnection();
      String sql =
          // ignore: use_build_context_synchronously
          "SELECT id, alias,url_structure from files where domain='$domain' and parent=0  and folder=1 and active=1";
      var result = await conn.query(sql);
      if (result.isNotEmpty) {
        final mainFolderResList = result.map((row) {
          dv.log("row ${row['id']} & ${row['alias']}");
          return MainFolderRes.fromJson({
            'id': row['id'],
            'alias': row['alias'].toString(),
            'url_structure': row['url_structure'].toString(),
          });
        }).toList();
        await conn.close();
        return mainFolderResList;
      } else {
        return []; // Return an empty list when there is no data to return
      }
    } catch (e) {
      dv.log(e.toString());
      return []; // Return an empty list when an error occurs
    }
  }

  List<MainFolder?>? mainFolderResList;

  Future<List<MainFolder>> fetchInnerFile(var fileid) async {
    try {
      var conn = await getConnection();
      String sql =
          // ignore: use_build_context_synchronously
          "SELECT * from files where parent=$fileid";
      var result = await conn.query(sql);
      if (result.isNotEmpty) {
        // for (var res in result) {
        //   mainFolderResList!;
        // }

        final mainFolderResList = result.map((row) {
          // var fetchLink;
          // var url =
          //     "https://${fetchLink['websiteurl']}/${fetchLink['path_folder']}upload/${row['name']}";
          MainFolder res = MainFolder.fromJson({
            'id': row['id'],
            'name': row['alias'].toString(),
            'url_pdf': row['folder'] == 1 ? "" : row['url_pdf'],
          });

          if (row['folder'] == 1) {
            dv.log('res folder ${row['url_pdf']}');
          } else {
            dv.log('res file ${row['url_pdf']}');
          }

          return res;
        }).toList();
        await conn.close();
        return mainFolderResList;
      } else {
        return []; // Return an empty list when there is no data to return
      }
    } catch (e) {
      dv.log(e.toString());
      return []; // Return an empty list when an error occurs
    }
  }
}
