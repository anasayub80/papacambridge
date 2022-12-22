// To parse this JSON data, do
//
//     final filtered = filteredFromJson(jsonString);

import 'dart:convert';

List<Filtered> filteredFromJson(String str) =>
    List<Filtered>.from(json.decode(str).map((x) => Filtered.fromJson(x)));

String filteredToJson(List<Filtered> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Filtered {
  Filtered({
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

  int? id;
  String? name;
  int? active;
  int? parent;
  int? folder;
  String? urlPdf;
  String? keyword;
  dynamic paper;
  String? folderCode;
  String? weather;
  List<List<String>>? year;

  factory Filtered.fromJson(Map<String, dynamic> json) => Filtered(
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
        year: List<List<String>>.from(
            json["year"].map((x) => List<String>.from(x.map((x) => x)))),
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
        "year": List<dynamic>.from(
            year!.map((x) => List<dynamic>.from(x.map((x) => x)))),
      };
}
