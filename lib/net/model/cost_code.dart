import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class CostCode {
  DocumentReference? contractId;
  String? costCodeId;
  String? code;
  String? description;
  num? progress;
  num? estimatedHours;
  num? completedHours;

  num? addedHours;
  DocumentReference? createdBy;

  Timestamp? startDate;
  Timestamp? createdDate;
  Timestamp? targetCompletionDate;
  Timestamp? lastUpdateDate;


  CostCode({
    this.code,
    this.contractId,
    this.description,
    this.estimatedHours,
    this.lastUpdateDate,
    this.progress,
    this.completedHours,
    this.costCodeId,
    this.addedHours,
    this.startDate,
    this.createdDate,
    this.createdBy,
    this.targetCompletionDate,
  });

  CostCode copyWith({
    String? code,
    DocumentReference? contractId,
    String? description,
    num? estimatedHours,
    Timestamp? lastUpdateDate,
    num? progress,
    String? costCodeId,
    num? completedHours,
    num? addedHours,
    Timestamp? startDate,
    Timestamp? createdDate,
    DocumentReference? createdBy,
    Timestamp? targetCompletionDate,
  }) =>
      CostCode(
        code: code ?? this.code,
        contractId: contractId ?? this.contractId,
        description: description ?? this.description,
        estimatedHours: estimatedHours ?? this.estimatedHours,
        lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
        progress: progress ?? this.progress,
        costCodeId: costCodeId,
        completedHours: completedHours ?? this.completedHours,
        addedHours: addedHours ?? this.addedHours,
        startDate: startDate ?? this.startDate,
        createdDate: createdDate ?? this.createdDate,
        createdBy: createdBy ?? this.createdBy,
        targetCompletionDate: targetCompletionDate ?? this.targetCompletionDate,
      );

  factory CostCode.fromRawJson(String str) => CostCode.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CostCode.fromJson(Map<String, dynamic> json) => CostCode(
    code: json["code"],
    contractId: json["contractId"],
    description: json["description"],
    estimatedHours: json["estimated_hours"],
    lastUpdateDate: json["last_update_date"],
    progress: json["progress"],
    costCodeId: json['cost_code_id'],
    completedHours: json["completed_hours"],
    addedHours: json["added_hours"],
    startDate: json["start_date"],
    createdDate: json["created_date"],
    createdBy: json["created_by"],
    targetCompletionDate: json["target_completion_date"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "contractId": contractId,
    "description": description,
    "estimated_hours": estimatedHours,
    "last_update_date": lastUpdateDate,
    "progress": progress,
    "cost_code_id": costCodeId,
    "completed_hours": completedHours,
    "added_hours": addedHours,
    "start_date": startDate,
    "created_date": createdDate,
    "created_by": createdBy,
    "target_completion_date": targetCompletionDate,
  };
}
