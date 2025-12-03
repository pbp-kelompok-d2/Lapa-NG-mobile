import 'dart:convert';

List<Feed> feedsFromJson(String str) =>
    List<Feed>.from(json.decode(str).map((x) => Feed.fromJson(x)));

class Feed {
  final String id;            
  final String content;       
  final String category;      
  final String thumbnail;     
  final int postViews;        
  final DateTime? createdAt;  
  final bool isFeatured;      
  final bool isHot;          
  final int? userId;          
  final String? userUsername; 

  Feed({
    required this.id,
    required this.content,
    required this.category,
    required this.thumbnail,
    required this.postViews,
    required this.createdAt,
    required this.isFeatured,
    required this.isHot,
    required this.userId,
    required this.userUsername,
  });

  /// Mapping dari JSON Django ke object Feed di Flutter.
  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        id: json['id'] as String,
        content: json['content'] ?? '',
        category: json['category'] ?? 'other',
        thumbnail: json['thumbnail'] ?? '',
        postViews: json['post_views'] ?? 0,
        createdAt: json['created_at'] != null && json['created_at'] != ''
            ? DateTime.parse(json['created_at'])
            : null,
        isFeatured: json['is_featured'] ?? false,
        isHot: json['is_hot'] ?? false,
        userId: json['user_id'],
        userUsername: json['user_username'],
      );

  Map<String, dynamic> toJson() => {
        "content": content,
        "category": category,
        "thumbnail": thumbnail,
        "is_featured": isFeatured ? "on" : "",
      };
}
