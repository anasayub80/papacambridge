// // To parse this JSON data, do
// //
// //     final mainFolderRes = mainFolderResFromJson(jsonString);

// List<MainFolderRes> mainFolderResFromJson(String str) =>
//     List<MainFolderRes>.from(
//         json.decode(str).map((x) => MainFolderRes.fromJson(x)));

// String mainFolderResToJson(List<MainFolderRes> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class MainFolderRes {
//   MainFolderRes({
//     this.id,
//     this.alias,
//     this.urlStructure,
//   });

//   int? id;
//   String? alias;
//   String? urlStructure;

//   factory MainFolderRes.fromJson(Map<String, dynamic> json) => MainFolderRes(
//         id: json["id"],
//         alias: json["alias"],
//         urlStructure: json["url_structure"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "alias": alias,
//         "url_structure": urlStructure,
//       };
// }
// List<MainFolderRes> mainFolderResFromJson(String str) =>
//     List<MainFolderRes>.from(
//         json.decode(str).map((x) => MainFolderRes.fromJson(x)));

// String mainFolderResToJson(List<MainFolderRes> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class MainFolderRes {
//   MainFolderRes({
//     this.id,
//     this.alias,
//     this.urlStructure,
//   });

//   int? id;
//   String? alias;
//   String? urlStructure;

//   factory MainFolderRes.fromJson(Map<String, dynamic> json) {
//     return MainFolderRes(
//       id: json['id'],
//       alias: json['alias'],
//       urlStructure: json['url_structure'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['alias'] = this.alias;
//     data['url_structure'] = this.urlStructure;

//     return data;
//   }
// }
import 'dart:convert';

List<MainFolderRes> mainFolderResFromJson(String str) =>
    List<MainFolderRes>.from(
        json.decode(str).map((x) => MainFolderRes.fromJson(x)));

class MainFolderRes {
  var id;
  var alias;
  int count = 1;
  String? urlStructure;

  MainFolderRes({
    required this.id,
    this.alias,
    this.count = 1,
    this.urlStructure,
  });

  factory MainFolderRes.fromJson(Map<String, dynamic> json) {
    return MainFolderRes(
      id: json['id'] as int,
      count: json["count"] ?? 1,
      alias: json['alias'] as String,
      urlStructure: json['url_structure'] as String,
    );
  }
}
