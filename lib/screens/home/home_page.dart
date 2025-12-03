import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapang/models/venue.dart';
import 'package:lapang/widgets/home/venue_card.dart';
import 'package:lapang/widgets/left_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State untuk Search & Filter
  String _searchQuery = "";
  String? _selectedCategory;

  // Daftar kategori (sesuai dengan models.py di Django)
  final List<String> _categories = [
    'Soccer',
    'Futsal',
    'Badminton',
    'Basketball',
    'Tennis',
    'Volleyball',
    'Multi-Sport',
    'Other'
  ];

  String _getEndpointUrl() {
    const String baseUrl = "http://127.0.0.1:8000";

    if (_searchQuery.isNotEmpty) {
      // Panggil API Search
      return "$baseUrl/api/venues/search/?q=$_searchQuery";
    } else if (_selectedCategory != null) {
      // Panggil API Filter
      return "$baseUrl/api/venues/filter/?sport=$_selectedCategory";
    } else {
      // Panggil API List Semua Venue
      return "$baseUrl/api/venues/";
    }
  }

  Future<List<Venue>> fetchVenues(CookieRequest request) async {
    final String url = _getEndpointUrl();
    final response = await request.get(url);

    var data = response;

    List<Venue> listVenue = [];
    for (var d in data) {
      if (d != null) {
        listVenue.add(Venue.fromJson(d));
      }
    }
    return listVenue;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapa-NG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          // search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari lapangan...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onChanged: (value) {
                // Set state query, reset category biar gak bentrok
                setState(() {
                  _searchQuery = value;
                  _selectedCategory = null;
                });
              },
            ),
          ),

          // category filter (horizontal scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Tombol "All" untuk reset filter
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: const Text("All"),
                    selected: _selectedCategory == null && _searchQuery.isEmpty,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = null;
                        _searchQuery = ""; // Reset search juga
                      });
                    },
                  ),
                ),
                // Generate Chips dari List Kategori
                ..._categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (bool selected) {
                        setState(() {
                          // Jika diklik lagi, unselect (jadi null). Jika belum, set category.
                          _selectedCategory = selected ? category : null;
                          _searchQuery = ""; // Reset search saat filter aktif
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // List Venue
          Expanded(
            child: FutureBuilder(
              future: fetchVenues(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada venue yang ditemukan.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) => VenueCard(venue: snapshot.data![index]),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}