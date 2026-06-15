class DriverModel {
  int? id;
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

  DriverModel({
    this.id,
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

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
    id: json["id"],
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
