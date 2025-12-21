import 'dart:convert';

import 'package:lapang/models/custom_user.dart';

List<EquipmentEntry> equipmentEntryFromJson(String str) => List<EquipmentEntry>.from(json.decode(str).map((x) => EquipmentEntry.fromJson(x)));

String equipmentEntryToJson(List<EquipmentEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EquipmentEntry {

    String id;
    String name;
    String pricePerHour;
    String sportCategory;
    String region;
    int quantity;
    bool available;
    String thumbnail;
    CustomUser user;

    EquipmentEntry({
        required this.id,
        required this.name,
        required this.pricePerHour,
        required this.sportCategory,
        required this.region,
        required this.quantity,
        required this.available,
        required this.thumbnail,
        required this.user,
    });

    factory EquipmentEntry.fromJson(Map<String, dynamic> json) => EquipmentEntry(
        id: json["id"],
        name: json["name"],
        pricePerHour: json["price_per_hour"],
        sportCategory: json["sport_category"],
        region: json["region"],
        quantity: json["quantity"],
        available: json["available"],
        thumbnail: json["thumbnail"],
        user: CustomUser.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price_per_hour": pricePerHour,
        "sport_category": sportCategory,
        "region": region,
        "quantity": quantity,
        "available": available,
        "thumbnail": thumbnail,
        "user": user.toJson(),
    };
}
