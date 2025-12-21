import 'package:flutter/material.dart';
import 'package:lapang/models/feeds.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapang/screens/feeds/feeds_detail_page.dart';

class FeedCard extends StatelessWidget {
  final Feed feed;
  final bool isMine;
  final VoidCallback? onChanged;

  static const String baseUrl = "https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id";

  const FeedCard({
    super.key,
    required this.feed,
    this.isMine = false,
    this.onChanged,
  });

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

  Future<void> _showEditDialog(
    BuildContext context,
    CookieRequest request,
  ) async {
    // nilai awal = data yang sudah ada
    final contentController = TextEditingController(text: feed.content);
    final thumbnailController = TextEditingController(text: feed.thumbnail);

    String selectedCategory = feed.category.isNotEmpty
        ? feed.category
        : "soccer";
    bool isFeatured = feed.isFeatured;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: const Text('Edit Feed'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CONTENT
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // CATEGORY
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "soccer",
                          child: Text("Soccer"),
                        ),
                        DropdownMenuItem(
                          value: "futsal",
                          child: Text("Futsal"),
                        ),
                        DropdownMenuItem(
                          value: "basket",
                          child: Text("Basket"),
                        ),
                        DropdownMenuItem(
                          value: "badminton",
                          child: Text("Badminton"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setStateDialog(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // THUMBNAIL URL
                    TextField(
                      controller: thumbnailController,
                      decoration: const InputDecoration(
                        labelText: 'Thumbnail URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // FEATURED SWITCH
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Featured'),
                      value: isFeatured,
                      onChanged: (value) {
                        setStateDialog(() {
                          isFeatured = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.end,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    // kirim nilai baru ke Django
    final response = await request
        .post("$baseUrl/feeds/api/post/${feed.id}/edit", {
          "content": contentController.text,
          "category": selectedCategory,
          "thumbnail": thumbnailController.text,
          "is_featured": isFeatured ? "on" : "",
        });

    if (response['ok'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Feed berhasil diupdate')));
      onChanged?.call();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengupdate feed')));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CookieRequest request,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final response = await request.post(
      "$baseUrl/feeds/api/post/${feed.id}/delete",
      {},
    );

    if (response['ok'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Feed berhasil dihapus')));
      onChanged?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus feed: ${response['detail'] ?? ''}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final dateText = formatDate(feed.createdAt);

    final borderRadius = BorderRadius.circular(18);
    final bool hasThumbnail = feed.thumbnail.trim().isNotEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        clipBehavior: Clip.antiAlias, // biar gambar ikut rounded
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () async {
            final changed = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedDetailPage(feed: feed),
              ),
            );

            if (changed == true) {
              onChanged?.call();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====== HEADER USERNAME + MENU ======
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "@${feed.userUsername ?? 'anonymous'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (isMine)
                      PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await _showEditDialog(context, request);
                          } else if (value == 'delete') {
                            await _confirmDelete(context, request);
                          }
                        },
                        itemBuilder: (ctx) => const [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        icon: const Icon(Icons.more_horiz),
                      ),
                  ],
                ),
              ),

              // ====== GAMBAR ======
              if (hasThumbnail)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    'https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(feed.thumbnail)}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),

              // ====== INFO BAR ======
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

              // ====== ISI FEED ======
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Text(feed.content, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
