import 'package:flutter/material.dart';
import 'package:lapang/screens/feeds/create_feeds.dart';
import 'package:lapang/screens/feeds/feeds_page.dart';
import 'package:lapang/screens/feeds/my_feeds_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapang/screens/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Lapa-NG',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green,
          ).copyWith(secondary: Colors.green[400]),
        ),
        home: const HomePage(),
        routes: {
          '/feeds': (context) => const FeedsPage(),
          '/feeds/my': (context) => const MyFeedsPage(),
          '/feeds/create': (context) => const CreateFeedPage(),
        },
      ),
    );
  }
}