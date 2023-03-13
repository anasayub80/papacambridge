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

class MainFolderRes {
  var id;
  var alias;
  var urlStructure;

  MainFolderRes({
    required this.id,
    required this.alias,
    this.urlStructure,
  });

  factory MainFolderRes.fromJson(Map<String, dynamic> json) {
    return MainFolderRes(
      id: json['id'] as int,
      alias: json['alias'] as String,
      urlStructure: json['url_structure'] as String,
    );
  }
}
