import 'dart:convert';

class Contract {
  String? address;
  String? code;
  String? contractStatus;
  String? contractId;
  num? currentProgress;
  num? estimatedHours;
  num? approvedHours;
  List? contractors;
  List? superIntendents;
  String? projectNumber;
  String? scopeOfWork;
  String? title;
  String? vendor;
  String? workLocation;
  String? defaultShiftId;

  Contract({
    this.address,
    this.code,
    this.contractStatus,
    this.currentProgress,
    this.estimatedHours,
    this.approvedHours,
    this.projectNumber,
    this.scopeOfWork,
    this.title,
    this.vendor,
    this.workLocation,
    this.contractId,
    this.contractors,
    this.superIntendents,
    this.defaultShiftId
  });

  Contract copyWith({
    String? address,
    String? code,
    String? contractStatus,
    num? currentProgress,
    num? estimatedHours,
    num? approvedHours,
    String? projectNumber,
    String? scopeOfWork,
    String? title,
    String? vendor,
    String? workLocation,
    String? contractId,
    List? contractors,
    List? superIntendents,
    String? defaultShiftId,
  }) =>
      Contract(
        address: address ?? this.address,
        code: code ?? this.code,
        contractStatus: contractStatus ?? this.contractStatus,
        currentProgress: currentProgress ?? this.currentProgress,
        estimatedHours: estimatedHours ?? this.estimatedHours,
          approvedHours: approvedHours ?? this.approvedHours,
        projectNumber: projectNumber ?? this.projectNumber,
        scopeOfWork: scopeOfWork ?? this.scopeOfWork,
        title: title ?? this.title,
        vendor: vendor ?? this.vendor,
        workLocation: workLocation ?? this.workLocation,
        contractId: contractId ?? this.contractId,
        contractors: contractors ?? this.contractors,
        superIntendents: superIntendents ?? this.superIntendents,
        defaultShiftId : defaultShiftId ?? this.defaultShiftId
      );

  factory Contract.fromRawJson(String str) => Contract.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Contract.fromJson(Map<String, dynamic> json) => Contract(
    address: json["address"],
    code: json["code"],
    contractStatus: json["contractStatus"],
    currentProgress: json["currentProgress"],
    estimatedHours: json["estimatedHours"],
      approvedHours: json["approvedHours"],
    projectNumber: json["projectNumber"],
    scopeOfWork: json["scopeOfWork"],
    title: json["title"],
    vendor: json["vendor"],
    workLocation: json["workLocation"],
    contractId: json["contractId"],
    contractors: json["contractors"],
    superIntendents: json["superIntendents"],
    defaultShiftId: json["defaultShiftId"]
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "code": code,
    "contractStatus": contractStatus,
    "currentProgress": currentProgress,
    "estimatedHours": estimatedHours,
    "approvedHours": approvedHours,
    "projectNumber": projectNumber,
    "scopeOfWork": scopeOfWork,
    "title": title,
    "vendor": vendor,
    "workLocation": workLocation,
    "contractId": contractId,
    "contractors": contractors,
    "superIntendents": superIntendents,
    "defaultShiftId": defaultShiftId
  };
}
