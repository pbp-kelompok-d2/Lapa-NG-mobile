import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapang/models/reviews.dart';

class ReviewFormPage extends StatefulWidget {
  final Review? review;
  const ReviewFormPage({super.key, this.review});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _venueController = TextEditingController();

  String? _selectedVenue;
  String _sportType = "soccer";
  int _rating = 0;
  String _comment = "";
  String _imageUrl = "";

  List<String> _venueList = [];
  bool _isLoadingVenues = true;

  final List<String> _sportTypes = [
    'soccer', 'tennis', 'badminton', 'futsal', 'basket'
  ];

  @override
  void initState() {
    super.initState();

    // Fetch data dataset lapangan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchVenueNames();
    });

    if (widget.review != null) {
      _selectedVenue = widget.review!.venueName;
      _venueController.text = widget.review!.venueName;
      _sportType = widget.review!.sportType.toLowerCase();
      _rating = widget.review!.rating;
      _comment = widget.review!.comment;
      _imageUrl = widget.review!.imageUrl ?? "";
    }
  }

  @override
  void dispose() {
    _venueController.dispose();
    super.dispose();
  }

  Future<void> fetchVenueNames() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("http://localhost:8000/reviews/venue-list/");
      if (mounted) {
        setState(() {
          _venueList = List<String>.from(response);
          _isLoadingVenues = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingVenues = false);
    }
  }

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'soccer': return Icons.sports_soccer;
      case 'tennis': return Icons.sports_tennis;
      case 'badminton': return Icons.sports_tennis;
      case 'futsal': return Icons.sports_soccer;
      case 'basket': return Icons.sports_basketball;
      default: return Icons.sports;
    }
  }

  void _showVenuePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7, minChildSize: 0.5, maxChildSize: 0.9, expand: false,
          builder: (_, scrollController) => Column(children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const Padding(padding: EdgeInsets.only(bottom: 16.0), child: Text("Pilih Lapangan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Expanded(child: _VenueSearchList(allVenues: _venueList, onSelect: (selected) {
              setState(() { _selectedVenue = selected; _venueController.text = selected; });
              Navigator.pop(context);
            }))
          ])
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bool isEdit = widget.review != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Ulasan' : 'Tulis Ulasan', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoadingVenues
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Column(children: [
                const Text("Bagaimana pengalamanmu?", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (index) => IconButton(onPressed: () => setState(() => _rating = index + 1), iconSize: 48, icon: Icon(index < _rating ? Icons.star_rounded : Icons.star_outline_rounded, color: index < _rating ? Colors.amber : Colors.grey[300])))),
                Text(_rating > 0 ? "$_rating/5 Bintang" : "Sentuh bintang untuk menilai", style: TextStyle(color: _rating > 0 ? Colors.amber[800] : Colors.grey[400], fontWeight: FontWeight.bold)),
              ])),

              const SizedBox(height: 30),

              const Text("Pilih Lapangan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _venueController, readOnly: true, onTap: () => _showVenuePicker(context),
                decoration: InputDecoration(hintText: "Pilih nama lapangan...", prefixIcon: Icon(Icons.stadium_rounded, color: primaryColor), suffixIcon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.grey), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                validator: (value) => value!.isEmpty ? "Pilih lapangan dulu ya" : null,
              ),
              const SizedBox(height: 24),

              const Text("Kategori Olahraga", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(spacing: 10.0, runSpacing: 10.0, children: _sportTypes.map((type) {
                final isSelected = _sportType == type;
                return ChoiceChip(label: Text(type[0].toUpperCase() + type.substring(1)), avatar: isSelected ? null : Icon(_getSportIcon(type), size: 18, color: Colors.grey[600]), selected: isSelected, selectedColor: primaryColor, labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!)), onSelected: (bool selected) { if (selected) setState(() => _sportType = type); });
              }).toList()),

              const SizedBox(height: 24),

              const Text("Ulasan Kamu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _comment,
                maxLines: 4,
                decoration: InputDecoration(hintText: "Ceritakan fasilitasnya...", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                onChanged: (value) => setState(() => _comment = value),
                validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _imageUrl, // Pre-fill image URL jika edit
                decoration: InputDecoration(labelText: "Link Foto (Opsional)", prefixIcon: const Icon(Icons.link_rounded), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                onChanged: (value) => setState(() => _imageUrl = value),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (_rating == 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kasih bintang dulu dong! ⭐")));
                return;
              }

              // SAVE: Cek URL (Create / Edit)
              String url;
              if (isEdit) {
                url = "http://localhost:8000/reviews/edit-flutter/${widget.review!.pk}/";
              } else {
                url = "http://localhost:8000/reviews/create-flutter/";
              }

              final response = await request.postJson(
                url,
                jsonEncode(<String, dynamic>{
                  'venue_name': _venueController.text,
                  'sport_type': _sportType,
                  'rating': _rating.toString(),
                  'comment': _comment,
                  'image_url': _imageUrl,
                }),
              );

              if (context.mounted) {
                if (response['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil disimpan!"), backgroundColor: Colors.green));
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${response['message']}"), backgroundColor: Colors.red));
                }
              }
            }
          },
          child: Text(isEdit ? "Simpan Perubahan" : "Kirim Ulasan", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _VenueSearchList extends StatefulWidget {
  final List<String> allVenues;
  final Function(String) onSelect;
  const _VenueSearchList({required this.allVenues, required this.onSelect});
  @override
  State<_VenueSearchList> createState() => _VenueSearchListState();
}
class _VenueSearchListState extends State<_VenueSearchList> {
  String _query = "";
  @override
  Widget build(BuildContext context) {
    final filtered = widget.allVenues.where((venue) => venue.toLowerCase().contains(_query.toLowerCase())).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: TextField(autofocus: false, decoration: InputDecoration(hintText: "Cari nama lapangan...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16)), onChanged: (val) => setState(() => _query = val))),
      const SizedBox(height: 10),
      Expanded(child: filtered.isEmpty ? const Center(child: Text("Lapangan tidak ditemukan 😢", style: TextStyle(color: Colors.grey))) : ListView.separated(itemCount: filtered.length, separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 16, endIndent: 16), itemBuilder: (context, index) => ListTile(title: Text(filtered[index], style: const TextStyle(fontSize: 16)), leading: const Icon(Icons.stadium_outlined, color: Colors.grey), onTap: () => widget.onSelect(filtered[index])))),
    ]);
  }
}