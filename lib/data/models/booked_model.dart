

import 'dart:convert';

import 'package:ridechain_driiver/data/models/ride_model.dart';

BookedRideModel bookedRideModelFromJson(String str) => BookedRideModel.fromJson(json.decode(str));

String bookedRideModelToJson(BookedRideModel data) => json.encode(data.toJson());

class BookedRideModel {
  int? id;
  Passenger? passenger;
  RideModel? ride;
  String? rideId;
  String? qrcodeUuid;
  String? qrCode;
  DateTime? dateBooked;
  DateTime? createdAt;
  DateTime? updatedAt;

  BookedRideModel({
    this.id,
    this.passenger,
    this.ride,
    this.rideId,
    this.qrcodeUuid,
    this.qrCode,
    this.dateBooked,
    this.createdAt,
    this.updatedAt,
  });

  factory BookedRideModel.fromJson(Map<dynamic, dynamic> json) => BookedRideModel(
    id: json["id"],
    passenger: json["passenger"] == null ? null : Passenger.fromJson(json["passenger"]),
    ride: json["ride"] == null ? null : RideModel.fromJson(json["ride"]),
    rideId: json["ride_id"],
    qrcodeUuid: json["qrcode_uuid"],
    qrCode: json["qr_code"],
    dateBooked: json["date_booked"] == null ? null : DateTime.parse(json["date_booked"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "passenger": passenger?.toJson(),
    "ride": ride?.toJson(),
    "ride_id": rideId,
    "qrcode_uuid": qrcodeUuid,
    "qr_code": qrCode,
    "date_booked": dateBooked?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Passenger {
  int? id;
  String? avatar;
  String? fullName;
  String? email;
  String? country;
  List<double>? currentLocation;
  String? phoneNumber;

  Passenger({
    this.id,
    this.avatar,
    this.fullName,
    this.email,
    this.country,
    this.currentLocation,
    this.phoneNumber,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
    id: json["id"],
    avatar: json["avatar"],
    fullName: json["full_name"],
    email: json["email"],
    country: json["country"],
    currentLocation: json["current_location"] == null ? [] : List<double>.from(json["current_location"]!.map((x) => x?.toDouble())),
    phoneNumber: json["phone_number"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "avatar": avatar,
    "full_name": fullName,
    "email": email,
    "country": country,
    "current_location": currentLocation == null ? [] : List<dynamic>.from(currentLocation!.map((x) => x)),
    "phone_number": phoneNumber,
  };
}


