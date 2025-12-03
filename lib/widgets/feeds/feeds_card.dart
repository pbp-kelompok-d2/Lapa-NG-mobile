import 'package:flutter/material.dart';
import 'package:lapang/models/feeds.dart';

class FeedCard extends StatelessWidget {
  final Feed feed;

  const FeedCard({super.key, required this.feed});

  String formatDate(DateTime? dt) {
    if (dt == null) return "";

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    String month = months[dt.month - 1];

    int hour = dt.hour;
    int minute = dt.minute;
    // Tentukan AM / PM
    String ampm = hour >= 12 ? "PM" : "AM";
    // Ubah ke format 12 jam
    int hour12 = hour % 12 == 0 ? 12 : hour % 12;
    // Format menit supaya selalu 2 digit
    String min = minute.toString().padLeft(2, '0');

    return "$month ${dt.day}, ${dt.year} $hour12:$min $ampm";
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final dateText = formatDate(feed.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias, // biar gambar ikut rounded
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "@${feed.userUsername ?? 'anonymous'}",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),

          // Gambar (thumbnail)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: feed.thumbnail.isNotEmpty
                ? Image.network(
                    feed.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 48, color: Colors.grey[600]),
                  ),
          ),

          // Baris info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  _capitalize(feed.category),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text("|"),
                if (feed.isFeatured) ...[
                  const Text(
                    "Featured",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text("|"),
                ],
                if (dateText.isNotEmpty) ...[
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                  const Text("|"),
                ],
                Text(
                  "Views: ${feed.postViews}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          // Konten / isi feed
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(feed.content, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
