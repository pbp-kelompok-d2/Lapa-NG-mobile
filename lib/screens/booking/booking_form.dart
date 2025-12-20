import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class BookingForm extends StatefulWidget {
  final int venueId;

  const BookingForm({super.key, required this.venueId});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();

  final borrower = TextEditingController();
  final date = TextEditingController();
  final start = TextEditingController();
  final end = TextEditingController();

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = Provider.of<CookieRequest>(context, listen: false);

    final jsonBody = {
      "venue": widget.venueId,
      "borrower_name": borrower.text,
      "booking_date": date.text,
      "start_time": start.text,
      "end_time": end.text,
    };

    final response = await request.postJson(
      "http://localhost:8000/booking/api/create/",
      jsonEncode(jsonBody),
    );
    print("RESP: $response");
    if (response != null && response['success'] == true) {
      Navigator.pop(context, {
        "refresh": true,
        "user_id": request.jsonData["id"]
      });
    } else {
      final msg = response != null ? (response['error'] ?? response['message'] ?? response.toString()) : 'Unknown';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan booking: $msg")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Lapangan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: borrower,
                decoration: const InputDecoration(labelText: "Nama Peminjam"),
                validator: (v) => v!.isEmpty ? "Wajib" : null,
              ),
              TextFormField(
                controller: date,
                decoration: const InputDecoration(labelText: "Tanggal (YYYY-MM-DD)"),
                validator: (v) => v!.isEmpty ? "Wajib" : null,
              ),
              TextFormField(
                controller: start,
                decoration: const InputDecoration(labelText: "Jam Mulai (HH:MM)"),
                validator: (v) => v!.isEmpty ? "Wajib" : null,
              ),
              TextFormField(
                controller: end,
                decoration: const InputDecoration(labelText: "Jam Selesai (HH:MM)"),
                validator: (v) => v!.isEmpty ? "Wajib" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: submit,
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
