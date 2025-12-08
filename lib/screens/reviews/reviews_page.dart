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
  // --- STATE FILTER & SORT ---
  String _filterType = "all";
  String _sportFilter = "all";
  String? _selectedVenueFilter;
  String _sortOption = "newest";

  // List Data
  List<Review> _allReviews = [];
  List<Review> _filteredReviews = [];
  bool _isLoading = true;
  bool _hasError = false;

  // Dataset Nama Lapangan
  List<String> _venueList = [];

  final List<String> _sportTypes = [
    'all', 'soccer', 'tennis', 'badminton', 'futsal', 'basket'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialFetch();
      _fetchVenueNames();
    });
  }

  // Fetch Dataset Lapangan
  Future<void> _fetchVenueNames() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("http://localhost:8000/reviews/venue-list/");
      if (mounted) {
        setState(() {
          _venueList = List<String>.from(response);
        });
      }
    } catch (_) {
    }
  }

  // Fetch Data Review Utama
  Future<void> _initialFetch() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('http://localhost:8000/reviews/get-reviews/');
      List<Review> fetchedData = [];
      for (var d in response) {
        if (d != null) fetchedData.add(Review.fromJson(d));
      }

      if (mounted) {
        setState(() {
          _allReviews = fetchedData;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
    }
  }

  // --- LOGIKA FILTER & SORT ---
  void _applyFilters() {
    setState(() {
      // 1. FILTERING
      var temp = _allReviews.where((review) {
        // Filter Tab (My Reviews)
        if (_filterType == "my_reviews" && !review.canModify) return false;

        // Filter Sport
        if (_sportFilter != "all" && review.sportType.toLowerCase() != _sportFilter) return false;

        // Filter Venue (Nama Lapangan)
        if (_selectedVenueFilter != null && review.venueName != _selectedVenueFilter) return false;

        return true;
      }).toList();

      // 2. SORTING
      if (_sortOption == "rating_high") {
        temp.sort((a, b) => b.rating.compareTo(a.rating)); // Besar ke Kecil
      } else if (_sortOption == "rating_low") {
        temp.sort((a, b) => a.rating.compareTo(b.rating)); // Kecil ke Besar
      } else {
      }

      _filteredReviews = temp;
    });
  }

  // MODAL FILTER VENUE (Searchable)
  void _showVenueFilterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.5, expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),

            // Header Modal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Filter Lapangan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      setState(() { _selectedVenueFilter = null; _applyFilters(); });
                      Navigator.pop(context);
                    },
                    child: const Text("Reset", style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
            ),

            Expanded(
              child: _VenueSearchList(
                allVenues: _venueList,
                onSelect: (selected) {
                  setState(() { _selectedVenueFilter = selected; _applyFilters(); });
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // MODAL SORTIR
  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const Text("Urutkan Berdasarkan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time_rounded),
                title: const Text("Terbaru"),
                trailing: _sortOption == "newest" ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                onTap: () { setState(() { _sortOption = "newest"; _applyFilters(); }); Navigator.pop(context); },
              ),
              ListTile(
                leading: const Icon(Icons.star_rounded, color: Colors.amber),
                title: const Text("Rating Tertinggi"),
                trailing: _sortOption == "rating_high" ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                onTap: () { setState(() { _sortOption = "rating_high"; _applyFilters(); }); Navigator.pop(context); },
              ),
              ListTile(
                leading: const Icon(Icons.star_outline_rounded),
                title: const Text("Rating Terendah"),
                trailing: _sortOption == "rating_low" ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                onTap: () { setState(() { _sortOption = "rating_low"; _applyFilters(); }); Navigator.pop(context); },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Helpers
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
  double _calculateAverageRating() {
    if (_filteredReviews.isEmpty) return 0.0;
    double total = _filteredReviews.fold(0, (sum, item) => sum + item.rating);
    return total / _filteredReviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final double avgRating = _calculateAverageRating();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const LeftDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? const Center(child: Text("Gagal memuat data."))
          : RefreshIndicator(
        onRefresh: _initialFetch,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Ulasan Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              floating: true, pinned: true, elevation: 0,
            ),

            // HEADER STATISTIK
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Rata-rata Rating", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(avgRating.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0)),
                            const SizedBox(width: 8),
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 40),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("${_filteredReviews.length} Ulasan Total", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 40),
                    ),
                  ],
                ),
              ),
            ),

            // FILTER & SORT SECTION
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Tombol Filter & Sort
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Tombol Filter Venue
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showVenueFilterPicker(context),
                            icon: const Icon(Icons.stadium_outlined, size: 18),
                            label: Text(
                              _selectedVenueFilter ?? "Pilih Lapangan",
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _selectedVenueFilter != null ? primaryColor : Colors.black87,
                              side: BorderSide(color: _selectedVenueFilter != null ? primaryColor : Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Tombol Filtering
                        OutlinedButton.icon(
                          onPressed: () => _showSortModal(context),
                          icon: const Icon(Icons.sort, size: 18),
                          label: const Text("Urut"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tab Filter (All dan My Reviews)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                      child: Row(
                        children: [
                          Expanded(child: GestureDetector(onTap: () { _filterType = "all"; _applyFilters(); }, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: _filterType == "all" ? primaryColor.withOpacity(0.1) : Colors.transparent, borderRadius: const BorderRadius.horizontal(left: Radius.circular(11))), alignment: Alignment.center, child: Text("Semua Ulasan", style: TextStyle(fontWeight: FontWeight.bold, color: _filterType == "all" ? primaryColor : Colors.grey))))),
                          Container(width: 1, height: 20, color: Colors.grey.shade300),
                          Expanded(child: GestureDetector(onTap: () { _filterType = "my_reviews"; _applyFilters(); }, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: _filterType == "my_reviews" ? primaryColor.withOpacity(0.1) : Colors.transparent, borderRadius: const BorderRadius.horizontal(right: Radius.circular(11))), alignment: Alignment.center, child: Text("Punya Saya", style: TextStyle(fontWeight: FontWeight.bold, color: _filterType == "my_reviews" ? primaryColor : Colors.grey))))),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filter Chips Kategori
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _sportTypes.map((sport) {
                        final isSelected = _sportFilter == sport;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Row(children: [Icon(_getSportIcon(sport), size: 18, color: isSelected ? Colors.white : Colors.grey[600]), const SizedBox(width: 6), Text(_getSportLabel(sport))]),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)),
                            onSelected: (bool selected) { if (selected) { _sportFilter = sport; _applyFilters(); } },
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
            if (_filteredReviews.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_alt_off_rounded, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text("Tidak ada ulasan yang cocok", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return ReviewCard(
                      review: _filteredReviews[index],
                      onReviewChanged: () {
                        _initialFetch();
                      },
                    );
                  },
                  childCount: _filteredReviews.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),

      // TOMBOL ADD
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewFormPage()));
          if (context.mounted) {
            _initialFetch();
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

// === WIDGET SEARCH VENUE ===
class _VenueSearchList extends StatefulWidget {
  final List<String> allVenues;
  final Function(String) onSelect;
  const _VenueSearchList({required this.allVenues, required this.onSelect});
  @override
  State<_VenueSearchList> createState() => _VenueSearchListState();
}
class _VenueSearchListState extends State<_VenueSearchList> {
  String _query = "";
  @override
  Widget build(BuildContext context) {
    final filtered = widget.allVenues.where((venue) => venue.toLowerCase().contains(_query.toLowerCase())).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: TextField(autofocus: false, decoration: InputDecoration(hintText: "Cari nama lapangan...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16)), onChanged: (val) => setState(() => _query = val))),
      const SizedBox(height: 10),
      Expanded(child: filtered.isEmpty ? const Center(child: Text("Lapangan tidak ditemukan 😢", style: TextStyle(color: Colors.grey))) : ListView.separated(itemCount: filtered.length, separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 16, endIndent: 16), itemBuilder: (context, index) => ListTile(title: Text(filtered[index], style: const TextStyle(fontSize: 16)), leading: const Icon(Icons.stadium_outlined, color: Colors.grey), onTap: () => widget.onSelect(filtered[index])))),
    ]);
  }
}