import 'package:flutter/material.dart';
import 'package:lapang/models/feeds.dart';
import 'package:lapang/widgets/feeds/feeds_card.dart';
import 'package:lapang/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MyFeedsPage extends StatefulWidget {
  const MyFeedsPage({super.key});

  @override
  State<MyFeedsPage> createState() => _MyFeedsPageState();
}

class _MyFeedsPageState extends State<MyFeedsPage> {
  static const String baseUrl = "http://localhost:8000";

  Future<List<Feed>> fetchMyFeeds(CookieRequest request) async {
    // pakai filter=my → di show_json sudah disaring ke user login
    final response = await request.get("$baseUrl/feeds/json/?filter=my");
    List<Feed> feeds = [];
    for (var d in response) {
      if (d != null) {
        feeds.add(Feed.fromJson(d));
      }
    }
    return feeds;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Feeds',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<Feed>>(
        future: fetchMyFeeds(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Kamu belum punya feed.'));
          }

          final feeds = snapshot.data!;
          return ListView.builder(
            itemCount: feeds.length,
            itemBuilder: (context, index) => Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: FeedCard(feed: feeds[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
