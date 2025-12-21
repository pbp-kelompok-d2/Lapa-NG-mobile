import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/screens/reviews/reviews_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MockCookieRequest extends CookieRequest {
  @override
  bool loggedIn = true;

  @override
  Future<dynamic> get(String url) async {
    if (url.contains('get-user-role')) {
      return {'role': 'customer'};
    }
    return [];
  }
}

void main() {
  setUpAll(() => HttpOverrides.global = null);

  testWidgets('ReviewsPage High Coverage Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;

    final mockRequest = MockCookieRequest();

    await tester.pumpWidget(
      Provider<CookieRequest>.value(
        value: mockRequest,
        child: const MaterialApp(
          home: ReviewsPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('LapaNG Reviews'), findsOneWidget);

    final sortButton = find.byIcon(Icons.tune_rounded);
    await tester.tap(sortButton);
    await tester.pumpAndSettle(); // Tunggu modal muncul

    expect(find.text('Urutkan Berdasarkan'), findsOneWidget);
    await tester.tap(find.text('Rating Tertinggi'));
    await tester.pumpAndSettle(); // Tunggu modal tutup

    final searchTrigger = find.text('Cari nama lapangan...');
    await tester.tap(searchTrigger);
    await tester.pumpAndSettle();

    expect(find.text('Filter Lapangan'), findsOneWidget);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    final sports = ['Tennis', 'Badminton', 'Basket'];
    for (var sport in sports) {
      final chip = find.text(sport);
      if (chip.evaluate().isNotEmpty) {
        await tester.tap(chip);
        await tester.pumpAndSettle();
      }
    }

    final myReviewsBtn = find.text('My Reviews');
    await tester.tap(myReviewsBtn);
    await tester.pumpAndSettle();

    final allReviewsBtn = find.text('All Reviews');
    await tester.tap(allReviewsBtn);
    await tester.pumpAndSettle();

    addTearDown(tester.view.resetPhysicalSize);
  });
}