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

  testWidgets('RatingBreakdown tidak menampilkan apa-apa jika list kosong', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: RatingBreakdown(reviews: [])),
    ));

    expect(find.byType(Container), findsNothing);
    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('RatingBreakdown menampilkan statistik ulasan dengan benar', (WidgetTester tester) async {
    final reviews = [
      makeReview(5),
      makeReview(5),
      makeReview(5),
      makeReview(3),
    ];

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue),
      home: Scaffold(body: RatingBreakdown(reviews: reviews)),
    ));

    expect(find.textContaining('Statistik Rating Anda'), findsOneWidget);

    expect(find.text('3'), findsAtLeastNWidgets(1));

    expect(find.text('0'), findsNWidgets(3));

    expect(find.byType(LinearProgressIndicator), findsNWidgets(5));
  });

  testWidgets('RatingBreakdown menghitung persentase dengan benar', (WidgetTester tester) async {
    final reviews = [makeReview(5)];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: RatingBreakdown(reviews: reviews)),
    ));

    final progressBars = tester.widgetList<LinearProgressIndicator>(find.byType(LinearProgressIndicator));

    expect(progressBars.first.value, 1.0);

    expect(progressBars.elementAt(1).value, 0.0);
  });
}