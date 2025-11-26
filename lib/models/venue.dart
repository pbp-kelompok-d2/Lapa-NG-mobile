import 'dart:convert';

List<Venue> venueFromJson(String str) => List<Venue>.from(json.decode(str).map((x) => Venue.fromJson(x)));

String venueToJson(List<Venue> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Venue {
  String model;
  int pk;
  Fields fields;

  Venue({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
    model: json["model"],
    pk: json["pk"],
    fields: Fields.fromJson(json["fields"]),
  );

  Map<String, dynamic> toJson() => {
    "model": model,
    "pk": pk,
    "fields": fields.toJson(),
  };
}

class Fields {
  String name;
  String category;
  String address;
  int? price;
  int capacity;
  int rating;
  String imageUrl;
  bool isFeatured;
  String description;

  Fields({
    required this.name,
    required this.category,
    required this.address,
    this.price,
    required this.capacity,
    required this.rating,
    required this.imageUrl,
    required this.isFeatured,
    required this.description,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    name: json["name"],
    category: json["category"],
    address: json["address"],
    price: json["price"],
    capacity: json["capacity"] ?? 0,
    rating: json["rating"] ?? 0,
    imageUrl: json["image_url"] ?? "",
    isFeatured: json["is_featured"] ?? false,
    description: json["description"] ?? "-",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "category": category,
    "address": address,
    "price": price,
    "capacity": capacity,
    "rating": rating,
    "image_url": imageUrl,
    "is_featured": isFeatured,
    "description": description,
  };
}