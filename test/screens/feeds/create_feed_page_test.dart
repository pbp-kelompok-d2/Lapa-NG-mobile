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
    // di kode asli kita kirim Map<String, String>, jadi aman di-cast
    lastPostBody = Map<String, String>.from(body as Map);

    if (succeedCreate) {
      return {'ok': true};
    } else {
      return {'ok': false, 'detail': 'Some error from server'};
    }
  }
}

/// Bungkus widget dengan Provider<CookieRequest> + MaterialApp.
Widget wrapWithProviders(Widget child, {MockCookieRequest? request}) {
  final mock = request ?? MockCookieRequest();

  return Provider<CookieRequest>.value(
    value: mock,
    child: MaterialApp(home: child),
  );
}

void main() {
  group('CreateFeedPage', () {
    testWidgets('menampilkan semua field form dengan benar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const CreateFeedPage()));

      // Cek AppBar title
      expect(find.text('Buat Feed Baru'), findsOneWidget);

      // TextFormField isi feed
      expect(find.widgetWithText(TextFormField, 'Isi Feed'), findsOneWidget);

      // Dropdown kategori
      expect(
        find.widgetWithText(DropdownButtonFormField<String>, 'Kategori'),
        findsOneWidget,
      );

      // TextFormField thumbnail
      expect(
        find.widgetWithText(TextFormField, 'Thumbnail URL'),
        findsOneWidget,
      );

      // Switch featured
      expect(find.widgetWithText(SwitchListTile, 'Featured'), findsOneWidget);

      // Tombol kirim
      expect(find.widgetWithText(FilledButton, 'Kirim'), findsOneWidget);
    });

    testWidgets('validasi gagal ketika Isi Feed kosong', (
      WidgetTester tester,
    ) async {
      final mock = MockCookieRequest();

      await tester.pumpWidget(
        wrapWithProviders(const CreateFeedPage(), request: mock),
      );

      // Langsung tekan tombol Kirim tanpa mengisi apapun
      await tester.tap(find.widgetWithText(FilledButton, 'Kirim'));
      await tester.pumpAndSettle();

      // Harus muncul pesan error "Wajib diisi"
      expect(find.text('Wajib diisi'), findsOneWidget);

      // post() tidak boleh dipanggil
      expect(mock.postCallCount, 0);
    });

    testWidgets('berhasil membuat feed ketika form valid dan server OK',
        (WidgetTester tester) async {
      final mock = MockCookieRequest()..succeedCreate = true;

      await tester.pumpWidget(
        wrapWithProviders(const CreateFeedPage(), request: mock),
      );

      // Isi field "Isi Feed"
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Isi Feed'),
        'Lagi olahraga di Lapa-NG nih!',
      );

      // Ganti kategori (misal ke Futsal)
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Futsal').last);
      await tester.pumpAndSettle();

      // Isi thumbnail URL
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Thumbnail URL'),
        'https://contoh.com/gambar.jpg',
      );

      // Nyalakan switch Featured
      await tester.tap(find.widgetWithText(SwitchListTile, 'Featured'));
      await tester.pumpAndSettle();

      // Tekan tombol Kirim
      await tester.tap(find.widgetWithText(FilledButton, 'Kirim'));
      await tester.pump(); // validator + onSaved
      await tester.pump(const Duration(milliseconds: 100));

      // post() harus terpanggil sekali dengan body yang benar
      expect(mock.postCallCount, 1);
      expect(mock.lastPostUrl, contains('/feeds/create-ajax/'));
      expect(mock.lastPostBody?['content'], 'Lagi olahraga di Lapa-NG nih!');
      expect(mock.lastPostBody?['category'], 'futsal');
      expect(mock.lastPostBody?['thumbnail'], 'https://contoh.com/gambar.jpg');
      expect(mock.lastPostBody?['is_featured'], 'on');

      // Tidak perlu cek SnackBar sukses karena route sudah di-pop.
      // Cukup pastikan tidak ada exception yang dilempar setelah ini.
      expect(tester.takeException(), isNull);
    });

    testWidgets('menampilkan snackbar error ketika server mengembalikan gagal', (
      WidgetTester tester,
    ) async {
      final mock = MockCookieRequest()..succeedCreate = false;

      await tester.pumpWidget(
        wrapWithProviders(const CreateFeedPage(), request: mock),
      );

      // Isi "Isi Feed" supaya lolos validasi
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Isi Feed'),
        'Isi feed untuk test error',
      );

      // Biarkan kategori default "soccer" dan thumbnail kosong juga tidak apa-apa
      await tester.tap(find.widgetWithText(FilledButton, 'Kirim'));
      await tester.pump(); // validator + onSaved
      await tester.pump(const Duration(milliseconds: 100));

      expect(mock.postCallCount, 1);

      // Muncul snackbar error dengan message dari mock
      await tester.pumpAndSettle();

      expect(
        find.text('Gagal membuat feed: Some error from server'),
        findsOneWidget,
      );
    });
  });
}
