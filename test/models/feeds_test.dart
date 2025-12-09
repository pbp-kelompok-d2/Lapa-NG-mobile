import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/models/feeds.dart';

void main() {
  group('Feed model', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': '123',
        'content': 'Halo dunia',
        'category': 'soccer',
        'thumbnail': 'https://example.com/img.png',
        'post_views': 10,
        'created_at': '2025-12-09T13:15:00Z',
        'is_featured': true,
        'is_hot': true,
        'user_id': 1,
        'user_username': 'hafizh',
      };

      final feed = Feed.fromJson(json);

      expect(feed.id, '123');
      expect(feed.content, 'Halo dunia');
      expect(feed.category, 'soccer');
      expect(feed.thumbnail, 'https://example.com/img.png');
      expect(feed.postViews, 10);
      expect(feed.createdAt, isA<DateTime>());
      expect(feed.isFeatured, isTrue);
      expect(feed.isHot, isTrue);
      expect(feed.userId, 1);
      expect(feed.userUsername, 'hafizh');
    });

    test('fromJson gives default values when some fields missing', () {
      final json = {
        'id': '456',
      };

      final feed = Feed.fromJson(json);

      expect(feed.id, '456');
      expect(feed.content, '');          // default
      expect(feed.category, 'other');    // default
      expect(feed.thumbnail, '');        // default
      expect(feed.postViews, 0);         // default
      expect(feed.createdAt, isNull);
      expect(feed.isFeatured, isFalse);
      expect(feed.isHot, isFalse);
    });

    test('toJson maps correctly to Django expected fields', () {
      final feed = Feed(
        id: '1',
        content: 'Test',
        category: 'soccer',
        thumbnail: 'https://example.com',
        postViews: 0,
        createdAt: null,
        isFeatured: true,
        isHot: false,
        userId: 1,
        userUsername: 'hafizh',
      );

      final json = feed.toJson();

      expect(json['content'], 'Test');
      expect(json['category'], 'soccer');
      expect(json['thumbnail'], 'https://example.com');
      expect(json['is_featured'], 'on'); // kalau true jadi "on"
    });
  });
}
