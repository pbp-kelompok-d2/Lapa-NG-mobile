import 'package:flutter/material.dart';
import 'package:lapang/models/venue.dart';
import 'package:lapang/screens/home/venue_detail_page.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;

  const VenueCard({super.key, required this.venue});

  // Helper untuk fix URL gambar di Android Emulator
  // String _fixImageUrl(String url) {
  //   if (url.contains('localhost')) return url.replaceAll('localhost', '10.0.2.2');
  //   if (url.contains('127.0.0.1')) return url.replaceAll('127.0.0.1', '10.0.2.2');
  //   return url;
  // }



  @override
  Widget build(BuildContext context) {
    final fields = venue.fields;
    final imageUrl ='http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(fields.imageUrl)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            // === GAMBAR ===
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                  )
                      : const Center(child: Icon(Icons.sports_soccer, size: 50, color: Colors.grey)),
                ),
                Positioned(
                  top: 10,
                  right: 10,
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

            // === INFO ===
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fields.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fields.price != null ? "Rp ${fields.price}" : "Hubungi Kami",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        "/ jam",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
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