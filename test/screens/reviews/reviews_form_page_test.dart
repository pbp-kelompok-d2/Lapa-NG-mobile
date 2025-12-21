import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapang/models/reviews.dart';
import 'package:lapang/screens/reviews/reviews_form_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MockCookieRequest extends CookieRequest {
  @override
  Future<dynamic> postJson(String url, dynamic data) async {
    return {'status': 'success', 'message': 'Review saved'};
  }

  @override
  Future<dynamic> get(String url) async {
    if (url.contains('venue-list')) return ['Venue A'];
    return null;
  }
}

void main() {
  Widget createWidget({Review? review}) {
    return Provider<CookieRequest>(
      create: (_) => MockCookieRequest(),
      child: MaterialApp(home: ReviewFormPage(venues: ['Venue A'], review: review)),
    );
  }

  testWidgets('ReviewFormPage validation hierarchy', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createWidget());

    Future<void> tapKirim() async {
      final btn = find.text('Kirim');
      await tester.tap(btn);
      await tester.pump();
    }

    await tapKirim();
    await tester.pumpAndSettle();
    expect(find.text("Pilih lapangan dulu ya"), findsOneWidget);

    await tester.tap(find.byType(TextFormField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Venue A').last);
    await tester.pumpAndSettle();

    await tapKirim();
    await tester.pumpAndSettle();
    expect(find.text("Wajib diisi"), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), "Mantap");
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tapKirim();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Kasih bintang dulu dong! ⭐"), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final starIcon = find.byIcon(Icons.star_outline_rounded).last;
    await tester.ensureVisible(starIcon);
    await tester.tap(starIcon);
    await tester.pump();

    await tapKirim();

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.byType(ReviewFormPage), findsNothing);

    addTearDown(tester.view.resetPhysicalSize);
  });
}