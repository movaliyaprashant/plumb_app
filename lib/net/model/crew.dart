import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Crew {
  String? name;
  Timestamp? createdAt;
  DocumentReference? contractId;
  List? workers;
  Timestamp? updatedAt;
  String? crewId;
  DocumentReference? createdBy;

  Crew({
    this.name,
    this.createdAt,
    this.contractId,
    this.workers,
    this.updatedAt,
    this.crewId,
    this.createdBy,
  });

  Crew copyWith({
    String? name,
    Timestamp? createdAt,
    DocumentReference? contractId,
    List<DocumentReference>? workers,
    Timestamp? updatedAt,
    String? crewId,
    DocumentReference? createdBy,
  }) =>
      Crew(
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        contractId: contractId ?? this.contractId,
        workers: workers ?? this.workers,
        updatedAt: updatedAt ?? this.updatedAt,
        crewId: crewId ?? this.crewId,
        createdBy: createdBy ?? this.createdBy,
      );

  factory Crew.fromRawJson(String str) => Crew.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Crew.fromJson(Map<String, dynamic> json) => Crew(
    name: json["name"],
    createdAt: json["created_at"],
    contractId: json["contractId"],
    workers: json["workers"],
    updatedAt: json["updated_at"],
    crewId: json["crew_id"],
    createdBy: json["created_by"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "created_at": createdAt,
    "contractId": contractId,
    "workers": workers == null ? [] : List<dynamic>.from(workers!.map((x) => x)),
    "updated_at": updatedAt,
    "crew_id": crewId,
    "created_by": createdBy,
  };


  static crewFromRef(DocumentReference reference) async {
    var crewDoc = await reference.get();
    if(crewDoc.exists){
      var crewData = crewDoc.data() as Map<String, dynamic>;
      return Crew(
        name: crewData['name'],
        updatedAt: crewData['updated_at'],
        crewId: crewData['crew_id'],
        createdBy: crewData['created_by'],
        contractId: crewData['createdId'],
        workers: crewData['workers'],
      );
    }
    return null;

  }
}
