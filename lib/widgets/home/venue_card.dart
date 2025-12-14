import 'package:flutter/material.dart';
import 'package:lapang/models/venue.dart';
import 'package:lapang/screens/home/venue_detail_page.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;

  const VenueCard({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final fields = venue.fields;

    // === PERBAIKAN 1: URL UNTUK EMULATOR ===
    // Gunakan 10.0.2.2 untuk Android Emulator.
    // Jika fields.imageUrl sudah berisi http://127.0.0.1..., kita encode dan kirim ke proxy.
    // Pastikan base URL proxy juga menggunakan 10.0.2.2.
    final imageUrl ='http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(fields.imageUrl)}';

    return Card(
      // Margin di-set zero biar GridView yang atur jarak
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VenueDetailPage(venue: venue),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === PERBAIKAN 2: LAYOUT RESPONSIF (AspectRatio) ===
            // Mengganti Container height: 180 agar gambar menyesuaikan lebar kartu
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      // === PERBAIKAN 3: OPTIMASI MEMORI ===
                      cacheWidth: 600,
                      errorBuilder: (ctx, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fields.category.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // === INFO ===
            // Menggunakan Flexible agar teks tidak overflow
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fields.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          fields.address,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          fields.price != null ? "Rp ${fields.price}" : "Hubungi Kami",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        "/ jam",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
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