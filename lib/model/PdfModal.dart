// To parse this JSON data, do
//
//     final pdfModal = pdfModalFromJson(jsonString);

import 'dart:convert';

List<PdfModal> pdfModalFromJson(String str) =>
    List<PdfModal>.from(json.decode(str).map((x) => PdfModal.fromJson(x)));

String pdfModalToJson(List<PdfModal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PdfModal {
  PdfModal({
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
  String? paper;
  String? folderCode;
  dynamic weather;
  dynamic year;

  factory PdfModal.fromJson(Map<String, dynamic> json) => PdfModal(
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
