import 'dart:convert';

List<Review> reviewFromJson(String str) => List<Review>.from(json.decode(str).map((x) => Review.fromJson(x)));

String reviewToJson(List<Review> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Review {
  int pk;
  String userUsername;
  String venueName;
  String sportType;
  int rating;
  String comment;
  String? imageUrl;
  String createdAt;
  bool canModify;

  Review({
    required this.pk,
    required this.userUsername,
    required this.venueName,
    required this.sportType,
    required this.rating,
    required this.comment,
    this.imageUrl,
    required this.createdAt,
    required this.canModify,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    pk: json["pk"],
    userUsername: json["user_username"],
    venueName: json["venue_name"],
    sportType: json["sport_type"],
    rating: json["rating"],
    comment: json["comment"] ?? "",
    imageUrl: (json["image_url"] != null && json["image_url"] != "")
        ? json["image_url"]
        : null,
    createdAt: json["created_at"],
    canModify: json["can_modify"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "pk": pk,
    "user_username": userUsername,
    "venue_name": venueName,
    "sport_type": sportType,
    "rating": rating,
    "comment": comment,
    "image_url": imageUrl,
    "created_at": createdAt,
    "can_modify": canModify,
  };
}