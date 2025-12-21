import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapang/models/venue.dart';
import 'package:lapang/widgets/home/venue_card.dart';
import 'package:lapang/widgets/left_drawer.dart';

class VenuesPage extends StatefulWidget {
  const VenuesPage({super.key});

  @override
  State<VenuesPage> createState() => _VenuesPageState();
}

class _VenuesPageState extends State<VenuesPage> {
  String _searchQuery = "";
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Soccer', 'Futsal', 'Badminton', 'Basketball', 'Tennis', 'Volleyball', 'Multi-Sport', 'Other'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getEndpointUrl() {
    const String baseUrl = "https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id";
    if (_searchQuery.isNotEmpty) {
      return "$baseUrl/api/venues/search/?q=$_searchQuery";
    } else if (_selectedCategory != null) {
      return "$baseUrl/api/venues/filter/?sport=$_selectedCategory";
    } else {
      return "$baseUrl/api/venues/";
    }
  }

  Future<List<Venue>> fetchVenues(CookieRequest request) async {
    final String url = _getEndpointUrl();
    final response = await request.get(url);
    var data = response;
    List<Venue> listVenue = [];
    for (var d in data) {
      if (d != null) listVenue.add(Venue.fromJson(d));
    }
    listVenue.sort((a, b) {
      if (a.fields.isFeatured == b.fields.isFeatured) {
        return a.fields.name.compareTo(b.fields.name);
      }
      return a.fields.isFeatured ? -1 : 1;
    });
    return listVenue;
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text;
      _selectedCategory = null;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) => _performSearch(),
      decoration: InputDecoration(
        hintText: "Cari lapangan...",
        suffixIcon: Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _performSearch,
            tooltip: "Cari",
          ),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCategoryChips({bool isVertical = false}) {
    List<Widget> chips = [
      _buildSingleChip("All", _selectedCategory == null && _searchQuery.isEmpty, isVertical),
      ..._categories.map((cat) => _buildSingleChip(cat, _selectedCategory == cat, isVertical)),
    ];

    if (isVertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: chips.map((c) => Padding(padding: const EdgeInsets.only(bottom: 8), child: c)).toList(),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips.map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: c)).toList(),
        ),
      );
    }
  }

  Widget _buildSingleChip(String label, bool isActive, bool isFullWidth) {
    return InkWell(
      onTap: () {
        setState(() {
          if (label == "All") {
            _selectedCategory = null;
            _searchQuery = "";
            _searchController.clear();
          } else {
            _selectedCategory = isActive ? null : label;
            _searchQuery = "";
            _searchController.clear();
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? Colors.green : Colors.grey.shade300),
          boxShadow: isActive ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : [],
        ),
        child: Text(
          label,
          textAlign: isFullWidth ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Browse Venues', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 900;

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 280,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Search", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        _buildSearchBar(),
                        const SizedBox(height: 32),
                        const Text("Categories", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        _buildCategoryChips(isVertical: true),
                      ],
                    ),
                  ),
                ),
                Expanded(child: _buildVenueGrid(request, constraints)),
              ],
            );
          } else {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                  ),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      _buildCategoryChips(isVertical: false),
                    ],
                  ),
                ),
                Expanded(child: _buildVenueGrid(request, constraints)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildVenueGrid(CookieRequest request, BoxConstraints constraints) {
    return FutureBuilder(
      future: fetchVenues(request),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Tidak ada venue ditemukan.', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          } else {
            double width = constraints.maxWidth;
            if (width > 900) width -= 280;

            int crossAxisCount;
            if (width <= 600) crossAxisCount = 2;
            else if (width <= 900) crossAxisCount = 3;
            else if (width <= 1200) crossAxisCount = 4;
            else if (width <= 1500) crossAxisCount = 5;
            else crossAxisCount = 6;

            double screenPadding = 32.0;
            double itemSpacing = 16.0;
            double totalSpacing = (crossAxisCount - 1) * itemSpacing;
            double itemWidth = (width - screenPadding - totalSpacing) / crossAxisCount;
            double fixedCardHeight = 300.0;
            double childAspectRatio = itemWidth / fixedCardHeight;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) => VenueCard(venue: snapshot.data![index]),
            );
          }
        }
      },
    );
  }
}