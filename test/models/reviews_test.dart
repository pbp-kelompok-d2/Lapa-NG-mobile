import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/models/reviews.dart';

void main() {
  group('Review Model Test', () {
    final Map<String, dynamic> jsonMap = {
      "pk": 1,
      "user_username": "budi",
      "venue_name": "Stadion",
      "sport_type": "soccer",
      "rating": 5,
      "comment": "Nice",
      "image_url": "http://img.com/a.jpg",
      "created_at": "Today",
      "can_modify": true
    };

    test('fromJson creates a valid Review object', () {
      final review = Review.fromJson(jsonMap);
      expect(review.pk, 1);
      expect(review.userUsername, "budi");
      expect(review.imageUrl, "http://img.com/a.jpg");
      expect(review.canModify, true);
    });

    test('fromJson handles null/empty fields correctly', () {
      final Map<String, dynamic> emptyJson = {
        "pk": 2,
        "user_username": "siti",
        "venue_name": "GOR",
        "sport_type": "tennis",
        "rating": 3,
        "created_at": "Yesterday",
      };
      final review = Review.fromJson(emptyJson);
      expect(review.comment, "");
      expect(review.imageUrl, null);
      expect(review.canModify, false);
    });

    test('toJson creates a valid Map', () {
      final review = Review(
          pk: 1, userUsername: "budi", venueName: "Stadion", sportType: "soccer",
          rating: 5, comment: "Nice", createdAt: "Today", canModify: true,
          imageUrl: "http://img.com/a.jpg"
      );
      final json = review.toJson();
      expect(json['pk'], 1);
      expect(json['image_url'], "http://img.com/a.jpg");
    });

    test('Top-level reviewFromJson parses list correctly', () {
      final jsonStr = jsonEncode([jsonMap]);
      final List<Review> reviews = reviewFromJson(jsonStr);
      expect(reviews.length, 1);
      expect(reviews.first.userUsername, "budi");
    });

    test('Top-level reviewToJson serializes list correctly', () {
      final review = Review(
          pk: 1, userUsername: "budi", venueName: "Stadion", sportType: "soccer",
          rating: 5, comment: "Nice", createdAt: "Today", canModify: true
      );
      final jsonStr = reviewToJson([review]);
      expect(jsonStr, contains('"user_username":"budi"'));
    });
  });
}