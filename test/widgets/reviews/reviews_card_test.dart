import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/models/reviews.dart';
import 'package:lapang/widgets/reviews/reviews_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MockCookieRequest extends CookieRequest {
  @override
  Future<dynamic> post(String url, dynamic data) async {
    return {'status': 'success', 'message': 'Deleted'};
  }
}

void main() {
  Review makeReview({required bool canModify, String? img}) => Review(
      pk: 1, userUsername: "user", venueName: "venue", sportType: "soccer",
      rating: 5, comment: "comment", createdAt: "date", canModify: canModify, imageUrl: img
  );

  Widget createTestWidget(Review review) {
    return Provider<CookieRequest>(
      create: (_) => MockCookieRequest(),
      child: MaterialApp(home: Scaffold(body: ReviewCard(review: review, venueList: const []))),
    );
  }

  testWidgets('ReviewCard displays image if present', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(makeReview(canModify: false, img: "http://img.com/a.jpg")));
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('ReviewCard hides buttons for non-owner', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(makeReview(canModify: false)));
    expect(find.byIcon(Icons.edit_rounded), findsNothing);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
  });

  testWidgets('ReviewCard delete flow works', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(makeReview(canModify: true)));

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text("Hapus Review"), findsOneWidget);
    expect(find.text("Batal"), findsOneWidget);
    expect(find.text("Hapus"), findsOneWidget);

    await tester.tap(find.text("Hapus"));

    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text("Review berhasil dihapus!"), findsOneWidget);
  });
}