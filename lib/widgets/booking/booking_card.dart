import 'package:flutter/material.dart';
import 'package:lapang/models/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<String?>? onStatusChanged;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatusChanged,
  });

  Color _statusColor() {
    switch (booking.status) {
      case "confirmed":
        return Colors.green.shade50;
      case "done":
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _statusColor(),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== VENUE =====
              Text(
                booking.venueName ?? "Venue ID: ${booking.venueId}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(booking.borrowerName),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 18),
                  const SizedBox(width: 6),
                  Text(booking.bookingDate),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(Icons.access_time, size: 18),
                  const SizedBox(width: 6),
                  Text("${booking.startTime} - ${booking.endTime}"),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(Icons.payments, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "Rp ${booking.totalPrice ?? 0}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ===== STATUS + ACTION =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: booking.status,
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(
                        value: "pending",
                        child: Text("PENDING"),
                      ),
                      DropdownMenuItem(
                        value: "confirmed",
                        child: Text("CONFIRMED"),
                      ),
                      DropdownMenuItem(
                        value: "done",
                        child: Text("DONE"),
                      ),
                    ],
                    onChanged: onStatusChanged,
                  ),

                  Row(
                    children: [
                      IconButton(
                        onPressed:
                            booking.status == "pending" ? onEdit : null,
                        icon: const Icon(Icons.edit),
                        color: booking.status == "pending"
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
