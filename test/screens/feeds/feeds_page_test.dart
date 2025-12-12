import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/screens/feeds/feeds_page.dart';
import 'package:lapang/widgets/feeds/feeds_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

enum GetBehavior { success, empty, error }

class MockCookieRequest extends CookieRequest {
  final Map<String, dynamic> _jsonData;
  GetBehavior getBehavior;

  int getCallCount = 0;
  String? lastGetUrl;

  MockCookieRequest({
    String? username,
    this.getBehavior = GetBehavior.success,
  }) : _jsonData = {
          if (username != null) 'username': username,
        };

  @override
  Map<String, dynamic> get jsonData => _jsonData;

  @override
  Future<dynamic> get(String url, {dynamic params}) async {
    getCallCount++;
    lastGetUrl = url;

    switch (getBehavior) {
      case GetBehavior.success:
        // satu feed dummy, format sama dengan Django JSON
        return [
          {
            'id': '1',
            'content': 'Hello from server',
            'category': 'soccer',
            'thumbnail': '',
            'post_views': 10,
            'created_at': '2025-01-02T13:05:00Z',
            'is_featured': false,
            'is_hot': false,
            'user_id': 1,
            'user_username': 'hafizh',
          },
        ];
      case GetBehavior.empty:
        return [];
      case GetBehavior.error:
        throw Exception('Network error');
    }
  }

  // Stub saja supaya kalau FeedCard sampai manggil post tidak error.
  @override
  Future<dynamic> post(String url, dynamic body) async {
    return {'ok': true};
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

/// ------------------ TESTS ------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedsPage - fetch & tampilan dasar', () {
    testWidgets('menampilkan loading lalu list feed ketika fetch sukses',
        (WidgetTester tester) async {
      final mock =
          MockCookieRequest(username: 'hafizh', getBehavior: GetBehavior.success);

      await tester.pumpWidget(
        wrapWithProviders(const FeedsPage(), request: mock),
      );

      // awalnya loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // setelah future selesai
      await tester.pumpAndSettle();

      expect(mock.getCallCount, 1);
      expect(mock.lastGetUrl, contains('filter=all'));
      expect(mock.lastGetUrl, contains('category=all'));

      // app bar & filter
      expect(find.text('Lapa-NG Feeds'), findsOneWidget);
      expect(find.text('All Feeds'), findsOneWidget);
      expect(find.text('My Feeds'), findsOneWidget);
      expect(find.text('Sport Type'), findsOneWidget);

      // list feed muncul
      expect(find.byType(FeedCard), findsOneWidget);
      expect(find.text('Hello from server'), findsOneWidget);
    });

    testWidgets('menampilkan pesan kosong ketika tidak ada feed (all)',
        (WidgetTester tester) async {
      final mock =
          MockCookieRequest(username: 'hafizh', getBehavior: GetBehavior.empty);

      await tester.pumpWidget(
        wrapWithProviders(const FeedsPage(), request: mock),
      );
      await tester.pumpAndSettle();

      expect(mock.getCallCount, 1);
      expect(find.text('Belum ada feed.'), findsOneWidget);
    });

    testWidgets(
        'menampilkan pesan kosong khusus ketika filter "my" dan data kosong',
        (WidgetTester tester) async {
      final mock =
          MockCookieRequest(username: 'hafizh', getBehavior: GetBehavior.empty);

      await tester.pumpWidget(
        wrapWithProviders(const FeedsPage(), request: mock),
      );
      await tester.pumpAndSettle();

      // awalnya all -> "Belum ada feed."
      expect(find.text('Belum ada feed.'), findsOneWidget);

      // pindah ke My Feeds
      await tester.tap(find.text('My Feeds'));
      await tester.pump(); // trigger setState
      await tester.pumpAndSettle();

      expect(mock.getCallCount, 2);
      expect(mock.lastGetUrl, contains('filter=my'));
      expect(find.text('Kamu belum punya feed.'), findsOneWidget);
    });

    testWidgets('menampilkan error ketika fetch gagal',
        (WidgetTester tester) async {
      final mock =
          MockCookieRequest(username: 'hafizh', getBehavior: GetBehavior.error);

      await tester.pumpWidget(
        wrapWithProviders(const FeedsPage(), request: mock),
      );
      await tester.pumpAndSettle();

      expect(mock.getCallCount, 1);
      expect(find.textContaining('Terjadi kesalahan:'), findsOneWidget);
    });
  });

  group('FeedsPage - filter & kategori', () {
    testWidgets('mengubah kategori memicu fetch baru dengan query yang tepat',
        (WidgetTester tester) async {
      final mock =
          MockCookieRequest(username: 'hafizh', getBehavior: GetBehavior.success);

      await tester.pumpWidget(
        wrapWithProviders(const FeedsPage(), request: mock),
      );
      await tester.pumpAndSettle();

      expect(mock.getCallCount, 1);
      expect(mock.lastGetUrl, contains('category=all'));

      // buka dropdown dan pilih Basket
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Basket').last);
      await tester.pump(); // trigger setState
      await tester.pumpAndSettle();

      expect(mock.getCallCount, 2);
      expect(mock.lastGetUrl, contains('category=basket'));
    });

    testWidgets('mengganti All -> My Feeds memicu fetch baru',
        (WidgetTester tester) async {
      final mock =
          MockCookieRequest(username: 'hafizh', getBehavior: GetBehavior.success);

      await tester.pumpWidget(
        wrapWithProviders(const FeedsPage(), request: mock),
      );
      await tester.pumpAndSettle();

      expect(mock.getCallCount, 1);
      expect(mock.lastGetUrl, contains('filter=all'));

      await tester.tap(find.text('My Feeds'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(mock.getCallCount, 2);
      expect(mock.lastGetUrl, contains('filter=my'));
    });
  });

  group('FeedsPage - FloatingActionButton & refresh setelah create', () {
    testWidgets('menekan FAB membuka halaman create dan refresh ketika balik',
        (WidgetTester tester) async {
      final mock =
          MockCookieRequest(username: 'hafizh', getBehavior: GetBehavior.success);

      // khusus test ini kita butuh route '/feeds/create'
      await tester.pumpWidget(
        Provider<CookieRequest>.value(
          value: mock,
          child: MaterialApp(
            routes: {
              '/feeds/create': (context) => Scaffold(
                    appBar: AppBar(title: const Text('Create Feed Dummy')),
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // simulasi submit berhasil -> return true
                          Navigator.pop(context, true);
                        },
                        child: const Text('Selesai & kembali'),
                      ),
                    ),
                  ),
            },
            home: const FeedsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final initialCalls = mock.getCallCount;
      expect(initialCalls, 1);

      // tekan FAB -> ke halaman create
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Create Feed Dummy'), findsOneWidget);

      // tekan tombol selesai -> pop dengan true
      await tester.tap(find.text('Selesai & kembali'));
      await tester.pumpAndSettle();

      // setelah kembali, FeedsPage harus refresh (panggil get lagi)
      expect(mock.getCallCount, greaterThan(initialCalls));
    });
  });
}
