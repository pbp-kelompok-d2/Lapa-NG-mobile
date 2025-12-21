import 'package:flutter/material.dart';
import 'package:lapang/models/feeds.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class FeedDetailPage extends StatefulWidget {
  final Feed feed;

  static const String baseUrl = "https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id";

  const FeedDetailPage({super.key, required this.feed});

  @override
  State<FeedDetailPage> createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends State<FeedDetailPage> {
  late String _content;
  late String _category;
  late String _thumbnail;
  late bool _isFeatured;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _content = widget.feed.content;
    _category = widget.feed.category;
    _thumbnail = widget.feed.thumbnail;
    _isFeatured = widget.feed.isFeatured;
  }

  String _formatDate(DateTime? dt) {
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
    String ampm = hour >= 12 ? "PM" : "AM";
    int hour12 = hour % 12 == 0 ? 12 : hour % 12;
    String min = minute.toString().padLeft(2, '0');

    return "$month ${dt.day}, ${dt.year} $hour12:$min $ampm";
  }

  Future<void> _showEditDialog(
    BuildContext context,
    CookieRequest request,
  ) async {
    // pakai nilai yang sedang ditampilkan
    final contentController = TextEditingController(text: _content);
    final thumbnailController = TextEditingController(text: _thumbnail);

    String selectedCategory = _category.isNotEmpty ? _category : "soccer";
    bool isFeatured = _isFeatured;

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
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        DropdownMenuItem(value: "other", child: Text("Other")),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setStateDialog(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: thumbnailController,
                      decoration: const InputDecoration(
                        labelText: 'Thumbnail URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
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

    final response = await request.post(
      "${FeedDetailPage.baseUrl}/feeds/api/post/${widget.feed.id}/edit",
      {
        "content": contentController.text,
        "category": selectedCategory,
        "thumbnail": thumbnailController.text,
        "is_featured": isFeatured ? "on" : "",
      },
    );

    if (response['ok'] == true) {
      // update tampilan di halaman detail (tanpa keluar halaman)
      setState(() {
        _content = contentController.text;
        _category = selectedCategory;
        _thumbnail = thumbnailController.text;
        _isFeatured = isFeatured;
      });
      _hasChanged = true;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Feed berhasil diupdate')));
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
      "${FeedDetailPage.baseUrl}/feeds/api/post/${widget.feed.id}/delete",
      {},
    );

    if (response['ok'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Feed berhasil dihapus')));
      // delete tetap balik ke list
      Navigator.pop(context, true);
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
    final currentUsername = request.jsonData['username'] as String?;
    final isMine =
        currentUsername != null && currentUsername == widget.feed.userUsername;

    final dateText = _formatDate(widget.feed.createdAt);
    final bool hasThumbnail = widget.feed.thumbnail.trim().isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanged);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Feed Detail',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 750),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // USERNAME + TITIK TIGA
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "@${widget.feed.userUsername ?? 'anonymous'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
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

                  // GAMBAR
                  if (hasThumbnail)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        'https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(_thumbnail)}',
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

                  // INFO BAR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          _category[0].toUpperCase() +
                              _category.substring(1).toLowerCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text("|"),
                        if (_isFeatured) ...[
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
                          "Views: ${widget.feed.postViews}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // KONTEN
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Text(
                      _content,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
