import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/screens/reviews/review_detail_page.dart';
import 'package:lapang/models/reviews.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MockCookieRequest extends CookieRequest {}

void main() {
  final review = Review(
      pk: 1, userUsername: "user", venueName: "Venue A", sportType: "soccer",
      rating: 5, comment: "Detail Comment", createdAt: "Date", canModify: true,
      imageUrl: "http://img.com/a.jpg"
  );

  testWidgets('ReviewDetailPage renders correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(Provider<CookieRequest>(
      create: (_) => MockCookieRequest(),
      child: MaterialApp(home: ReviewDetailPage(review: review, venueList: const [])),
    ));

    expect(find.text('Venue A'), findsOneWidget);
    expect(find.text('Detail Comment'), findsOneWidget);

    expect(find.byType(Image), findsOneWidget);

    await tester.scrollUntilVisible(find.text("Edit"), 500); // Scroll ke bawah kalau ketutupan
    expect(find.text("Edit"), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}