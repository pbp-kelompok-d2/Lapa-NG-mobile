import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/screens/reviews/reviews_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MockCookieRequest extends CookieRequest {
  @override
  Future<dynamic> get(String url) async {
    if (url.contains('get-user-role')) return {'role': 'customer'};
    if (url.contains('venue-list')) return ['Venue A'];
    if (url.contains('get-reviews')) {
      return [
        {
          "pk": 1,
          "user_username": "user1",
          "venue_name": "Venue A",
          "sport_type": "soccer",
          "rating": 5,
          "comment": "Good",
          "created_at": "Date",
          "can_modify": true,
        },
        {
          "pk": 2,
          "user_username": "user2",
          "venue_name": "Venue B",
          "sport_type": "basket",
          "rating": 3,
          "comment": "Bad",
          "created_at": "Date",
          "can_modify": false,
        }
      ];
    }
    return null;
  }
}

void main() {
  setUpAll(() => HttpOverrides.global = null);

  testWidgets('ReviewsPage filter interactions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(Provider<CookieRequest>(
      create: (_) => MockCookieRequest(),
      child: const MaterialApp(home: ReviewsPage()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('user1'), findsOneWidget);
    expect(find.text('user2'), findsOneWidget);

    final horizontalScrollable = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    ).first;

    await tester.scrollUntilVisible(
        find.text('Soccer'),
        500,
        scrollable: horizontalScrollable
    );
    await tester.tap(find.text('Soccer'));
    await tester.pumpAndSettle();

    expect(find.text('user1'), findsOneWidget);
    expect(find.text('user2'), findsNothing);

    await tester.tap(find.text('Semua'));
    await tester.pumpAndSettle();
    expect(find.text('user2'), findsOneWidget);

    final myReviewsBtn = find.text('My Reviews');
    await tester.ensureVisible(myReviewsBtn);
    await tester.tap(myReviewsBtn);
    await tester.pumpAndSettle();

    expect(find.text('user1'), findsOneWidget);
    expect(find.text('user2'), findsNothing);

    addTearDown(tester.view.resetPhysicalSize);
  });
}