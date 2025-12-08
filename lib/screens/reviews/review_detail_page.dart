import 'package:flutter/material.dart';
import 'package:lapang/models/reviews.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:lapang/screens/reviews/reviews_form_page.dart';


class ReviewDetailPage extends StatelessWidget {
  final Review review;

  const ReviewDetailPage({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final primaryColor = Theme.of(context).colorScheme.primary;

    final String initial = review.userUsername.isNotEmpty
        ? review.userUsername[0].toUpperCase()
        : "?";

    final bool hasImage = review.imageUrl != null && review.imageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // HEADER IMAGE (parallax)
          SliverAppBar(
            expandedHeight: hasImage ? 450.0 : 150.0,
            pinned: true,
            backgroundColor: primaryColor,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: hasImage
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    review.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: primaryColor),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              )
                  : Container(color: primaryColor),
            ),
          ),

          // BODY CONTENT
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -50, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 45, top: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // NAMA VENUE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            review.venueName,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            review.sportType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // --- RATING BOX BESAR ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFFECB3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "RATING",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${review.rating}",
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      "/ 5.0",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: Colors.amber,
                                size: 32,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- USER INFO ---
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey[100],
                          child: Text(initial, style: TextStyle(fontSize: 22, color: primaryColor, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userUsername,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              review.createdAt,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // --- KOMENTAR ---
                    const Text(
                      "Komentar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.format_quote_rounded, color: Colors.grey, size: 30),
                          const SizedBox(height: 8),
                          Text(
                            review.comment,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: review.canModify
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TOMBOL EDIT
          FloatingActionButton.extended(
            heroTag: "btnEdit",
            onPressed: () async {
              // Navigasi ke Form dengan membawa data review
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewFormPage(review: review),
                ),
              );
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            label: const Text("Edit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.edit, color: Colors.white),
            backgroundColor: Colors.amber,
            elevation: 4,
          ),

          const SizedBox(width: 16),

          // TOMBOL HAPUS
          FloatingActionButton.extended(
            heroTag: "btnDelete",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Hapus Ulasan"),
                  content: const Text("Apakah Anda yakin ingin menghapus ulasan ini?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true) {
                final response = await request.postJson(
                  "http://localhost:8000/reviews/delete-review-ajax/${review.pk}/",
                  jsonEncode({}),
                );

                if (context.mounted) {
                  if (response['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil dihapus!")));
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${response['message']}")));
                  }
                }
              }
            },
            label: const Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            backgroundColor: Colors.redAccent,
            elevation: 4,
          ),
        ],
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}