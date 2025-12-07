import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CreateFeedPage extends StatefulWidget {
  const CreateFeedPage({super.key});

  @override
  State<CreateFeedPage> createState() => _CreateFeedPageState();
}

class _CreateFeedPageState extends State<CreateFeedPage> {
  final _formKey = GlobalKey<FormState>();
  String _content = "";
  String _category = "soccer";
  String _thumbnail = "";
  bool _isFeatured = false;

  static const String baseUrl = "http://localhost:8000";

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buat Feed Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ISI FEED
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Isi Feed',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
                onSaved: (value) => _content = value ?? "",
              ),
              const SizedBox(height: 12),

              // KATEGORI
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(),
                ),
                value: _category,
                items: const [
                  DropdownMenuItem(value: "soccer", child: Text("Soccer")),
                  DropdownMenuItem(value: "futsal", child: Text("Futsal")),
                  DropdownMenuItem(value: "basket", child: Text("Basket")),
                  DropdownMenuItem(
                    value: "badminton",
                    child: Text("Badminton"),
                  ),
                  DropdownMenuItem(value: "other", child: Text("Other")),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value ?? "other";
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Thumbnail URL',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _thumbnail = value ?? "",
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Featured"),
                value: _isFeatured,
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final response = await request
                        .post("$baseUrl/feeds/create-ajax/", {
                          "content": _content,
                          "category": _category,
                          "thumbnail": _thumbnail,
                          "is_featured": _isFeatured ? "on" : "",
                        });

                    if (response['ok'] == true) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feed berhasil dibuat!')),
                      );
                      Navigator.pop(context, true); // balik ke list
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Gagal membuat feed: ${response['detail'] ?? 'Unknown error'}',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Kirim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
