import 'dart:convert';

class HelpAndSupport {
  String? paragraph;
  String? status;
  String? title;

  HelpAndSupport({
    this.paragraph,
    this.status,
    this.title,
  });

  HelpAndSupport copyWith({
    String? paragraph,
    String? status,
    String? title,
  }) =>
      HelpAndSupport(
        paragraph: paragraph ?? this.paragraph,
        status: status ?? this.status,
        title: title ?? this.title,
      );

  factory HelpAndSupport.fromRawJson(String str) => HelpAndSupport.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HelpAndSupport.fromJson(Map<String, dynamic> json) => HelpAndSupport(
    paragraph: json["paragraph"],
    status: json["status"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "paragraph": paragraph,
    "status": status,
    "title": title,
  };
}
