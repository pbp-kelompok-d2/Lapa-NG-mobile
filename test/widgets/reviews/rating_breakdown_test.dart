import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/models/reviews.dart';
import 'package:lapang/widgets/reviews/rating_breakdown.dart';

void main() {
  Review makeReview(int rating) {
    return Review(
      pk: 1,
      userUsername: "user",
      venueName: "venue",
      sportType: "soccer",
      rating: rating,
      comment: "comment",
      createdAt: "date",
      canModify: false,
    );
  }

  testWidgets('RatingBreakdown displays correct counts', (WidgetTester tester) async {
    final reviews = [
      makeReview(5),
      makeReview(5),
      makeReview(5),
      makeReview(3),
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: RatingBreakdown(reviews: reviews)),
    ));

    expect(find.text('Statistik'), findsOneWidget);
    expect(find.text('3'), findsAtLeastNWidgets(1));
    expect(find.text('1'), findsAtLeastNWidgets(1));
  });
}