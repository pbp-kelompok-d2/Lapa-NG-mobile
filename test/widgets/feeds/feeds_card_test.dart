import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/models/feeds.dart';
import 'package:lapang/widgets/feeds/feeds_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

/// Mock CookieRequest untuk intercept HTTP `post`
class MockCookieRequest extends CookieRequest {
  bool succeedEdit;
  bool succeedDelete;
  int postCallCount = 0;

  MockCookieRequest({
    this.succeedEdit = true,
    this.succeedDelete = true,
  });

  @override
  Future<dynamic> post(String url, dynamic body) async {
    postCallCount++;

    if (url.contains('/delete')) {
      if (succeedDelete) {
        return {'ok': true};
      } else {
        return {'ok': false, 'detail': 'delete error'};
      }
    }

    if (succeedEdit) {
      return {'ok': true};
    } else {
      return {'ok': false, 'detail': 'edit error'};
    }
  }
}

/// Helper bikin Feed dummy
Feed buildFeed({String thumbnail = ''}) {
  return Feed(
    id: '1',
    content: 'isi feed contoh',
    category: 'soccer',
    thumbnail: thumbnail,
    postViews: 10,
    createdAt: DateTime(2025, 1, 2, 13, 5),
    isFeatured: false,
    isHot: false,
    userId: 1,
    userUsername: 'hafizh',
  );
}

/// Bungkus widget dengan Provider<CookieRequest> + MaterialApp
Widget wrapWithProviders(Widget child, {CookieRequest? request}) {
  final req = request ?? MockCookieRequest();
  return Provider<CookieRequest>.value(
    value: req,
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  /// ---------- TEST TAMPILAN DASAR ----------
  testWidgets('FeedCard menampilkan username, content, dan info bar',
      (WidgetTester tester) async {
    final feed = buildFeed();

    await tester.pumpWidget(
      wrapWithProviders(
        FeedCard(feed: feed, isMine: true),
      ),
    );

    // Username
    expect(find.text('@hafizh'), findsOneWidget);
    // Content
    expect(find.text('isi feed contoh'), findsOneWidget);
    // Category
    expect(find.text('Soccer'), findsOneWidget);
    // Views
    expect(find.textContaining('Views: 10'), findsOneWidget);
  });

  testWidgets('FeedCard tidak menampilkan gambar jika thumbnail kosong',
      (WidgetTester tester) async {
    final feed = buildFeed(thumbnail: '');

    await tester.pumpWidget(
      wrapWithProviders(
        FeedCard(feed: feed),
      ),
    );

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('FeedCard menampilkan gambar jika thumbnail ada',
      (WidgetTester tester) async {
    final feed =
        buildFeed(thumbnail: 'https://example.com/dummy-image.jpg');

    await tester.pumpWidget(
      wrapWithProviders(
        FeedCard(feed: feed),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  /// ---------- TEST FORMAT TANGGAL ----------
  test('FeedCard.formatDate mengembalikan format yang benar', () {
    final feed = buildFeed();
    final card = FeedCard(feed: feed);

    final dt = DateTime(2025, 1, 2, 13, 5); // 13:05 -> 1:05 PM
    final result = card.formatDate(dt);

    expect(result, 'Jan 2, 2025 1:05 PM');
  });

  /// ---------- TEST ALUR EDIT ----------
  testWidgets('FeedCard edit sukses memanggil onChanged',
      (WidgetTester tester) async {
    bool onChangedCalled = false;
    final mockRequest = MockCookieRequest(succeedEdit: true);
    final feed = buildFeed(thumbnail: '');

    await tester.pumpWidget(
      wrapWithProviders(
        FeedCard(
          feed: feed,
          isMine: true,
          onChanged: () {
            onChangedCalled = true;
          },
        ),
        request: mockRequest,
      ),
    );

    // buka menu titik tiga
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    // pilih Edit
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    // ganti isi TextField pertama (Content)
    const newContent = 'isi feed setelah edit';
    await tester.enterText(find.byType(TextField).first, newContent);

    // klik Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // callback onChanged seharusnya terpanggil
    expect(onChangedCalled, isTrue);
    expect(mockRequest.postCallCount, greaterThan(0));
  });

  /// ---------- TEST ALUR DELETE BERHASIL ----------
  testWidgets('FeedCard delete sukses memanggil onChanged',
      (WidgetTester tester) async {
    bool onChangedCalled = false;
    final mockRequest = MockCookieRequest(succeedDelete: true);
    final feed = buildFeed();

    await tester.pumpWidget(
      wrapWithProviders(
        FeedCard(
          feed: feed,
          isMine: true,
          onChanged: () {
            onChangedCalled = true;
          },
        ),
        request: mockRequest,
      ),
    );

    // buka menu titik tiga
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    // klik item menu Delete
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    // dialog konfirmasi -> tombol Delete lagi
    await tester.tap(
      find.widgetWithText(TextButton, 'Delete'),
    );
    await tester.pumpAndSettle();

    expect(onChangedCalled, isTrue);
    expect(mockRequest.postCallCount, greaterThan(0));
  });

  /// ---------- TEST ALUR DELETE GAGAL ----------
  testWidgets('FeedCard delete gagal tidak memanggil onChanged',
      (WidgetTester tester) async {
    bool onChangedCalled = false;
    final mockRequest = MockCookieRequest(succeedDelete: false);
    final feed = buildFeed();

    await tester.pumpWidget(
      wrapWithProviders(
        FeedCard(
          feed: feed,
          isMine: true,
          onChanged: () {
            onChangedCalled = true;
          },
        ),
        request: mockRequest,
      ),
    );

    // buka menu titik tiga
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    // pilih Delete di menu
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    // di dialog konfirmasi, klik Delete
    await tester.tap(
      find.widgetWithText(TextButton, 'Delete'),
    );
    await tester.pumpAndSettle();

    // karena request gagal, onChanged tidak dipanggil
    expect(onChangedCalled, isFalse);
    expect(mockRequest.postCallCount, greaterThan(0));
  });
}
