import 'package:flutter/material.dart';
import 'package:lapang/models/feeds.dart';
import 'package:lapang/widgets/feeds/feeds_card.dart';
import 'package:lapang/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class FeedsPage extends StatefulWidget {
  const FeedsPage({super.key});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  static const String baseUrl = "http://localhost:8000";

  Future<List<Feed>> fetchFeeds(CookieRequest request) async {
    // ini langsung pakai show_json di Django (filter=all default)
    final response = await request.get("$baseUrl/feeds/json/");

    // response dari CookieRequest sudah berupa List<dynamic> (Map)
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
          'Lapa-NG Feeds',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<Feed>>(
        future: fetchFeeds(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada feed.'));
          }

          final feeds = snapshot.data!;
          return ListView.builder(
            itemCount: feeds.length,
            itemBuilder: (context, index) => Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 750, // atur lebar maksimum card
                ),
                child: FeedCard(feed: feeds[index]),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/feeds/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
