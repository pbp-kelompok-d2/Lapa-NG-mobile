class Booking {
  final int? id;
  final int? venueId;
  final String? venueName;
  final String borrowerName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final int? totalPrice;
  final String status;

  Booking({
    this.id,
    this.venueId,
    this.venueName,
    required this.borrowerName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.totalPrice,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json["id"] != null ? (json["id"] as num).toInt() : null,
      venueId: json["venue_id"] != null ? (json["venue_id"] as num).toInt() : null,
      venueName: json["venue_name"] != null ? json["venue_name"].toString() : null,
      borrowerName: json["borrower_name"] ?? '',
      bookingDate: json["booking_date"] ?? '',
      startTime: json["start_time"] ?? '',
      endTime: json["end_time"] ?? '',
      totalPrice: json["total_price"] != null ? (json["total_price"] as num).toInt() : null,
      status: json["status"] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (venueId != null) "venue_id": venueId,
      if (venueName != null) "venue_name": venueName,
      "borrower_name": borrowerName,
      "booking_date": bookingDate,
      "start_time": startTime,
      "end_time": endTime,
      if (totalPrice != null) "total_price": totalPrice,
      "status": status,
    };
  }
}
