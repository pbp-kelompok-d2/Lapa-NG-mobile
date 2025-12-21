import 'package:flutter/material.dart';
import 'package:lapang/models/venue.dart';
import 'package:lapang/screens/home/venue_detail_page.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;

  const VenueCard({super.key, required this.venue});

  String _formatCurrency(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final fields = venue.fields;
    // Menggunakan 127.0.0.1 untuk Localhost view
    final imageUrl = 'https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(fields.imageUrl)}';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        child: Stack(
          children: [
            // === 1. GAMBAR BACKGROUND (Full Fill) ===
            // Tidak ada AspectRatio. Gambar dipaksa memenuhi kotak Grid.
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // KUNCI: Gambar akan otomatis ter-crop rapi sesuai ukuran kartu
                cacheWidth: 600,
                errorBuilder: (ctx, error, stackTrace) =>
                    Container(color: Colors.grey[800], child: const Center(child: Icon(Icons.broken_image, color: Colors.white54))),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(color: Colors.grey[200]);
                },
              ),
            ),

            // === 2. GRADIENT SCRIM (Agar Teks Terbaca) ===
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.5, 0.8, 1.0],
                  ),
                ),
              ),
            ),

            // === 3. FEATURED BADGE ===
            if (fields.isFeatured)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.yellow[700],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        "Featured",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

            // === 4. TEXT CONTENT (Bottom) ===
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nama Venue
                    Text(
                      fields.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 2)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Alamat
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            fields.address,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Harga & Kapasitas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          fields.price != null ? "Rp ${_formatCurrency(fields.price!)}" : "Free",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                        if (fields.capacity > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  "${fields.capacity}",
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}