import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plumbata/net/model/contract.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/crew_time_sheet.dart';
import 'package:plumbata/net/model/shift.dart';
import 'package:plumbata/net/model/worker.dart';

class TimeSheet {
  final DocumentReference addedBy;
  final int breakHrs;
  final int breakMins;
  final String comment;
  final DocumentReference contract;
  final DocumentReference costCode;
  final Timestamp createdAt;
  final List<String> crewIds;
  final List<DocumentReference<Object?>> crewTimeSheet;
  final List<DocumentReference<Object?>> crews;
  final DateTime datePerformedOn;
  final String defaultCostCodeShift;
  final DateTime endTime;
  final DocumentReference shift;
  final DateTime startTime;
  final String status;
  final String timeSheetId;
  final Timestamp updatedAt;
  final List<String> workerIds;
  final List<DocumentReference<Object?>> workers;
  final Map<String, dynamic> workersCostCodes;
  final List<String> files;
  final bool? isEscalated;
  final bool? isResubmitted;

  TimeSheet({
    required this.addedBy,
    required this.breakHrs,
    required this.breakMins,
    required this.comment,
    required this.contract,
    required this.costCode,
    required this.createdAt,
    required this.crewIds,
    required this.crewTimeSheet,
    required this.crews,
    required this.datePerformedOn,
    required this.defaultCostCodeShift,
    required this.endTime,
    required this.shift,
    required this.startTime,
    required this.status,
    required this.timeSheetId,
    required this.updatedAt,
    required this.workerIds,
    required this.workers,
    required this.workersCostCodes,
    required this.files,
    this.isEscalated,
    this.isResubmitted
  });

  factory TimeSheet.fromMap(Map<String, dynamic> map) {
    return TimeSheet(
      addedBy: map['added_by'],
      breakHrs: map['breakHrs'],
      breakMins: map['breakMins'],
      comment: map['comment'],
      contract: map['contract'],
      costCode: map['cost_code'],
      createdAt: map['created_at'],
      isEscalated: map['isEscalated'],
        isResubmitted: map["resubmitted"],
      crewIds: List<String>.from(map['crewIds']),
      crewTimeSheet: List<DocumentReference<Object?>>.from(
          map['crew_time_sheet']),
      crews: List<DocumentReference<Object?>>.from(map['crews']),
      datePerformedOn: (map['date_performed_on'] as Timestamp).toDate(),
      defaultCostCodeShift: map['default_cost_code_shift'],
      endTime: map['end_time'].toDate(),
      shift: map['shift'],
      startTime: map['start_time'].toDate(),
      status: map['status'],
      timeSheetId: map['timesheet_id'],
      updatedAt: map['updated_at'],
      workerIds: List<String>.from(map['workerIds']),
      workers: List<DocumentReference<Object?>>.from(map['workers']),
      workersCostCodes: Map<String, dynamic>.from(map['workers_cost_codes']),
      files: List<String>.from(map['files']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'added_by': addedBy,
      'breakHrs': breakHrs,
      'breakMins': breakMins,
      'comment': comment,
      'contract': contract,
      'cost_code': costCode,
      'created_at': createdAt,
      'crewIds': crewIds,
      'crew_time_sheet': crewTimeSheet,
      'crews': crews,
      'date_performed_on': datePerformedOn,
      'default_cost_code_shift': defaultCostCodeShift,
      'end_time': endTime,
      'shift': shift,
      'start_time': startTime,
      'status': status,
      'timesheet_id': timeSheetId,
      'updated_at': updatedAt,
      'workerIds': workerIds,
      'workers': workers,
      'workers_cost_codes': workersCostCodes,
      'files': files,
      "isEscalated":isEscalated,
      "resubmitted": isResubmitted
    };
  }
}

class TimeSlot {
  int? breakMins;
  int? breakHrs;
  Timestamp? endTime;
  Timestamp? startTime;
  String? workerId;
  String? crewId;
  String? status;
  double? total;
  String? costCodeId;

  TimeSlot({
    this.breakMins,
    this.breakHrs,
    this.endTime,
    this.startTime,
    this.workerId,
    this.status,
    this.crewId,
    this.total,
    this.costCodeId
  });

  TimeSlot copyWith({
    int? breakMins,
    int? breakHrs,
    Timestamp? endTime,
    Timestamp? startTime,
    String? workerId,
    String? crewId,
    String? status,
    double? total,
    String? costCodeId
  }) =>
      TimeSlot(
        breakMins: breakMins ?? this.breakMins,
        endTime: endTime ?? this.endTime,
        startTime: startTime ?? this.startTime,
        workerId: workerId ?? this.workerId,
        status: status,
        crewId: crewId,
        total: total,
        costCodeId: costCodeId
      );

  factory TimeSlot.fromRawJson(String str) => TimeSlot.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    breakMins: json["break_mins"],
    breakHrs: json["break_hrs"],
    endTime: json["end_time"],
    startTime: json["start_time"],
    workerId: json["worker"],
    crewId: json["crew"],
    status: json["status"],
    total: json["total"],
    costCodeId: json["costCodeId"]
  );

  Map<String, dynamic> toJson() => {
    "break_mins": breakMins,
    "break_hrs": breakHrs,
    "end_time": endTime,
    "start_time": startTime,
    "worker": workerId,
    "status":status,
    "crew":crewId,
    "total":total,
    "costCode": costCodeId
  };
}

class UiTimeSheet{
  UiTimeSheet({
    this.shift,
    this.startTime,
    this.endTime,
    this.costCode,
    this.contract,
    required this.workers,
    required this.crews,
    this.datePerformedOn,
    this.crewTimeSheet,
  });

  DateTime? startTime;
  DateTime? datePerformedOn;
  DateTime? endTime;

  Shift? shift; //Document Reference
  CostCode? costCode; // Document Reference
  Contract? contract; // Document Reference
  CostCodeShift? defaultCostCodeShift; // Document Reference
  Map<String, List<CostCodeShift>> workersCostCodes = {}; // Map<String, Document Reference>
  List<CrewTimeSheet>? crewTimeSheet = []; // List<Document Reference>

  List<Worker> workers = []; // List<Document Reference>
  List<Crew> crews = []; // List<Document Reference>
  int breakHrs = 0;
  int breakMins = 0;
  String comment = '';
  List<String> crewIds = [];
  List<String> workerIds = [];


}
class CostCodeShift {
  CostCode? costCode;
  DateTime? startTime;
  DateTime? endTime;
  int? breakMins;

  CostCodeShift({
    this.costCode,
    this.startTime,
    this.endTime,
    this.breakMins,
  });

  factory CostCodeShift.fromJson(Map<String, dynamic> data) {

    return CostCodeShift(
      costCode: CostCode.fromJson(data['costCode']),
      startTime: data['startTime'].toDate(),
      endTime: data['endTime'].toDate(),
      breakMins: data['breakMins'],
    );
  }
}