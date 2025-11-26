import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapang/models/venue.dart';
import 'package:lapang/widgets/home/venue_card.dart';
import 'package:lapang/widgets/left_drawer.dart'; // Import Drawer

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Venue>> fetchVenues(CookieRequest request) async {
    // Sesuaikan URL:
    // Android Emulator: 10.0.2.2
    // Web/Browser: 127.0.0.1
    // Device Fisik: IP Laptop (misal 192.168.1.x)
    final response = await request.get('http://127.0.0.1:8000/api/venues/');

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
      body: FutureBuilder(
        future: fetchVenues(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Center(
                child: Text('Belum ada data venue.'),
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
    );
  }
}