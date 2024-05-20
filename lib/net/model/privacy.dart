import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Privacy {
  Timestamp? lastUpdate;
  String? paragraph;
  String? status;
  String? title;

  Privacy({
    this.lastUpdate,
    this.paragraph,
    this.status,
    this.title,
  });

  Privacy copyWith({
    Timestamp? lastUpdate,
    String? paragraph,
    String? status,
    String? title,
  }) =>
      Privacy(
        lastUpdate: lastUpdate ?? this.lastUpdate,
        paragraph: paragraph ?? this.paragraph,
        status: status ?? this.status,
        title: title ?? this.title,
      );

  factory Privacy.fromRawJson(String str) => Privacy.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Privacy.fromJson(Map<String, dynamic> json) => Privacy(
    lastUpdate: json["last_update"],
    paragraph: json["paragraph"],
    status: json["status"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "last_update": lastUpdate,
    "paragraph": paragraph,
    "status": status,
    "title": title,
  };
}
