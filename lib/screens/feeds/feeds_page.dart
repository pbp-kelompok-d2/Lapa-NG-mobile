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
  static const String baseUrl = "https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id";

  // --- STATE UNTUK FILTER ---
  String _activeFilter = 'all';      // 'all' atau 'my'
  String _selectedCategory = 'all';  // 'all' atau nama kategori di Django

  // daftar kategori sport yang tersedia di backend
  final Map<String, String> _sportCategories = const {
    'all': 'All',
    'soccer': 'Soccer',
    'futsal': 'Futsal',
    'basket': 'Basket',
    'badminton': 'Badminton',
    'other': 'Other',
  };

  Future<List<Feed>> fetchFeeds(CookieRequest request) async {
    // pakai query param filter & category sesuai state
    final url = "$baseUrl/feeds/json/?filter=$_activeFilter&category=$_selectedCategory";

    final response = await request.get(url);

    List<Feed> feeds = [];
    for (var d in response) {
      if (d != null) {
        feeds.add(Feed.fromJson(d));
      }
    }
    return feeds;
  }

  // helper buat bikin pill button All/My Feeds
  Widget _buildFilterButton(String value, String label) {
    final bool selected = _activeFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_activeFilter == value) return;
          setState(() {
            _activeFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.green),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final currentUsername = request.jsonData['username'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lapa-NG Feeds',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          // --- BAGIAN FILTER ATAS (All/My + Dropdown) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // tombol All Feeds & My Feeds
                Expanded(
                  child: Row(
                    children: [
                      _buildFilterButton('all', 'All Feeds'),
                      const SizedBox(width: 8),
                      _buildFilterButton('my', 'My Feeds'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // dropdown Sport Type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sport Type',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        underline: const SizedBox(),
                        isDense: true,
                        items: _sportCategories.entries
                            .map(
                              (e) => DropdownMenuItem<String>(
                                value: e.key, // value = slug di Django
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // --- LIST FEEDS ---
          Expanded(
            child: FutureBuilder<List<Feed>>(
              future: fetchFeeds(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // beda pesan kalau filter 'my'
                  final emptyText = _activeFilter == 'my'
                      ? 'Kamu belum punya feed.'
                      : 'Belum ada feed.';
                  return Center(child: Text(emptyText));
                }

                final feeds = snapshot.data!;
                return ListView.builder(
                  itemCount: feeds.length,
                  itemBuilder: (context, index) {
                    final feed = feeds[index];
                    final isMine = currentUsername != null && currentUsername == feed.userUsername;

                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 750),
                        child: FeedCard(
                          feed: feed,
                          isMine: isMine,
                          onChanged: () {
                            // setelah edit/delete, refresh list
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.pushNamed(context, '/feeds/create');

          if (created == true) {
            setState(() {}); // refresh sesuai filter & kategori yg lagi aktif
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}