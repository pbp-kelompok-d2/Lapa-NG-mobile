import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/models/feeds.dart';
import 'package:lapang/screens/feeds/feeds_detail_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MockCookieRequest extends CookieRequest {
  bool succeedEdit = true;
  bool succeedDelete = true;

  int postCallCount = 0;
  String? lastPostUrl;
  Map<String, dynamic>? lastPostBody;

  final Map<String, dynamic> _jsonData;

  MockCookieRequest({String? username})
      : _jsonData = {
          if (username != null) 'username': username,
        };

  @override
  Map<String, dynamic> get jsonData => _jsonData;

  @override
  Future<dynamic> post(String url, dynamic body) async {
    postCallCount++;
    lastPostUrl = url;
    lastPostBody = (body as Map).cast<String, dynamic>();

    if (url.contains('/edit')) {
      if (succeedEdit) {
        return {'ok': true};
      } else {
        return {'ok': false, 'detail': 'Edit failed'};
      }
    }

    if (url.contains('/delete')) {
      if (succeedDelete) {
        return {'ok': true};
      } else {
        return {'ok': false, 'detail': 'Delete failed'};
      }
    }

    return {'ok': false, 'detail': 'Unknown'};
  }
}

Widget wrapWithProviders(Widget child, {CookieRequest? request}) {
  final req = request ?? CookieRequest();
  return Provider<CookieRequest>.value(
    value: req,
    child: MaterialApp(
      home: child,
    ),
  );
}

Feed buildFeed({
  String id = '1',
  String content = 'Isi feed awal',
  String category = 'soccer',
  String thumbnail = 'https://example.com/thumb.jpg',
  int postViews = 5,
  bool isFeatured = true,
  String? userUsername = 'hafizh',
}) {
  return Feed(
    id: id,
    content: content,
    category: category,
    thumbnail: thumbnail,
    postViews: postViews,
    createdAt: DateTime(2025, 1, 2, 13, 5),
    isFeatured: isFeatured,
    isHot: false,
    userId: 1,
    userUsername: userUsername,
  );
}

/// ------------------ TESTS ------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedDetailPage UI', () {
    testWidgets(
        'menampilkan data feed lengkap dengan gambar dan menu pemilik',
        (WidgetTester tester) async {
      final feed = buildFeed();
      final mock = MockCookieRequest(username: 'hafizh');

      await tester.pumpWidget(
        wrapWithProviders(FeedDetailPage(feed: feed), request: mock),
      );

      expect(find.text('@hafizh'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      expect(find.byType(Image), findsOneWidget);

      expect(find.text('Soccer'), findsOneWidget);
      expect(find.text('Featured'), findsOneWidget);
      expect(find.text('Views: 5'), findsOneWidget);
      expect(find.text('Jan 2, 2025 1:05 PM'), findsOneWidget);

      expect(find.text('Isi feed awal'), findsOneWidget);
    });

    testWidgets('tidak menampilkan gambar jika thumbnail kosong',
        (WidgetTester tester) async {
      final feed = buildFeed(thumbnail: '');
      final mock = MockCookieRequest(username: 'hafizh');

      await tester.pumpWidget(
        wrapWithProviders(FeedDetailPage(feed: feed), request: mock),
      );

      expect(find.byType(AspectRatio), findsNothing);
      expect(find.text('Isi feed awal'), findsOneWidget);
    });

    testWidgets(
        'tidak menampilkan menu titik tiga jika feed bukan milik user login',
        (WidgetTester tester) async {
      final feed = buildFeed(userUsername: 'orang_lain');
      final mock = MockCookieRequest(username: 'hafizh');

      await tester.pumpWidget(
        wrapWithProviders(FeedDetailPage(feed: feed), request: mock),
      );

      expect(find.byIcon(Icons.more_horiz), findsNothing);
    });
  });

  group('FeedDetailPage edit', () {
    testWidgets('berhasil mengedit feed dan memperbarui tampilan',
        (WidgetTester tester) async {
      // Mulai dengan isFeatured = false supaya setelah tap switch -> true
      final feed = buildFeed(
        content: 'konten lama',
        thumbnail: '',
        isFeatured: false,
      );
      final mock = MockCookieRequest(username: 'hafizh')..succeedEdit = true;

      await tester.pumpWidget(
        wrapWithProviders(FeedDetailPage(feed: feed), request: mock),
      );

      // buka dialog edit
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // ubah content & thumbnail, nyalakan featured
      await tester.enterText(
        find.byType(TextField).first,
        'konten baru dari dialog',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        'https://example.com/baru.jpg',
      );
      // awalnya false, tap sekali jadi true
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // tekan Save
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(mock.postCallCount, 1);
      expect(mock.lastPostUrl, contains('/edit'));
      expect(mock.lastPostBody?['content'], 'konten baru dari dialog');
      expect(mock.lastPostBody?['thumbnail'], 'https://example.com/baru.jpg');
      expect(mock.lastPostBody?['is_featured'], 'on');

      expect(find.text('konten baru dari dialog'), findsOneWidget);
      expect(find.text('Featured'), findsOneWidget);
      expect(find.text('Feed berhasil diupdate'), findsOneWidget);
    });

    testWidgets('menampilkan snackbar error ketika edit gagal',
        (WidgetTester tester) async {
      final feed = buildFeed(content: 'konten lama', thumbnail: '');
      final mock = MockCookieRequest(username: 'hafizh')..succeedEdit = false;

      await tester.pumpWidget(
        wrapWithProviders(FeedDetailPage(feed: feed), request: mock),
      );

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(mock.postCallCount, 1);
      expect(find.text('Gagal mengupdate feed'), findsOneWidget);
    });
  });

  group('FeedDetailPage delete & back', () {
    testWidgets('berhasil menghapus feed dan menutup halaman detail',
        (WidgetTester tester) async {
      final feed = buildFeed(thumbnail: '');
      final mock = MockCookieRequest(username: 'hafizh')..succeedDelete = true;

      await tester.pumpWidget(
        wrapWithProviders(FeedDetailPage(feed: feed), request: mock),
      );

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Post'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(mock.postCallCount, 1);
      expect(mock.lastPostUrl, contains('/delete'));
      expect(find.byType(FeedDetailPage), findsNothing);
    });

    testWidgets('menampilkan snackbar error ketika delete gagal',
        (WidgetTester tester) async {
      final feed = buildFeed(thumbnail: '');
      final mock = MockCookieRequest(username: 'hafizh')..succeedDelete = false;

      await tester.pumpWidget(
        wrapWithProviders(FeedDetailPage(feed: feed), request: mock),
      );

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(mock.postCallCount, 1);
      expect(find.text('Gagal menghapus feed: Delete failed'), findsOneWidget);
      expect(find.byType(FeedDetailPage), findsOneWidget);
    });

    testWidgets(
        'WillPopScope mengirimkan true ke halaman sebelumnya jika sudah ada perubahan',
        (WidgetTester tester) async {
      final feed = buildFeed(content: 'konten lama', thumbnail: '');
      final mock = MockCookieRequest(username: 'hafizh')..succeedEdit = true;

      bool? result;

      await tester.pumpWidget(
        Provider<CookieRequest>.value(
          value: mock,
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FeedDetailPage(feed: feed),
                    ),
                  );
                },
                child: const Text('Buka Detail'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Detail'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });
}
