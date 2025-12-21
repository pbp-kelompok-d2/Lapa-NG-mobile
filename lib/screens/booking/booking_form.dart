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

  final borrowerCtrl = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  String _formatTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tanggal dan jam wajib diisi")),
      );
      return;
    }

    final request = Provider.of<CookieRequest>(context, listen: false);

    final jsonBody = {
      "venue": widget.venueId,
      "borrower_name": borrowerCtrl.text,
      "booking_date": _formatDate(selectedDate!),
      "start_time": _formatTime(startTime!),
      "end_time": _formatTime(endTime!),
    };

    final response = await request.postJson(
      "http://localhost:8000/booking/api/create/",
      jsonEncode(jsonBody),
    );

    if (response != null && response['success'] == true) {
      Navigator.pop(context, {
        "refresh": true,
        "user_id": request.jsonData["user_id"],
      });
    } else {
      final msg = response != null
          ? (response['error'] ??
              response['message'] ??
              response.toString())
          : 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan booking: $msg")),
      );
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
              // Nama peminjam
              TextFormField(
                controller: borrowerCtrl,
                decoration: const InputDecoration(
                  labelText: "Nama Peminjam",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Wajib diisi" : null,
              ),

              const SizedBox(height: 16),

              // Tanggal
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                title: Text(
                  selectedDate == null
                      ? "Pilih Tanggal"
                      : "Tanggal: ${_formatDate(selectedDate!)}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),

              const SizedBox(height: 12),

              // Jam mulai
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                title: Text(
                  startTime == null
                      ? "Pilih Jam Mulai"
                      : "Mulai: ${_formatTime(startTime!)}",
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: startTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => startTime = picked);
                  }
                },
              ),

              const SizedBox(height: 12),

              // Jam selesai
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                title: Text(
                  endTime == null
                      ? "Pilih Jam Selesai"
                      : "Selesai: ${_formatTime(endTime!)}",
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => endTime = picked);
                  }
                },
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
