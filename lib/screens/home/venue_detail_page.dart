import 'package:flutter/material.dart';
import 'package:lapang/models/venue.dart';

class VenueDetailPage extends StatelessWidget {
  final Venue venue;

  const VenueDetailPage({super.key, required this.venue});

  String _fixImageUrl(String url) {
    if (url.contains('localhost')) return url.replaceAll('localhost', '10.0.2.2');
    if (url.contains('127.0.0.1')) return url.replaceAll('127.0.0.1', '10.0.2.2');
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final fields = venue.fields;
    final imageUrl = _fixImageUrl(fields.imageUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Venue", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Header
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) =>
                    Container(height: 250, color: Colors.grey, child: const Center(child: Icon(Icons.error))),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Venue
                  Text(fields.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Chips Kategori & Kapasitas
                  Row(
                    children: [
                      Chip(
                        label: Text(fields.category),
                        backgroundColor: Colors.green[50],
                      ),
                      const SizedBox(width: 8),
                      if (fields.capacity > 0) // Tampilkan kapasitas kalau ada
                        Chip(
                          avatar: const Icon(Icons.people, size: 16),
                          label: Text("${fields.capacity} Orang"),
                          backgroundColor: Colors.blue[50],
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Harga
                  Text(
                    fields.price != null ? "Rp ${fields.price} / jam" : "Harga: Hubungi Kami",
                    style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Alamat
                  const Text("Lokasi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(fields.address)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Deskripsi
                  const Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    fields.description, // Ini sekarang aman karena ada default "-" di model
                    style: const TextStyle(height: 1.5),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 32),

                  // Tombol Booking
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Fitur Booking akan segera hadir!")),
                        );
                      },
                      child: const Text("Book Now", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}