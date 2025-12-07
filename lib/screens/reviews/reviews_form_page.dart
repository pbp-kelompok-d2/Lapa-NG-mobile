import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'reviews_page.dart';

class ReviewFormPage extends StatefulWidget {
  const ReviewFormPage({super.key});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _venueName = "";
  String _sportType = "soccer";
  int _rating = 5;
  String _comment = "";
  String _imageUrl = "";

  final List<String> _sportTypes = [
    'soccer',
    'tennis',
    'badminton',
    'futsal',
    'basket'
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Tambah Review',
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Input Nama Venue
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Contoh: Lapangan Merdeka",
                    labelText: "Nama Lapangan/Venue",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _venueName = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Nama lapangan tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // 2. Dropdown Tipe Olahraga
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Tipe Olahraga",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  value: _sportType,
                  items: _sportTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type[0].toUpperCase() + type.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _sportType = newValue!;
                    });
                  },
                ),
              ),

              // 3. Input Rating (clickable 1-5)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Rating: $_rating Bintang",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Bintang di tengah
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40.0, // Ukuran bintang lebih besar
                          ),
                        );
                      }),
                    ),
                    if (_rating == 0)
                      const Center(
                        child: Text(
                          "Silakan beri bintang",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      )
                  ],
                ),
              ),

              // 4. Input Komentar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Ceritakan pengalamanmu...",
                    labelText: "Komentar",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (String? value) {
                    setState(() {
                      _comment = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Komentar tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // 5. Input Image URL (Opsional)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Link gambar (Opsional)",
                    labelText: "URL Gambar",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _imageUrl = value!;
                    });
                  },
                ),
              ),

              // Tombol Simpan
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Kirim data ke Django
                        final response = await request.postJson(
                          "http://127.0.0.1:8000/reviews/add-review/",
                          jsonEncode(<String, dynamic>{
                            'venue_name': _venueName,
                            'sport_type': _sportType,
                            'rating': _rating,
                            'comment': _comment,
                            'image_url': _imageUrl,
                          }),
                        );

                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Review berhasil disimpan!"),
                              ),
                            );
                            // Kembali ke halaman daftar & refresh
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const ReviewsPage()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Gagal menyimpan: ${response['message'] ?? 'Kesalahan server'}"),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text(
                      "Simpan Review",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}