class CustomUser {
  final int? userId;
  final String? username;
  final String? email;
  final String name;
  final String role; 
  final String number;
  final String? profilePicture;

  CustomUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.name,
    required this.role,
    required this.number,
    this.profilePicture,
  });

  factory CustomUser.fromJson(Map<String, dynamic> json) {
    return CustomUser(
      userId: json['user_id'] is int ? json['user_id'] : (json['user_id'] != null ? int.tryParse('${json['user_id']}') : null),
      username: json['username'] as String?,
      email: json['email'] as String?,
      name: (json['name'] ?? '') as String,
      role: (json['role'] ?? 'owner') as String,
      number: (json['number'] ?? '') as String,
      profilePicture: json['profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'username': username,
      'email': email,
      'name': name,
      'role': role,
      'number': number, // already normalized on server; client may send normalized as well
      'profile_picture': profilePicture,
    };
  }

  // Format number for display
  String get formattedNumber => formatIndonesiaNumber(number);

  static String normalizeIndonesiaNumber(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62')) return digits.substring(2);
    if (digits.startsWith('0')) return digits.substring(1);
    return digits;
  }

  static String formatIndonesiaNumber(String? raw) {
    final digits = normalizeIndonesiaNumber(raw);
    if (digits.isEmpty) return '';
    final n = digits.length;
    List<String> parts;
    if (n == 11) {
      parts = [digits.substring(0, 3), digits.substring(3, 7), digits.substring(7)];
    } else if (n == 10) {
      parts = [digits.substring(0, 3), digits.substring(3, 6), digits.substring(6)];
    } else if (n > 7) {
      final midLen = n - 7;
      parts = [digits.substring(0, 3), digits.substring(3, 3 + midLen), digits.substring(n - 4)];
    } else if (n > 4) {
      parts = [digits.substring(0, n - 4), digits.substring(n - 4)];
    } else {
      parts = [digits];
    }
    final joined = parts.where((p) => p.isNotEmpty).join('-');
    return '+62 $joined';
  }
}


