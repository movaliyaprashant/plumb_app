import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  Timestamp? dateSent;
  bool? notifyBackOffice;
  bool? read;
  String? receiver;
  String? sender;
  String? statusChanged;
  String? timesheet;
  String? contract;
  String? title;
  String? description;

  AppNotification({
    this.dateSent,
    this.notifyBackOffice,
    this.read,
    this.receiver,
    this.sender,
    this.statusChanged,
    this.timesheet,
    this.contract,
    this.title,
    this.description,
  });

  AppNotification copyWith({
    Timestamp? dateSent,
    bool? notifyBackOffice,
    bool? read,
    String? receiver,
    String? sender,
    String? statusChanged,
    String? timesheet,
    String? contract,
    String? title,
    String? description,
  }) =>
      AppNotification(
        dateSent: dateSent ?? this.dateSent,
        notifyBackOffice: notifyBackOffice ?? this.notifyBackOffice,
        read: read ?? this.read,
        receiver: receiver ?? this.receiver,
        sender: sender ?? this.sender,
        statusChanged: statusChanged ?? this.statusChanged,
        timesheet: timesheet ?? this.timesheet,
        contract: contract ?? this.contract,
        title: title ?? this.title,
        description: description ?? this.description,
      );

  factory AppNotification.fromRawJson(String str) => AppNotification.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    dateSent: json["dateSent"],
    notifyBackOffice: json["notifyBackOffice"],
    read: json["read"],
    receiver: json["receiver"],
    sender: json["sender"],
    statusChanged: json["statusChanged"],
    timesheet: json["timesheet"],
    contract: json["contract"],
    title: json["title"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "dateSent": dateSent,
    "notifyBackOffice": notifyBackOffice,
    "read": read,
    "receiver": receiver,
    "sender": sender,
    "statusChanged": statusChanged,
    "timesheet": timesheet,
    "contract": contract,
    "title": title,
    "description": description,
  };
}
