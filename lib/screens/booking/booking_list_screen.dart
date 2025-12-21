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
  List<Booking> allBookings = [];
  List<Booking> bookings = [];
  bool loading = true;

  final TextEditingController venueFilterCtrl = TextEditingController();
  final TextEditingController borrowerFilterCtrl = TextEditingController();
  String selectedStatus = "all";

  /* ================= FETCH ================= */

  Future<void> fetchBookings() async {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn || !request.jsonData.containsKey("user_id")) {
      setState(() => loading = false);
      return;
    }

    final userId = request.jsonData["user_id"];
    final url = "https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/booking/api/list/$userId/";

    final response = await request.get(url);

    setState(() {
      allBookings =
          (response as List).map((e) => Booking.fromJson(e)).toList();

      bookings =
          allBookings.where((b) => b.status != "done").toList();

      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  /* ================= FILTER ================= */

  void applyFilter() {
    final venueKey = venueFilterCtrl.text.toLowerCase();
    final borrowerKey = borrowerFilterCtrl.text.toLowerCase();

    setState(() {
      bookings = allBookings.where((b) {
        if (b.status == "done") return false;

        final matchVenue = venueKey.isEmpty ||
            (b.venueName ?? "")
                .toLowerCase()
                .contains(venueKey);

        final matchBorrower = borrowerKey.isEmpty ||
            b.borrowerName.toLowerCase().contains(borrowerKey);

        final matchStatus =
            selectedStatus == "all" || b.status == selectedStatus;

        return matchVenue && matchBorrower && matchStatus;
      }).toList();
    });
  }

  /* ================= EDIT ================= */

  Future<void> showEditDialog(BuildContext context, Booking booking) async {
    final borrowerCtrl =
        TextEditingController(text: booking.borrowerName);

    DateTime selectedDate = DateTime.parse(booking.bookingDate);
    TimeOfDay startTime = _parseTime(booking.startTime);
    TimeOfDay endTime = _parseTime(booking.endTime);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Edit Booking"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: borrowerCtrl,
                      decoration: const InputDecoration(
                        labelText: "Nama Peminjam",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ListTile(
                      title: Text(
                        "Tanggal: ${selectedDate.toString().split(" ")[0]}",
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                    ),

                    ListTile(
                      title: Text("Mulai: ${startTime.format(context)}"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (picked != null) {
                          setModalState(() => startTime = picked);
                        }
                      },
                    ),

                    ListTile(
                      title: Text("Selesai: ${endTime.format(context)}"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (picked != null) {
                          setModalState(() => endTime = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await updateBooking(
                      booking: booking,
                      borrowerName: borrowerCtrl.text,
                      date: selectedDate,
                      start: startTime,
                      end: endTime,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /* ================= UPDATE BOOKING ================= */

  Future<void> updateBooking({
    required Booking booking,
    required String borrowerName,
    required DateTime date,
    required TimeOfDay start,
    required TimeOfDay end,
  }) async {
    final request = context.read<CookieRequest>();
    final url =
        "https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/booking/api/update/${booking.id}/";

    final response = await request.post(url, {
      "borrower_name": borrowerName,
      "booking_date": date.toIso8601String().substring(0, 10),
      "start_time": _formatTime(start),
      "end_time": _formatTime(end),
    });

    if (response == null || response["success"] != true) {
      throw Exception("Gagal update booking");
    }

    setState(() {
      final index = allBookings.indexWhere((b) => b.id == booking.id);
      allBookings[index] = booking.copyWith(
        borrowerName: borrowerName,
        bookingDate: response["data"]["booking_date"],
        startTime: response["data"]["start_time"],
        endTime: response["data"]["end_time"],
        totalPrice: response["data"]["total_price"],
      );
      applyFilter();
    });
  }

  /* ================= DELETE ================= */

  Future<void> deleteBooking(int bookingId) async {
    final request = context.read<CookieRequest>();
    final url = "https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/booking/api/delete/$bookingId/";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Booking?"),
        content: const Text("Yakin ingin menghapus booking ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await request.post(url, {});
    if (response["success"] == true) fetchBookings();
  }

  Future<void> deleteBookingSilently(int bookingId) async {
    final request = context.read<CookieRequest>();
    final url = "https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/booking/api/delete/$bookingId/";

    final response = await request.post(url, {});
    if (response != null && response["success"] == true) {
      setState(() {
        allBookings.removeWhere((b) => b.id == bookingId);
        applyFilter();
      });
    }
  }

  /* ================= STATUS ================= */

  Future<void> changeStatus(int index, String newStatus) async {
    final booking = bookings[index];
    final request = context.read<CookieRequest>();

    if (newStatus == "done") {
      await deleteBookingSilently(booking.id!);
      return;
    }

    final url =
        "https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/booking/api/update-status/${booking.id}/";

    final response = await request.post(url, {"status": newStatus});

    if (response != null && response["success"] == true) {
      setState(() {
        final idx =
            allBookings.indexWhere((b) => b.id == booking.id);
        allBookings[idx] =
            allBookings[idx].copyWith(status: newStatus);
        applyFilter();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal update status")),
      );
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Booking Saya")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: bookings.isEmpty
                      ? const Center(child: Text("Tidak ada booking"))
                      : ListView.builder(
                          itemCount: bookings.length,
                          itemBuilder: (_, i) {
                            return BookingCard(
                              booking: bookings[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingDetailScreen(
                                    booking: bookings[i],
                                  ),
                                ),
                              ),
                              onEdit: bookings[i].status == "pending"
                                  ? () =>
                                      showEditDialog(context, bookings[i])
                                  : null,
                              onDelete: bookings[i].status == "pending"
                                  ? () => deleteBooking(bookings[i].id!)
                                  : null,
                              onStatusChanged: (status) =>
                                  changeStatus(i, status!),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  /* ================= FILTER UI ================= */

  Widget _buildFilterBar() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: venueFilterCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nama Venue",
                      hintText: "Cari nama venue...",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => applyFilter(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("Semua")),
                      DropdownMenuItem(
                          value: "pending", child: Text("Pending")),
                      DropdownMenuItem(
                          value: "confirmed", child: Text("Confirmed")),
                    ],
                    onChanged: (value) {
                      selectedStatus = value!;
                      applyFilter();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: borrowerFilterCtrl,
              decoration: const InputDecoration(
                labelText: "Nama Peminjam",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => applyFilter(),
            ),
            TextButton(
              onPressed: () {
                venueFilterCtrl.clear();
                borrowerFilterCtrl.clear();
                selectedStatus = "all";
                applyFilter();
              },
              child: const Text("Hapus semua filter"),
            )
          ],
        ),
      ),
    );
  }
}

/* ================= HELPERS ================= */

TimeOfDay _parseTime(String time) {
  final parts = time.split(":");
  return TimeOfDay(
    hour: int.parse(parts[0]),
    minute: int.parse(parts[1]),
  );
}

String _formatTime(TimeOfDay time) {
  return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
}
