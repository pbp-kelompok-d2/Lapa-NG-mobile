import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapang/models/reviews.dart';
import 'package:lapang/widgets/reviews/reviews_card.dart';
import 'package:lapang/screens/reviews/reviews_form_page.dart';
import 'package:lapang/widgets/left_drawer.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  String _filterType = "all";
  String _sportFilter = "all";

  // List kategori untuk Filter Chips
  final List<String> _sportTypes = [
    'all', 'soccer', 'tennis', 'badminton', 'futsal', 'basket'
  ];

  // icon sports category
  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'soccer': return Icons.sports_soccer;
      case 'tennis': return Icons.sports_tennis;
      case 'badminton': return Icons.sports_tennis;
      case 'futsal': return Icons.sports_soccer;
      case 'basket': return Icons.sports_basketball;
      default: return Icons.grid_view_rounded;
    }
  }

  String _getSportLabel(String sport) {
    if (sport == 'all') return 'Semua';
    return "${sport[0].toUpperCase()}${sport.substring(1)}";
  }

  Future<List<Review>> fetchReviews(CookieRequest request) async {
    final response = await request.get(
        'http://localhost:8000/reviews/get-reviews/?filter=$_filterType&sport_type=$_sportFilter'
    );

    var data = response;
    List<Review> listReview = [];
    for (var d in data) {
      if (d != null) {
        listReview.add(Review.fromJson(d));
      }
    }
    return listReview;
  }

  // rata-rata rating untuk di header
  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    double total = reviews.fold(0, (sum, item) => sum + item.rating);
    return total / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchReviews(request),
        builder: (context, AsyncSnapshot snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final List<Review> reviews = snapshot.data ?? [];
          final double avgRating = _calculateAverageRating(reviews);

          // CustomScrollView agar header bisa scroll berbarengan dgn list
          return RefreshIndicator(
            onRefresh: () async { setState(() {}); },
            child: CustomScrollView(
              slivers: [
                // APP BAR
                SliverAppBar(
                  title: const Text('Ulasan Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                ),

                // HEADER STATISTIK
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Rata-rata Rating",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  avgRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 40),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${reviews.length} Ulasan Total",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 40),
                        ),
                      ],
                    ),
                  ),
                ),

                // FILTER SECTION
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // filter tab (all & my reviews)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _filterType = "all"),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _filterType == "all" ? primaryColor.withOpacity(0.1) : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Semua Ulasan",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _filterType == "all" ? primaryColor : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(width: 1, height: 20, color: Colors.grey.shade300),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _filterType = "my_reviews"),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _filterType == "my_reviews" ? primaryColor.withOpacity(0.1) : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(11)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Punya Saya",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _filterType == "my_reviews" ? primaryColor : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Filter Kategori
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: _sportTypes.map((sport) {
                            final isSelected = _sportFilter == sport;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Row(
                                  children: [
                                    Icon(
                                      _getSportIcon(sport),
                                      size: 18,
                                      color: isSelected ? Colors.white : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(_getSportLabel(sport)),
                                  ],
                                ),
                                selected: isSelected,
                                selectedColor: primaryColor,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                  ),
                                ),
                                onSelected: (bool selected) {
                                  if (selected) {
                                    setState(() {
                                      _sportFilter = sport;
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // LIST REVIEW
                if (reviews.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            "Belum ada ulasan",
                            style: TextStyle(color: Colors.grey[500], fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return ReviewCard(review: reviews[index]);
                      },
                      childCount: reviews.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),

      // TOMBOL ADD
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReviewFormPage()),
          );
          if (context.mounted) {
            setState(() {});
          }
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text("Tulis Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }
}