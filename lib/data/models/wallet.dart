

import 'package:ridechain_driiver/data/models/user_model.dart';

class Wallet {
  int? id;
  UserModel? user;
  String? address;
  DateTime? createdAt;
  DateTime? updatedAt;
  Balance? balance;

  Wallet({
    this.id,
    this.user,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.balance,
  });

  factory Wallet.fromJson(Map<dynamic, dynamic> json) => Wallet(
    id: json["id"],
    user: json["user"] == null ? null : UserModel.fromJson(json["user"]),
    address: json["address"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    balance: json["balance"] == null ? null : Balance.fromJson(json["balance"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user?.toJson(),
    "address": address,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "balance": balance?.toJson(),
  };
}

class Balance {
  num? lovelace;
  num? ada;

  Balance({
    this.lovelace,
    this.ada,
  });

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
    lovelace: json["lovelace"],
    ada: json["ada"],
  );

  Map<String, dynamic> toJson() => {
    "lovelace": lovelace,
    "ada": ada,
  };
}