import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/screens/reviews/reviews_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MockCookieRequest extends CookieRequest {
  @override
  Future<dynamic> get(String url) async {
    if (url.contains('get-user-role')) {
      return {'role': 'customer'};
    }
    if (url.contains('venue-list')) {
      return ['Venue A', 'Venue B'];
    }
    if (url.contains('get-booked-venues')) {
      return ['Venue A'];
    }
    if (url.contains('get-reviews')) {
      return [
        {
          "user_username": "user1",
          "venue_name": "Venue A",
          "sport_type": "soccer",
          "rating": 5,
          "comment": "Mantap!",
          "created_at": "2023-12-21T00:00:00Z",
          "can_modify": true,
        },
        {
          "user_username": "user2",
          "venue_name": "Venue B",
          "sport_type": "basket",
          "rating": 3,
          "comment": "Biasa aja.",
          "created_at": "2023-12-20T00:00:00Z",
          "can_modify": false,
        }
      ];
    }
    return [];
  }
}

void main() {
  setUpAll(() => HttpOverrides.global = null);

  testWidgets('ReviewsPage UI and Interaction Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      Provider<CookieRequest>(
        create: (_) => MockCookieRequest(),
        child: const MaterialApp(
          home: ReviewsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('LapaNG Reviews'), findsOneWidget);
    expect(find.text('user1'), findsOneWidget);
    expect(find.text('user2'), findsOneWidget);

    await tester.tap(find.text('Soccer'));
    await tester.pumpAndSettle();
    expect(find.text('user1'), findsOneWidget);
    expect(find.text('user2'), findsNothing);

    await tester.tap(find.text('Semua'));
    await tester.pumpAndSettle();
    expect(find.text('user2'), findsOneWidget);

    final myReviewsBtn = find.text('My Reviews');
    await tester.tap(myReviewsBtn);
    await tester.pumpAndSettle();
    expect(find.text('user1'), findsOneWidget);
    expect(find.text('user2'), findsNothing);

    expect(find.byType(FloatingActionButton), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}