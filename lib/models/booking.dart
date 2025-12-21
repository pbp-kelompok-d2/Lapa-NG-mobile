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

  Booking copyWith({
    String? borrowerName,
    String? bookingDate,
    String? startTime,
    String? endTime,
    int? totalPrice,
    String? status,
  }) {
    return Booking(
      id: id,
      venueId: venueId,
      venueName: venueName,
      borrowerName: borrowerName ?? this.borrowerName,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json["id"],
      venueId: json["venue_id"],
      venueName: json["venue_name"],
      borrowerName: json["borrower_name"],
      bookingDate: json["booking_date"],
      startTime: json["start_time"],
      endTime: json["end_time"],
      totalPrice: json["total_price"],
      status: json["status"],
    );
  }
}
