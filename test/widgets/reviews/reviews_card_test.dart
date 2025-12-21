import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/models/reviews.dart';
import 'package:lapang/screens/reviews/reviews_form_page.dart';
import 'package:lapang/screens/reviews/review_detail_page.dart';
import 'package:lapang/widgets/reviews/reviews_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MockRequestSuccess extends CookieRequest {
  @override
  Future<dynamic> post(String url, dynamic data) async {
    return {'status': 'success'};
  }
}

class MockRequestFail extends CookieRequest {
  @override
  Future<dynamic> post(String url, dynamic data) async {
    return {'status': 'error', 'message': 'Gagal menghapus data'};
  }
}

class MockRequestFailNoMsg extends CookieRequest {
  @override
  Future<dynamic> post(String url, dynamic data) async {
    return {'status': 'error'};
  }
}

void main() {
  Review makeReview({
    required bool canModify,
    String? img,
    String username = "user",
  }) => Review(
      pk: 1,
      userUsername: username,
      venueName: "venue",
      sportType: "soccer",
      rating: 5,
      comment: "comment",
      createdAt: "date",
      canModify: canModify,
      imageUrl: img
  );

  Widget createTestWidget(Review review, CookieRequest req) {
    return Provider<CookieRequest>(
      create: (_) => req,
      child: MaterialApp(
        home: Scaffold(
          body: ReviewCard(
            review: review,
            venueList: const ["venue"],
            onReviewChanged: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('ReviewCard menampilkan "?" jika username kosong', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(makeReview(canModify: false, username: ""), MockRequestSuccess()));
    expect(find.text("?"), findsOneWidget);
  });

  testWidgets('ReviewCard menampilkan gambar jika ada imageUrl', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(makeReview(canModify: false, img: "http://img.com/a.jpg"), MockRequestSuccess()));
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Navigasi ke DetailPage saat card di-tap', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(makeReview(canModify: false), MockRequestSuccess()));
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.byType(ReviewDetailPage), findsOneWidget);
  });

  testWidgets('Navigasi ke FormPage saat tombol edit ditekan', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(makeReview(canModify: true), MockRequestSuccess()));
    await tester.tap(find.byIcon(Icons.edit_note_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewFormPage), findsOneWidget);
  });

  testWidgets('Batal menghapus (klik Batal di Dialog)', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(makeReview(canModify: true), MockRequestSuccess()));
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Batal"));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Skenario hapus sukses', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(makeReview(canModify: true), MockRequestSuccess()));
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Hapus"));
    await tester.pump();
    expect(find.text("Review berhasil dihapus!"), findsOneWidget);
  });

  testWidgets('Skenario hapus gagal dengan pesan dari server', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(makeReview(canModify: true), MockRequestFail()));
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Hapus"));
    await tester.pump();
    expect(find.text("Gagal menghapus data"), findsOneWidget);
  });

  testWidgets('Skenario hapus gagal tanpa pesan (pesan default)', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(makeReview(canModify: true), MockRequestFailNoMsg()));
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Hapus"));
    await tester.pump();
    expect(find.text("Gagal menghapus."), findsOneWidget);
  });
}