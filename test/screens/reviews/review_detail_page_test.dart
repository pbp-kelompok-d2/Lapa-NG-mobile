import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/screens/reviews/review_detail_page.dart';
import 'package:lapang/models/reviews.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MockCookieRequest extends CookieRequest {
  @override
  Future<dynamic> post(String url, dynamic body) async {
    if (url.contains('delete-review')) {
      return {'status': 'success', 'message': 'Berhasil dihapus!'};
    }
    return {'status': 'error', 'message': 'Gagal'};
  }
}

void main() {
  setUpAll(() => HttpOverrides.global = null);

  final reviewLengkap = Review(
      pk: 1, userUsername: "levina", venueName: "Venue A", sportType: "soccer",
      rating: 5, comment: "Mantap!", createdAt: "2023-12-21", canModify: true,
      imageUrl: "http://img.com/a.jpg"
  );

  testWidgets('ReviewDetailPage Full Coverage Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;

    final mockRequest = MockCookieRequest();

    await tester.pumpWidget(Provider<CookieRequest>.value(
      value: mockRequest,
      child: MaterialApp(
        home: ReviewDetailPage(review: reviewLengkap, venueList: const ["Venue A"]),
      ),
    ));

    await tester.pumpAndSettle();

    final deleteBtn = find.text("Hapus");
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    await tester.tap(find.text("Hapus").last);

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("Berhasil dihapus!"), findsOneWidget);

    await tester.pumpAndSettle();

    addTearDown(tester.view.resetPhysicalSize);
  });
}