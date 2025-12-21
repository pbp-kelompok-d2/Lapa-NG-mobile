import 'package:flutter/material.dart';
import 'package:lapang/models/booking.dart';

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailScreen({
    super.key,
    required this.booking,
  });

  Color _statusColor(String status) {
    switch (status) {
      case "confirmed":
        return Colors.green;
      case "pending":
        return Colors.grey;
      case "done":
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Booking"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== VENUE =====
            Text(
              booking.venueName ?? "Venue ID: ${booking.venueId ?? '-'}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // ===== STATUS =====
            Chip(
              label: Text(
                booking.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: _statusColor(booking.status),
            ),

            const SizedBox(height: 20),

            // ===== DETAIL CARD =====
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(
                      Icons.person,
                      "Nama Peminjam",
                      booking.borrowerName,
                    ),
                    _divider(),
                    _infoRow(
                      Icons.calendar_month,
                      "Tanggal",
                      booking.bookingDate,
                    ),
                    _divider(),
                    _infoRow(
                      Icons.access_time,
                      "Jam",
                      "${booking.startTime} - ${booking.endTime}",
                    ),
                    _divider(),
                    _infoRow(
                      Icons.payments,
                      "Total Harga",
                      "Rp ${booking.totalPrice ?? 0}",
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== WIDGET HELPERS =====

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ??
                    const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1),
    );
  }
}
