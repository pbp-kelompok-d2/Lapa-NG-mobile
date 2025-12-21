import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/screens/feeds/create_feeds.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

/// Mock CookieRequest untuk mengontrol hasil HTTP di dalam test.
class MockCookieRequest extends CookieRequest {
  bool succeedCreate = true;
  int postCallCount = 0;
  String? lastPostUrl;
  Map<String, String>? lastPostBody;

  @override
  Future<dynamic> post(String url, dynamic body) async {
    postCallCount++;
    lastPostUrl = url;

    //kirim Map<String, String>
    lastPostBody = Map<String, String>.from(body as Map);

    if (succeedCreate) {
      return {'ok': true};
    }
    return {'ok': false, 'detail': 'Some error from server'};
  }
}

///Bungkus widget dengan Provider<CookieRequest> + MaterialApp
Widget wrapWithProviders(
  Widget child, {
  MockCookieRequest? request,
  NavigatorObserver? navObserver,
}) {
  final mock = request ?? MockCookieRequest();

  return Provider<CookieRequest>.value(
    value: mock,
    child: MaterialApp(
      home: child,
      navigatorObservers: navObserver != null ? [navObserver] : const [],
    ),
  );
}

/// Observer buat ngecek Navigator.pop terpanggil
class TestNavigatorObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route route, Route? previousRoute) {
    popCount++;
    super.didPop(route, previousRoute);
  }
}

void main() {
  group('CreateFeedPage', () {
    testWidgets('menampilkan semua field form dengan benar',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const CreateFeedPage()));

      // AppBar title
      expect(find.text('Create New Feed'), findsOneWidget);

      // Field-field utama
      expect(find.widgetWithText(TextFormField, 'Isi Feed'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Thumbnail URL'), findsOneWidget);

      // Dropdown kategori
      expect(
        find.widgetWithText(DropdownButtonFormField<String>, 'Kategori'),
        findsOneWidget,
      );

      // Switch featured
      expect(find.widgetWithText(SwitchListTile, 'Featured'), findsOneWidget);

      // Tombol submit
      expect(find.widgetWithText(FilledButton, 'Submit'), findsOneWidget);
    });

    testWidgets('validasi gagal ketika Isi Feed kosong',
        (WidgetTester tester) async {
      final mock = MockCookieRequest();

      await tester.pumpWidget(wrapWithProviders(const CreateFeedPage(), request: mock));

      // Tap submit tanpa isi apapun
      await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
      await tester.pumpAndSettle();

      // Harus muncul pesan validasi
      expect(find.text('Wajib diisi'), findsOneWidget);

      // Tidak boleh ada request post
      expect(mock.postCallCount, 0);
    });

    testWidgets('berhasil membuat feed ketika form valid dan server OK',
        (WidgetTester tester) async {
      final mock = MockCookieRequest()..succeedCreate = true;
      final nav = TestNavigatorObserver();

      await tester.pumpWidget(
        wrapWithProviders(const CreateFeedPage(), request: mock, navObserver: nav),
      );

      // Isi feed
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Isi Feed'),
        'Lagi olahraga di Lapa-NG nih!',
      );

      // Buka dropdown kategori dan pilih Futsal
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Futsal').last);
      await tester.pumpAndSettle();

      // Isi thumbnail
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Thumbnail URL'),
        'https://contoh.com/gambar.jpg',
      );

      // Nyalakan Featured
      await tester.tap(find.widgetWithText(SwitchListTile, 'Featured'));
      await tester.pumpAndSettle();

      // Tap Submit
      await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
      await tester.pump(); // mulai async
      await tester.pump(const Duration(milliseconds: 50)); // selesaikan future

      // post() kepanggil dan payload benar
      expect(mock.postCallCount, 1);
      expect(mock.lastPostUrl, contains('/feeds/create-ajax/'));
      expect(mock.lastPostBody?['content'], 'Lagi olahraga di Lapa-NG nih!');
      expect(mock.lastPostBody?['category'], 'futsal');
      expect(mock.lastPostBody?['thumbnail'], 'https://contoh.com/gambar.jpg');
      expect(mock.lastPostBody?['is_featured'], 'on');

      // Harus pop balik ke page sebelumnya
      await tester.pumpAndSettle();
      expect(nav.popCount, greaterThanOrEqualTo(1));

      // Tidak ada exception
      expect(tester.takeException(), isNull);
    });

    testWidgets('menampilkan snackbar error ketika server mengembalikan gagal',
        (WidgetTester tester) async {
      final mock = MockCookieRequest()..succeedCreate = false;

      await tester.pumpWidget(wrapWithProviders(const CreateFeedPage(), request: mock));

      // Isi feed supaya lolos validasi
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Isi Feed'),
        'Isi feed untuk test error',
      );

      // Tap Submit
      await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
      await tester.pump(); // trigger onPressed
      await tester.pumpAndSettle(); // tunggu snackbar

      expect(mock.postCallCount, 1);

      // SnackBar error harus muncul
      expect(
        find.text('Gagal membuat feed: Some error from server'),
        findsOneWidget,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
