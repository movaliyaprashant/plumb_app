import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AppComment {
  DocumentReference? addedBy;
  Timestamp? addedAt;
  String? type;
  String? comment;
  DocumentReference? contract;
  DocumentReference? timesheet;

  AppComment({
    this.addedBy,
    this.addedAt,
    this.type,
    this.comment,
    this.contract,
    this.timesheet,
  });

  AppComment copyWith({
    DocumentReference? addedBy,
    Timestamp? addedAt,
    String? type,
    String? comment,
    DocumentReference? contract,
    DocumentReference? timesheet,
  }) =>
      AppComment(
        addedBy: addedBy ?? this.addedBy,
        addedAt: addedAt ?? this.addedAt,
        type: type ?? this.type,
        comment: comment ?? this.comment,
        contract: contract ?? this.contract,
        timesheet: timesheet ?? this.timesheet,
      );

  factory AppComment.fromRawJson(String str) => AppComment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppComment.fromJson(Map<String, dynamic> json) => AppComment(
    addedBy: json["added_by"],
    addedAt: json["added_at"],
    type: json["type"],
    comment: json["comment"],
    contract: json["contract"],
    timesheet: json["timesheet"],
  );

  Map<String, dynamic> toJson() => {
    "added_by": addedBy,
    "added_at": addedAt,
    "type": type,
    "comment": comment,
    "contract": contract,
    "timesheet": timesheet,
  };
}
