import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lapang/screens/auth/login.dart';
import 'package:lapang/widgets/left_drawer.dart';
import 'package:http/browser_client.dart';
import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class BookingItem {
  final String id;
  final String name;
  final String venueName;
  final String date;
  final String startTime;
  final String endTime;
  final int? totalPrice;
  final String? imageUrl;

  BookingItem({
    required this.id,
    required this.name,
    required this.venueName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.totalPrice,
    this.imageUrl,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final http.Client _client;
  bool _loadingUser = true;

  int? _userId;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _client = BrowserClient()..withCredentials = true;
    } else {
      _client = http.Client();
    }

    _fetchUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllBookings();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_userId != null && _allBookings.isEmpty) {
      _fetchAllBookings();
    }
  }

  String _username = '';
  String _fullName = '';
  String _phoneRaw = '';
  String _role = '';
  String? _profilePicture;

  Future<void> _fetchUser() async {
    try {
      final res = await _client.get(
        Uri.parse('http://localhost:8000/api/auth/me/'),
        headers: {'X-Requested-With': 'XMLHttpRequest'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _userId = data['id'];

        setState(() {
          _username = data['username'] ?? '';
          _fullName = data['name'] ?? '';
          _phoneRaw = data['number'] ?? '';
          _role = data['role'] ?? '';
          _profilePicture = data['profile_picture'];
          _loadingUser = false;
        });

        await _fetchAllBookings();
      } else {
        _loadingUser = false;
      }
    } catch (_) {
      _loadingUser = false;
    }
  }

  final ScrollController _bookingsController = ScrollController();

  final List<BookingItem> _allBookings = [];
  final List<BookingItem> _bookings = [];

  bool _bookingsLoading = false;
  bool _bookingsHasMore = true;

  int _bookingsOffset = 0;
  final int _limit = 12;

  @override
  void dispose() {
    _bookingsController.dispose();
    super.dispose();
  }

  Future<void> _openEditProfileModal() async {
    final usernameController = TextEditingController(text: _username);
    final nameController = TextEditingController(text: _fullName);
    final numberController = TextEditingController(text: _phoneRaw);
    final pictureController = TextEditingController(
      text: _profilePicture ?? '',
    );

    final res = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Edit profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    helperText: 'Digits only, max 11 numbers',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pictureController,
                  decoration: const InputDecoration(
                    labelText: 'Profile picture (URL)',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await _submitEditProfile(
                          username: usernameController.text,
                          name: nameController.text,
                          number: numberController.text,
                          profilePicture: pictureController.text,
                        );
                        Navigator.pop(context, true);
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    child: const Text('Save changes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (res == true) {
      setState(() {
        _username = usernameController.text.trim();
        _fullName = nameController.text.trim();
        _phoneRaw = numberController.text.trim();
        final pic = pictureController.text.trim();
        _profilePicture = pic.isEmpty ? null : pic;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
    }
  }

  Future<void> _submitEditProfile({
    required String username,
    required String name,
    required String number,
    String? profilePicture,
  }) async {
    final res = await _client.post(
      Uri.parse('http://localhost:8000/api/auth/edit/'),
      headers: {'X-Requested-With': 'XMLHttpRequest'},
      body: {
        'username': username,
        'name': name,
        'number': number,
        'profile_picture': profilePicture ?? '',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Edit failed');
    }

    final data = jsonDecode(res.body);

    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Edit failed');
    }
  }

  Future<void> _deleteProfile() async {
    final res = await _client.post(
      Uri.parse('http://localhost:8000/api/auth/delete/'),
      headers: {'X-Requested-With': 'XMLHttpRequest'},
    );

    if (res.statusCode != 200) {
      throw Exception('Delete failed');
    }

    final data = jsonDecode(res.body);

    if (data['success'] == true) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } else {
      throw Exception(data['error'] ?? 'Delete failed');
    }
  }

  Future<void> _openDeleteConfirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'This will permanently delete your profile and you will be logged out.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _deleteProfile();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _fetchAllBookings() async {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn || !request.jsonData.containsKey("user_id")) {
      return;
    }

    final userId = request.jsonData["user_id"];
    final url = "http://localhost:8000/booking/api/list/$userId/";

    final response = await request.get(url);

    _allBookings.clear();
    for (final b in response) {
      _allBookings.add(
        BookingItem(
          id: b['id'].toString(),
          name: b['venue_name'] ?? '',
          venueName: b['venue_name'] ?? '',
          date: b['booking_date'] ?? '',
          startTime: b['start_time'] ?? '',
          endTime: b['end_time'] ?? '',
          totalPrice: b['total_price'],
          imageUrl: null,
        ),
      );
    }

    setState(() {
      _bookings.clear();
      _bookingsOffset = 0;
      _bookingsHasMore = true;
    });

    _loadMoreBookings();
  }

  Future<void> _loadMoreBookings() async {
    if (_bookingsLoading || !_bookingsHasMore) return;

    setState(() => _bookingsLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final nextItems = _allBookings.skip(_bookingsOffset).take(_limit).toList();

    setState(() {
      _bookings.addAll(nextItems);
      _bookingsOffset += nextItems.length;
      _bookingsHasMore = _bookingsOffset < _allBookings.length;
      _bookingsLoading = false;
    });
  }

  String _formatPhone(String? input) {
    if (input == null || input.isEmpty) return '';
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = '62' + digits.substring(1);
    if (!digits.startsWith('62')) digits = '62' + digits;
    final rest = digits.substring(2);
    if (rest.isEmpty) return '+62';
    final a = rest.length >= 3 ? rest.substring(0, 3) : rest;
    final b = rest.length > 3
        ? rest.substring(3, rest.length >= 7 ? 7 : rest.length)
        : '';
    final c = rest.length > 7 ? rest.substring(7) : '';
    var out = '+62 $a';
    if (b.isNotEmpty) out += '-$b';
    if (c.isNotEmpty) out += '-$c';
    return out;
  }

  Widget _buildItemCard(BookingItem item) {
    final price = item.totalPrice != null && item.totalPrice! > 0
        ? 'Rp ${item.totalPrice!.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}'
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.6)),
            ),
            child: _noImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.venueName,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(item.date),
                const SizedBox(height: 6),
                Text('${item.startTime} - ${item.endTime}'),
                if (price != null) ...[const SizedBox(height: 8), Text(price)],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 28,
          color: Colors.black26,
        ),
      ),
    );
  }

  Widget _buildInfiniteList({
    required ScrollController controller,
    required List<BookingItem> items,
    required bool isLoading,
    required bool hasMore,
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        itemCount: items.length + 1,
        itemBuilder: (context, idx) {
          if (idx < items.length) return _buildItemCard(items[idx]);
          if (isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (!hasMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No more items')),
            );
          } else {
            return const SizedBox(height: 48);
          }
        },
      ),
    );
  }

  Widget _buildLeftCard() {
    final avatar = _profilePicture;
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9DD3FF), Color(0xFF89E0C6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 44,
              backgroundColor: Colors.transparent,
              backgroundImage: (avatar != null && avatar.isNotEmpty)
                  ? NetworkImage(avatar)
                  : null,
              child: (avatar == null || avatar.isEmpty)
                  ? const Icon(
                      Icons.account_circle,
                      size: 88,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          if (_phoneRaw.isNotEmpty)
            Text(
              _formatPhone(_phoneRaw),
              style: const TextStyle(color: Colors.black54),
            ),
          const SizedBox(height: 6),
          Text(
            _role,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _openEditProfileModal,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _openDeleteConfirm,
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  backgroundColor: Colors.red.withOpacity(0.06),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightCard(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9DD3FF), Color(0xFF89E0C6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booked Courts',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: _buildInfiniteList(
                controller: _bookingsController,
                items: _bookings,
                isLoading: _bookingsLoading,
                hasMore: _bookingsHasMore,
                onRefresh: () async {
                  setState(() {
                    _bookings.clear();
                    _bookingsOffset = 0;
                    _bookingsHasMore = true;
                  });
                  await _loadMoreBookings();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screenH = MediaQuery.of(context).size.height;
    final rightCardHeight = screenH * 0.5;

    return Scaffold(
      appBar: AppBar(title: const Text('LapaNG')),
      drawer: const LeftDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: isWide ? 320 : double.infinity,
                      child: _buildLeftCard(),
                    ),
                    const SizedBox(width: 12, height: 12),
                    isWide
                        ? Expanded(child: _buildRightCard(rightCardHeight))
                        : _buildRightCard(rightCardHeight),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
