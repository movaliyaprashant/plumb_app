import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Worker {
  String? firstName;
  String? lastName;
  DocumentReference? contractId;
  DocumentReference? added_by;
  String? classification;
  String? unionId;
  String? workerId;
  Timestamp? addedAt;
  Timestamp? updatedAt;
  bool? isActive;

  Worker({
    this.firstName,
    this.lastName,
    this.contractId,
    this.added_by,
    this.classification,
    this.unionId,
    this.workerId,
    this.addedAt,
    this.updatedAt,
    this.isActive
  });

  Worker copyWith({
    String? firstName,
    String? lastName,
    DocumentReference? contractId,
    DocumentReference? added_by,
    String? classification,
    String? unionId,
    String? workerId,
    Timestamp? addedAt,
    Timestamp? updatedAt,
    bool? isActive
  }) =>
      Worker(
        firstName: capitalize(firstName?? this.firstName),
        lastName: capitalize(lastName ?? this.lastName),
        contractId: contractId ?? this.contractId,
        added_by: added_by ?? this.added_by,
        classification: classification ?? this.classification,
        unionId: unionId ?? this.unionId,
        workerId: workerId ?? this.workerId,
        addedAt: addedAt ?? this.addedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive?? this.isActive
      );

  factory Worker.fromRawJson(String str) => Worker.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Worker.fromJson(Map<String, dynamic> json) => Worker(
    firstName: (json["first_name"])[0].toUpperCase() + (json["first_name"]).substring(1),
    lastName: (json["last_name"])[0].toUpperCase() + (json["last_name"]).substring(1),
    contractId: json["contractId"],
    added_by: json["added_by"],
    classification: json["classification"],
    unionId: json["unionId"],
    workerId: json["worker_id"],
    addedAt: json["added_at"],
    updatedAt: json["updated_at"],
    isActive:  json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "first_name": capitalize(firstName),
    "last_name": capitalize(lastName),
    "contractId": contractId,
    "added_by": added_by,
    "classification": classification,
    "unionId": unionId,
    "worker_id": workerId,
    "added_at": addedAt,
    "updated_at": updatedAt,
    "isActive":isActive
  };
  String capitalize(String? s){
    if(s == null){
      s = '';
    }
    return s[0].toUpperCase() + s.substring(1);
  }

}
