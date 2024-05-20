import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Shift {
  DocumentReference? addedBy;
  Timestamp? addedAt;
  DocumentReference? contract;
  String? endTime;
  String? startTime;
  String? shiftName;
  String? shiftId;
  bool? isActive;
  int breaksMins;

  Shift(
      {this.addedBy,
      this.addedAt,
      this.contract,
      this.endTime,
      this.shiftName,
      this.startTime,
      this.breaksMins = 0,
      this.shiftId,
      this.isActive});

  Shift copyWith(
          {DocumentReference? addedBy,
          Timestamp? addedAt,
          DocumentReference? contract,
          String? endTime,
          String? startTime,
          String? shiftName,
          String? shiftId,
          int breaksMins = 0,
          bool isActive = true}) =>
      Shift(
          addedBy: addedBy ?? this.addedBy,
          addedAt: addedAt ?? this.addedAt,
          contract: contract ?? this.contract,
          endTime: endTime ?? this.endTime,
          startTime: startTime ?? this.startTime,
          shiftName: shiftName ?? this.shiftName,
          breaksMins: breaksMins ?? this.breaksMins,
          shiftId: shiftId ?? this.shiftId,
          isActive: isActive ?? this.isActive);

  factory Shift.fromRawJson(String str) => Shift.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
        addedBy: json["added_by"],
        addedAt: json["added_at"],
        contract: json["contract"],
        endTime: json["end_time"],
        isActive: json["isActive"],
        startTime: json["start_time"],
        shiftName: json["shift_name"],
        breaksMins: json["breaks_mins"],
        shiftId: json["shift_id"],
      );

  Map<String, dynamic> toJson() => {
        "added_by": addedBy,
        "added_at": addedAt,
        "contract": contract,
        "end_time": endTime,
        "start_time": startTime,
        "isActive": isActive,
        "shift_name": shiftName,
        "breaks_mins": breaksMins,
        "shift_id":shiftId
      };
}
