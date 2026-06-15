// To parse this JSON data, do
//
//     final rideModel = rideModelFromJson(jsonString);

import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideModel {
  String? uuid;
  Driver? driver;
  List<Passenger>? passengers;
  dynamic pickUp;
  dynamic dropOff;
  DateTime? departureTime;
  DateTime? arrivalTime;
  int? seatsAvailable;
  String? pricePerSeat;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  RideModel({
    this.uuid,
    this.driver,
    this.passengers,
    this.pickUp,
    this.dropOff,
    this.departureTime,
    this.arrivalTime,
    this.seatsAvailable,
    this.pricePerSeat,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory RideModel.fromJson(Map<dynamic, dynamic> json) => RideModel(
    uuid: json["uuid"],
    driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
    passengers: json["passengers"] == null ? [] : List<Passenger>.from(json["passengers"]!.map((x) => Passenger.fromJson(x))),
    pickUp: json["pick_up"] == null ? null : json["pick_up"] is int ? json["pick_up"] : DropOff.fromJson(json["pick_up"]),
    dropOff: json["drop_off"] == null ? null : json["drop_off"] is int ? json["drop_off"] : DropOff.fromJson(json["drop_off"]),
    departureTime: json["departure_time"] == null ? null : DateTime.parse(json["departure_time"]),
    arrivalTime: json["arrival_time"] == null ? null : DateTime.parse(json["arrival_time"]),
    seatsAvailable: json["seats_available"],
    pricePerSeat: json["price_per_seat"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "driver": driver?.toJson(),
    "passengers": passengers == null ? [] : List<dynamic>.from(passengers!.map((x) => x.toJson())),
    "pick_up": pickUp?.toJson(),
    "drop_off": dropOff?.toJson(),
    "departure_time": departureTime?.toIso8601String(),
    "arrival_time": arrivalTime?.toIso8601String(),
    "seats_available": seatsAvailable,
    "price_per_seat": pricePerSeat,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  LatLng get latLng => LatLng(pickUp!.latitude!, pickUp!.longitude!);
}

class Driver {
  int? id;
  Passenger? user;
  String? vehicleImage;
  String? vehicleType;
  String? vehicleColor;
  String? vehiclePlateNumber;
  String? licenceImage;
  String? idType;
  String? idNumber;
  String? idFrontImage;
  String? idBackImage;
  String? insuranceCert;
  DateTime? dateCreated;
  DateTime? dateUpdated;
  String? status;

  Driver({
    this.id,
    this.user,
    this.vehicleImage,
    this.vehicleType,
    this.vehicleColor,
    this.vehiclePlateNumber,
    this.licenceImage,
    this.idType,
    this.idNumber,
    this.idFrontImage,
    this.idBackImage,
    this.insuranceCert,
    this.dateCreated,
    this.dateUpdated,
    this.status,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"],
    user: json["user"] == null ? null : Passenger.fromJson(json["user"]),
    vehicleImage: json["vehicle_image"],
    vehicleType: json["vehicle_type"],
    vehicleColor: json["vehicle_color"],
    vehiclePlateNumber: json["vehicle_plate_number"],
    licenceImage: json["licence_image"],
    idType: json["id_type"],
    idNumber: json["id_number"],
    idFrontImage: json["id_front_image"],
    idBackImage: json["id_back_image"],
    insuranceCert: json["insurance_cert"],
    dateCreated: json["date_created"] == null ? null : DateTime.parse(json["date_created"]),
    dateUpdated: json["date_updated"] == null ? null : DateTime.parse(json["date_updated"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user?.toJson(),
    "vehicle_image": vehicleImage,
    "vehicle_type": vehicleType,
    "vehicle_color": vehicleColor,
    "vehicle_plate_number": vehiclePlateNumber,
    "licence_image": licenceImage,
    "id_type": idType,
    "id_number": idNumber,
    "id_front_image": idFrontImage,
    "id_back_image": idBackImage,
    "insurance_cert": insuranceCert,
    "date_created": dateCreated?.toIso8601String(),
    "date_updated": dateUpdated?.toIso8601String(),
    "status": status,
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

class DropOff {
  int? id;
  String? name;
  double? latitude;
  double? longitude;

  DropOff({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
  });

  factory DropOff.fromJson(Map<String, dynamic> json) => DropOff(
    id: json["id"],
    name: json["name"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "latitude": latitude,
    "longitude": longitude,
  };
}
