// To parse this JSON data, do
//
//     final mainFolder = mainFolderFromJson(jsonString);

import 'dart:convert';

List<MainFolder> mainFolderFromJson(String str) =>
    List<MainFolder>.from(json.decode(str).map((x) => MainFolder.fromJson(x)));

String mainFolderToJson(List<MainFolder> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MainFolder {
  MainFolder({
    this.id,
    this.name,
    this.active,
    this.parent,
    this.folder,
    this.urlPdf,
    this.keyword,
    this.paper,
    this.folderCode,
    this.weather,
    this.year,
  });

  var id;
  String? name;
  int? active;
  int? parent;
  int? folder;
  String? urlPdf;
  String? keyword;
  String? paper;
  String? folderCode;
  dynamic weather;
  dynamic year;

  factory MainFolder.fromJson(Map<String, dynamic> json) => MainFolder(
        id: json["id"],
        name: json["name"],
        active: json["active"],
        parent: json["parent"],
        folder: json["folder"],
        urlPdf: json["url_pdf"],
        keyword: json["keyword"],
        paper: json["paper"],
        folderCode: json["folder_code"],
        weather: json["weather"],
        year: json["year"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "active": active,
        "parent": parent,
        "folder": folder,
        "url_pdf": urlPdf,
        "keyword": keyword,
        "paper": paper,
        "folder_code": folderCode,
        "weather": weather,
        "year": year,
      };
}
