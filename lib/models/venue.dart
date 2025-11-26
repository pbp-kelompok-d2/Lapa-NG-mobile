import 'dart:convert';

class Venue {
  final int id;
  final String name;
  final String category;
  final String address;
  final int? price;
  final int? capacity;
  final String? openingTime;
  final String? closingTime;
  final String imageUrl;
  final bool isFeatured;
  final String? description;

  Venue({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    this.price,
    this.capacity,
    this.openingTime,
    this.closingTime,
    required this.imageUrl,
    required this.isFeatured,
    this.description,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    // Django JSON format: { "pk": 1, "fields": { ... } }
    final fields = json['fields'];
    return Venue(
      id: json['pk'],
      name: fields['name'],
      category: fields['category'],
      address: fields['address'],
      price: fields['price'],
      capacity: fields['capacity'],
      openingTime: fields['opening_time'],
      closingTime: fields['closing_time'],
      imageUrl: fields['image_url'] ?? '',
      isFeatured: fields['is_featured'] ?? false,
      description: fields['description'],
    );
  }
}