import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/worker.dart';

class TimeTableItem {
  DateTime? startTime;
  DateTime? endTime;
  int breakHrs = 0;
  int breakMins = 0;
  Worker? worker;
  Crew? crew;
  String? costCodeId;
  CostCode? costCode;

  TimeTableItem({
    this.startTime,
    this.endTime,
    this.breakHrs = 0,
    this.breakMins = 0,
    this.worker,
    this.crew,
    this.costCodeId,
    this.costCode,
  });

  TimeTableItem copyWith({
    DateTime? startTiem,
    DateTime? endTime,
    int? breakHrs,
    int? breakMins,
    Worker? worker,
    Crew? crew,
    String? costCodeId,
    CostCode? costCode
  }) =>
      TimeTableItem(
        startTime: startTiem ?? this.startTime,
        endTime: endTime ?? this.endTime,
        breakHrs: breakHrs ?? this.breakHrs,
        breakMins: breakMins ?? this.breakMins,
        worker:this.worker,
        crew: this.crew,
        costCodeId: this.costCodeId,
        costCode: this.costCode,
      );

  factory TimeTableItem.fromRawJson(String str) => TimeTableItem.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TimeTableItem.fromJson(Map<String, dynamic> json) => TimeTableItem(
    startTime: json["start_time"],
    endTime: json["end_time"],
    breakHrs: json["break_hrs"],
    breakMins: json["break_mins"],
    worker: json["worker"],
    crew: json["crew"],
    costCodeId: json['costCodeId'],
    costCode: json['CostCode']
  );

  Map<String, dynamic> toJson() => {
    "start_time": startTime,
    "end_time": endTime,
    "break_hrs": breakHrs,
    "break_mins": breakMins,
    "worker": worker?.workerId,
    "crew": crew?.crewId,
    "costCodeId": costCodeId,
    "costCode":costCode
  };
  double calculateCrewTotalDuration(startTime, endTime, creLen) {
    if (startTime != null && endTime != null) {
      // Calculate the total duration in minutes
      DateTime now = DateTime.now();
      DateTime sTime = DateTime(
          startTime?.year??now.year,startTime?.month?? now.month,
          startTime?.day?? now.day,
          startTime?.hour?? now.hour,
          startTime?.minute?? now.minute
      );
      DateTime eTime = DateTime(
          endTime?.year??now.year,endTime?.month?? now.month,
          endTime?.day?? now.day,
          endTime?.hour?? now.hour,
          endTime?.minute?? now.minute
      );

      int totalMinutes = eTime.difference(sTime).inMinutes;

      print("totalMinutes*** ${totalMinutes}");

      // Subtract break time
      totalMinutes = totalMinutes - (breakHrs * 60) - breakMins;

      print("totalMinutes ** ${totalMinutes}");
      // Convert total minutes to hours
      double totalHours = totalMinutes / 60.0;

      // Round to two decimal places
      totalHours = double.parse(totalHours.toStringAsFixed(2));

      return totalHours * creLen;
    } else {
      return 0.0; // Handle the case where either startTime or endTime is null
    }
  }
  double calculateTotalDuration() {
    if (startTime != null && endTime != null) {
      // Calculate the total duration in minutes
      DateTime now = DateTime.now();
      DateTime sTime = DateTime(
        startTime?.year??now.year,startTime?.month?? now.month,
          startTime?.day?? now.day,
          startTime?.hour?? now.hour,
          startTime?.minute?? now.minute
      );
      DateTime eTime = DateTime(
          endTime?.year??now.year,endTime?.month?? now.month,
          endTime?.day?? now.day,
          endTime?.hour?? now.hour,
          endTime?.minute?? now.minute
      );

      int totalMinutes = eTime.difference(sTime).inMinutes;

      print("totalMinutes*** ${totalMinutes}");

      // Subtract break time
      totalMinutes = totalMinutes - (breakHrs * 60) - breakMins;

      print("totalMinutes ** ${totalMinutes}");
      // Convert total minutes to hours
      double totalHours = totalMinutes / 60.0;

      // Round to two decimal places
      totalHours = double.parse(totalHours.toStringAsFixed(2));

      return totalHours;
    } else {
      return 0.0; // Handle the case where either startTime or endTime is null
    }
  }
}
