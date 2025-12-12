import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapang/models/reviews.dart';
import 'package:lapang/screens/reviews/review_detail_page.dart';
import 'package:lapang/screens/reviews/reviews_form_page.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onReviewChanged;
  final List<String> venueList;

  const ReviewCard({
    super.key,
    required this.review,
    this.onReviewChanged,
    required this.venueList,
  });

  Future<void> _deleteReview(BuildContext context, CookieRequest request) async {
    final response = await request.post(
        'http://localhost:8000/reviews/delete-review/${review.pk}/',
        {}
    );

    if (context.mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review berhasil dihapus!"), backgroundColor: Colors.green),
        );
        onReviewChanged?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal menghapus."), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, CookieRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Review"),
          content: const Text("Apakah yakin ingin menghapus review Anda?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteReview(context, request);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final primaryColor = Theme.of(context).primaryColor;
    final String initial = review.userUsername.isNotEmpty
        ? review.userUsername[0].toUpperCase()
        : "?";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewDetailPage(
                    review: review,
                    venueList: venueList
                ),
              ),
            );
            if (result == true) {
              onReviewChanged?.call();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Text(initial, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review.userUsername, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(review.createdAt, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text("${review.rating}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (review.canModify) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReviewFormPage(
                                review: review,
                                venues: venueList,
                              ))
                          );
                          onReviewChanged?.call();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(Icons.edit_rounded, color: Colors.grey, size: 20),
                        ),
                      ),
                      InkWell(
                        onTap: () => _showDeleteConfirmation(context, request),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(review.venueName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(review.comment, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey[800])),
                if (review.imageUrl != null && review.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      review.imageUrl!,
                      height: 120, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => const SizedBox(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}