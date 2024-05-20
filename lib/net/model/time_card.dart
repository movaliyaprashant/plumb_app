import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class TimeCard {
  double? breakTime;
  DocumentReference? costCode;
  Timestamp? finishTime;
  Timestamp? startTime;
  double? netHours;
  DocumentReference? timesheet;
  DocumentReference? worker;
  DocumentReference? crewId;
  DocumentReference? contract;

  TimeCard({
    this.breakTime,
    this.costCode,
    this.finishTime,
    this.startTime,
    this.netHours,
    this.timesheet,
    this.worker,
    this.contract,
    this.crewId
  });

  TimeCard copyWith({
    double? breakTime,
    DocumentReference? costCode,
    Timestamp? finishTime,
    Timestamp? startTime,
    double? netHours,
    DocumentReference? timesheet,
    DocumentReference? worker,
    DocumentReference? contract,
    DocumentReference? crewId,

  }) =>
      TimeCard(
        breakTime: breakTime ?? this.breakTime,
        costCode: costCode ?? this.costCode,
        finishTime: finishTime ?? this.finishTime,
        startTime: startTime ?? this.startTime,
        netHours: netHours ?? this.netHours,
        timesheet: timesheet ?? this.timesheet,
        worker: worker ?? this.worker,
        contract: contract ?? this.contract,
        crewId: crewId ?? this.crewId,
      );

  factory TimeCard.fromRawJson(String str) => TimeCard.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TimeCard.fromJson(Map<String, dynamic> json) => TimeCard(
    breakTime: json["breakTime"],
    costCode: json["costCode"],
    finishTime: json["finishTime"],
    startTime: json["startTime"],
    netHours: json["netHours"],
    timesheet: json["timesheet"],
    worker: json["worker"],
    contract: json["contract"],
    crewId: json["crewId"]
  );

  Map<String, dynamic> toJson() => {
    "breakTime": breakTime,
    "costCode": costCode,
    "finishTime": finishTime,
    "startTime": startTime,
    "netHours": netHours,
    "timesheet": timesheet,
    "worker": worker,
    "contract":contract,
    "crewId": crewId
  };
}
