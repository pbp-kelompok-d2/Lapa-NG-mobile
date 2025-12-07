import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapang/widgets/left_drawer.dart';

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
    'soccer', 'tennis', 'badminton', 'futsal', 'basket'
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Review'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Input Nama Venue
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Contoh: Lapangan Merdeka",
                  labelText: "Nama Lapangan",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                onChanged: (value) => setState(() => _venueName = value),
                validator: (value) => value!.isEmpty ? "Nama lapangan tidak boleh kosong!" : null,
              ),
              const SizedBox(height: 16),

              // 2. Dropdown Tipe Olahraga
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Tipe Olahraga",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                value: _sportType,
                items: _sportTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type[0].toUpperCase() + type.substring(1)),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _sportType = newValue!),
              ),
              const SizedBox(height: 16),

              // 3. Input Rating
              Text("Rating: $_rating Bintang", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => _rating = index + 1),
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40.0,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // 4. Input Komentar
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Ceritakan pengalamanmu...",
                  labelText: "Komentar",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                maxLines: 3,
                onChanged: (value) => setState(() => _comment = value),
                validator: (value) => value!.isEmpty ? "Komentar tidak boleh kosong!" : null,
              ),
              const SizedBox(height: 16),

              // 5. Input Image URL
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Link gambar (Opsional)",
                  labelText: "URL Gambar",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                onChanged: (value) => setState(() => _imageUrl = value),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Ganti URL sesuai endpoint kamu (Localhost untuk Chrome, 10.0.2.2 untuk Emulator)
                      // Karena kamu pakai Chrome, gunakan localhost atau 127.0.0.1
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
                            const SnackBar(content: Text("Review berhasil disimpan!")),
                          );
                          // PENTING: Kembali dan kirim sinyal 'true' agar halaman list refresh
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Gagal: ${response['message']}")),
                          );
                        }
                      }
                    }
                  },
                  child: const Text("Simpan Review", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}