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
  String _searchQuery = "";
  String? _selectedCategory;

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
    // Android Emulator: 10.0.2.2
    // Web/Chrome: 127.0.0.1
    const String baseUrl = "http://127.0.0.1:8000";

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
      if (d != null) {
        listVenue.add(Venue.fromJson(d));
      }
    }

    // === LOGIC SORTING (Featured First) ===
    // Mengurutkan list: Venue yang isFeatured=true akan ditaruh di paling atas.
    // Jika sama-sama featured atau tidak, urutkan berdasarkan nama.
    listVenue.sort((a, b) {
      if (a.fields.isFeatured == b.fields.isFeatured) {
        return a.fields.name.compareTo(b.fields.name);
      }
      return a.fields.isFeatured ? -1 : 1;
    });

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
          // === SEARCH BAR ===
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
                setState(() {
                  _searchQuery = value;
                  _selectedCategory = null;
                });
              },
            ),
          ),

          // === FILTER CHIPS ===
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: const Text("All"),
                    selected: _selectedCategory == null && _searchQuery.isEmpty,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = null;
                        _searchQuery = "";
                      });
                    },
                  ),
                ),
                ..._categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                          _searchQuery = "";
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // === RESPONSIVE GRID LIST ===
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
                    return const Center(child: Text('Tidak ada venue yang ditemukan.'));
                  } else {

                    // LayoutBuilder digunakan untuk mendapatkan lebar layar saat ini
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        // Logic Responsif:
                        // Default (Mobile kecil): 2 kolom
                        int crossAxisCount = 2;

                        // Tablet / Layar sedang (> 600px): 4 kolom
                        if (constraints.maxWidth > 600 && constraints.maxWidth <= 1200) {
                          crossAxisCount = 4;
                        }
                        // Desktop / Layar Besar (> 1200px): 7 kolom
                        else if (constraints.maxWidth > 1200) {
                          crossAxisCount = 7;
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            // childAspectRatio mengatur perbandingan lebar:tinggi kartu.
                            // Angka 0.7 - 0.8 biasanya pas untuk kartu vertical.
                            childAspectRatio: 0.75,
                          ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (_, index) => VenueCard(venue: snapshot.data![index]),
                        );
                      },
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