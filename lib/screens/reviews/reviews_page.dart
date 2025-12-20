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
  List<String> _bookedVenueNames = [];

  final List<String> _sportTypes = [
    'all', 'soccer', 'tennis', 'badminton', 'futsal', 'basket'
  ];

  // lib/screens/reviews/reviews_page.dart

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final request = context.read<CookieRequest>();

      if (request.loggedIn) {
        await _fetchUserRole();
        await _initialFetch();
        await _fetchVenueNames();
        await _fetchBookedVenues();
      } else {
        _initialFetch();
        _fetchVenueNames();
      }
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
    } catch (_) {}
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

  Future<void> _fetchBookedVenues() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("http://localhost:8000/reviews/get-booked-venues/");

      if (response is List && mounted) {
        setState(() {
          _bookedVenueNames = List<String>.from(response);
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil data booking: $e");
    }
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
        if (_filterType == "my_reviews" && !review.canModify) return false;
        if (_sportFilter != "all" && review.sportType.toLowerCase() != _sportFilter) return false;
        if (_selectedVenueFilter != null && review.venueName != _selectedVenueFilter) return false;
        return true;
      }).toList();

      if (_sortOption == "rating_high") {
        temp.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (_sortOption == "rating_low") {
        temp.sort((a, b) => a.rating.compareTo(b.rating));
      } else {
        temp.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      _filteredReviews = temp;
    });
  }

  double _calculateAverageRating() {
    if (_filteredReviews.isEmpty) return 0.0;
    double total = _filteredReviews.fold(0, (sum, item) => sum + item.rating);
    return total / _filteredReviews.length;
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
      case 'all': return Icons.grid_view_rounded;
      default: return Icons.sports;
    }
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
                    onPressed: () { setState(() { _selectedVenueFilter = null; _applyFilters(); }); Navigator.pop(context); },
                    child: const Text("Reset", style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
            ),
            Expanded(child: _VenueSearchList(allVenues: _venueList, onSelect: (selected) { setState(() { _selectedVenueFilter = selected; _applyFilters(); }); Navigator.pop(context); }))
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
              _buildSortTile("Terbaru", "newest", Icons.access_time_rounded),
              _buildSortTile("Rating Tertinggi", "rating_high", Icons.star_rounded),
              _buildSortTile("Rating Terendah", "rating_low", Icons.star_outline_rounded),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: value.contains("rating") ? Colors.amber : Colors.grey),
      title: Text(title),
      trailing: _sortOption == value ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
      onTap: () { setState(() { _sortOption = value; _applyFilters(); }); Navigator.pop(context); },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const LeftDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? const Center(child: Text("Gagal memuat data."))
          : RefreshIndicator(
        onRefresh: _initialFetch,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 900;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: const Text('LapaNG Reviews', style: TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  floating: true, pinned: true, elevation: 2,
                  centerTitle: true,
                ),

                // HEADER (Full Width)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: primaryColor, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      child: isDesktop
                          ? _buildDesktopHeader(primaryColor)
                          : _buildMobileHeader(primaryColor),
                    ),
                  ),
                ),

                // FILTER SECTION
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      if (_userRole == 'customer')
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey[200]!)),
                            child: Row(
                              children: [
                                _buildToggleOption("All Reviews", "all", primaryColor),
                                _buildToggleOption("My Reviews", "my_reviews", primaryColor),
                              ],
                            ),
                          ),
                        ),

                      Container(
                        height: 60,
                        margin: const EdgeInsets.only(top: 8),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: _sportTypes.map((sport) {
                            final isSelected = _sportFilter == sport;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: FilterChip(
                                showCheckmark: false,
                                avatar: Icon(_getSportIcon(sport), size: 18, color: isSelected ? Colors.white : Colors.grey[600]),
                                label: Text(_getSportLabel(sport)),
                                selected: isSelected,
                                onSelected: (bool selected) { if (selected) { setState(() { _sportFilter = sport; _applyFilters(); }); } },
                                backgroundColor: Colors.white,
                                selectedColor: primaryColor,
                                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? primaryColor : Colors.grey[300]!)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // GRID REVIEWS
                if (_filteredReviews.isEmpty)
                  const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text("Review tidak ditemukan")))
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => ReviewCard(
                          review: _filteredReviews[index],
                          venueList: _venueList,
                          onReviewChanged: () => _initialFetch(),
                        ),
                        childCount: _filteredReviews.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth < 650 ? 1 :
                        (constraints.maxWidth < 1100 ? 2 :
                        (constraints.maxWidth < 1500 ? 3 : 4)),
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 400,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),

      floatingActionButton: _userRole == 'customer'
          ? FloatingActionButton.extended(
        onPressed: () async {
          if (_bookedVenueNames.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Kamu hanya bisa mengulas lapangan yang sudah pernah kamu pesan."),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReviewFormPage(
                    venues: _bookedVenueNames,
                  )
              )
          );

          if (context.mounted) {
            _initialFetch();
          }
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text("Tulis Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
          : null,
    );
  }

  Widget _buildMobileHeader(Color primaryColor) {
    return Column(children: [_buildSearchAndSort(), const SizedBox(height: 20), RatingBreakdown(reviews: _filteredReviews)]);
  }

  Widget _buildDesktopHeader(Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Temukan Review Lapangan Terbaik", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSearchAndSort(),
        ])),
        const SizedBox(width: 40),
        Expanded(flex: 3, child: RatingBreakdown(reviews: _filteredReviews)),
      ],
    );
  }

  Widget _buildSearchAndSort() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showVenueFilterPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 20, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_selectedVenueFilter ?? "Cari nama lapangan...", overflow: TextOverflow.ellipsis, style: TextStyle(color: _selectedVenueFilter != null ? Colors.black87 : Colors.grey))),
                        if (_selectedVenueFilter != null) IconButton(onPressed: () => setState(() => _selectedVenueFilter = null), icon: const Icon(Icons.close, size: 18))
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), child: IconButton(onPressed: () => _showSortModal(context), icon: const Icon(Icons.tune_rounded))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 20), const SizedBox(width: 4), Text(_calculateAverageRating().toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold))]),
              Text("${_filteredReviews.length} Ulasan", style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildToggleOption(String title, String value, Color primaryColor) {
    bool isSelected = _filterType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _filterType = value; _applyFilters(); }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: isSelected ? primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(25)),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey[600])),
        ),
      ),
    );
  }
}

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
    final filtered = widget.allVenues.where((v) => v.toLowerCase().contains(_query.toLowerCase())).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(decoration: InputDecoration(hintText: "Cari nama lapangan...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), onChanged: (v) => setState(() => _query = v))),
      Expanded(child: filtered.isEmpty ? const Center(child: Text("Tidak ditemukan")) : ListView.builder(itemCount: filtered.length, itemBuilder: (ctx, i) => ListTile(title: Text(filtered[i]), leading: const Icon(Icons.location_on_outlined), onTap: () => widget.onSelect(filtered[i]))))
    ]);
  }
}