import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapang/models/booking.dart';
import 'package:lapang/widgets/booking/booking_card.dart';
import 'booking_detail_screen.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  List<Booking> bookings = [];
  bool loading = true;

  Future<void> fetchBookings() async {
    final request = context.read<CookieRequest>();

    print("SESSION: ${request.jsonData}");

    if (!request.loggedIn || !request.jsonData.containsKey("user_id")) {
      print("ERROR: USER NOT LOGGED IN");
      setState(() => loading = false);
      return;
    }

    final userId = request.jsonData["user_id"];
    final url = "http://localhost:8000/booking/api/list/$userId/";

    print("FETCHING: $url");

    final response = await request.get(url);

    setState(() {
      bookings = (response as List).map((e) => Booking.fromJson(e)).toList();
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Booking Saya")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (_, i) {
                return BookingCard(
                  booking: bookings[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BookingDetailScreen(booking: bookings[i]),
                    ),
                  ),
                  onDelete: () => deleteBooking(bookings[i].id!),
                  onEdit: () => showEditDialog(context, bookings[i]),
                );
              },
            ),
    );
  }

  void deleteBooking(int bookingId) async {
    final request = context.read<CookieRequest>();

    final url = "http://localhost:8000/booking/api/delete/$bookingId/";

    // Tampilkan confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Booking?"),
          content: const Text("Apakah Anda yakin ingin menghapus booking ini?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal")),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Hapus")),
          ],
        );
      },
    );

    // Jika user batal
    if (confirm != true) return;

    // Panggil API delete
    final response = await request.post(url, {});

    if (response["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking berhasil dihapus!")),
      );

      fetchBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Gagal menghapus booking, coba lagi.")),
      );
    }
  }

  void showEditDialog(BuildContext context, Booking booking) {
    final nameController = TextEditingController(text: booking.borrowerName);
    final priceController = TextEditingController(text: booking.totalPrice.toString());

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Edit Booking",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nama Peminjam",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: "Total Price",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: panggil API Django update
                print("Saving...");
                Navigator.pop(context);
              },
              child: Text("Save"),
            )
          ],
        );
      },
    );
  }
}