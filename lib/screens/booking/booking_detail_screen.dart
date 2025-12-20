import 'package:flutter/material.dart';
import 'package:lapang/models/booking.dart';

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Booking")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Venue: ${booking.venueName ?? 'ID: ${booking.venueId ?? '-'}'}"),
            Text("Nama Peminjam: ${booking.borrowerName}"),
            Text("Tanggal: ${booking.bookingDate}"),
            Text("Mulai: ${booking.startTime}"),
            Text("Selesai: ${booking.endTime}"),
            Text("Total Harga: ${booking.totalPrice ?? '-'}"),
            Text("Status: ${booking.status}"),
          ],
        ),
      ),
    );
  }
}
