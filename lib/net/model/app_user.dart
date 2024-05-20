import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String? company;
  String? email;
  String? firstName;
  String? lastName;
  String? phone;
  String? countryCode;
  String? role;
  String? status;
  String? unionid;
  Timestamp? createdTime;
  String? uid;
  String? profileImage;
  List<DocumentReference>? contracts;

  AppUser({
    this.company,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.role,
    this.status,
    this.unionid,
    this.createdTime,
    this.uid,
    this.profileImage,
    this.contracts,
    this.countryCode
  });

  AppUser copyWith({
    String? company,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? countryCode,
    String? role,
    String? status,
    String? unionid,
    Timestamp? createdTime,
    String? uid,
    String? profileImage,
    List<DocumentReference>? contracts,
  }) =>
      AppUser(
        company: company ?? this.company,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        status: status ?? this.status,
        unionid: unionid ?? this.unionid,
        createdTime: createdTime ?? this.createdTime,
        uid: uid ?? this.uid,
        profileImage: profileImage ?? this.profileImage,
        contracts: contracts ?? this.contracts,
      );

  factory AppUser.fromRawJson(String str) => AppUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    company: json["company"],
    email: json["email"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    phone: json["phone"],
    countryCode: json["countryCode"],
    role: json["role"],
    status: json["status"],
    unionid: json["unionid"],
    createdTime: json["created_time"],
    uid: json["uid"],
    profileImage: json["profile_image"],
    contracts: json["contracts"] == null ? [] : List<DocumentReference>.from(json["contracts"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "company": company,
    "email": email,
    "firstName": firstName,
    "lastName": lastName,
    "phone": phone,
    "role": role,
    "status": status,
    "unionid": unionid,
    "created_time": createdTime,
    "uid": uid,
    "countryCode":countryCode,
    "profile_image": profileImage,
    "contracts": contracts == null ? [] : List<dynamic>.from(contracts!.map((x) => x)),
  };
}
