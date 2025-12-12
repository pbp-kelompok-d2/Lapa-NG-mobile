import 'package:flutter/material.dart';
import 'package:lapang/widgets/reviews/rating_breakdown.dart';
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
  String? _selectedVenueFilter;
  String _sortOption = "newest";
  String _userRole = "guest";

  List<Review> _allReviews = [];
  List<Review> _filteredReviews = [];
  bool _isLoading = true;
  bool _hasError = false;

  List<String> _venueList = [];

  final List<String> _sportTypes = [
    'all', 'soccer', 'tennis', 'badminton', 'futsal', 'basket'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserRole();
      _initialFetch();
      _fetchVenueNames();
    });
  }

  Future<void> _fetchUserRole() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("http://localhost:8000/reviews/get-user-role/");
      if (mounted) {
        setState(() {
          _userRole = response['role'] ?? "guest";
        });
      }
    } catch (_) {
    }
  }

  Future<void> _fetchVenueNames() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("http://localhost:8000/reviews/venue-list/");
      if (mounted) {
        setState(() {
          _venueList = List<String>.from(response);
        });
      }
    } catch (_) {}
  }

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

  void _applyFilters() {
    setState(() {
      var temp = _allReviews.where((review) {
        // Filter My Reviews
        if (_filterType == "my_reviews" && !review.canModify) return false;

        // Filter Sport
        if (_sportFilter != "all" && review.sportType.toLowerCase() != _sportFilter) return false;

        // Filter Venue
        if (_selectedVenueFilter != null && review.venueName != _selectedVenueFilter) return false;

        return true;
      }).toList();

      if (_sortOption == "rating_high") {
        temp.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (_sortOption == "rating_low") {
        temp.sort((a, b) => a.rating.compareTo(b.rating));
      }

      _filteredReviews = temp;
    });
  }

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

  String _getSportLabel(String sport) {
    if (sport == 'all') return 'Semua';
    return "${sport[0].toUpperCase()}${sport.substring(1)}";
  }

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'soccer': return Icons.sports_soccer;
      case 'tennis': return Icons.sports_tennis;
      case 'badminton': return Icons.sports_tennis;
      case 'futsal': return Icons.sports_soccer;
      case 'basket': return Icons.sports_basketball;
      case 'all': return Icons.grid_view_rounded; // Ikon khusus untuk "Semua"
      default: return Icons.sports;
    }
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
      backgroundColor: const Color(0xFFF5F7FA),
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
              title: const Text('Review Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              floating: true, pinned: true, elevation: 0,
              centerTitle: true,
            ),

            // HEADER
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Container(height: 80, decoration: BoxDecoration(color: primaryColor, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _showVenueFilterPicker(context),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                                        child: Row(
                                          children: [
                                            Icon(Icons.search_rounded, color: Colors.grey[600], size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(child: Text(_selectedVenueFilter ?? "Cari nama lapangan...", style: TextStyle(color: _selectedVenueFilter != null ? Colors.black87 : Colors.grey[500], fontSize: 14, fontWeight: _selectedVenueFilter != null ? FontWeight.w600 : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                            if (_selectedVenueFilter != null) GestureDetector(onTap: () { setState(() { _selectedVenueFilter = null; _applyFilters(); }); }, child: const Icon(Icons.close, size: 18, color: Colors.grey))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _showSortModal(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)), child: const Icon(Icons.tune_rounded, color: Colors.black87, size: 24)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 20), const SizedBox(width: 4), Text(avgRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(" Rata-rata", style: TextStyle(color: Colors.grey[600], fontSize: 12))]),
                                  Text("${_filteredReviews.length} Review", style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: RatingBreakdown(reviews: _filteredReviews),
              ),
            ),


            if (_userRole == 'customer')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(25)),
                    child: Row(
                      children: [
                        _buildToggleOption("All Reviews", "all"),
                        _buildToggleOption("My Reviews", "my_reviews"),
                      ],
                    ),
                  ),
                ),
              ),

            // CHIPS KATEGORI
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _sportTypes.map((sport) {
                    final isSelected = _sportFilter == sport;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(_getSportLabel(sport)),
                        avatar: isSelected
                            ? null
                            : Icon(
                            _getSportIcon(sport),
                            size: 18,
                            color: Colors.grey[600]
                        ),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() {
                              _sportFilter = sport;
                              _applyFilters();
                            });
                          }
                        },
                        backgroundColor: Colors.white,
                        selectedColor: primaryColor.withOpacity(0.15),
                        checkmarkColor: primaryColor,
                        labelStyle: TextStyle(
                            color: isSelected ? primaryColor : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: isSelected ? primaryColor : Colors.grey[300]!
                            )
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // LIST REVIEWS
            if (_filteredReviews.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      const Text("Review tidak ditemukan", style: TextStyle(color: Colors.grey)),
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
                      venueList: _venueList,
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

      // <--- 4. LOGIKA FAB: Hanya muncul jika role = customer
      floatingActionButton: _userRole == 'customer'
          ? FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewFormPage(venues: _venueList)));
          if (context.mounted) {
            _initialFetch();
          }
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text("Tulis Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
          : null, // Kalau bukan customer, tombol hilang
    );
  }

  Widget _buildToggleOption(String title, String value) {
    final isSelected = _filterType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () { setState(() { _filterType = value; _applyFilters(); }); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(20), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 1))] : []),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? Colors.black87 : Colors.grey[600])),
        ),
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