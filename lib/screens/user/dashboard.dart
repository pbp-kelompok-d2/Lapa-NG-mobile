import 'dart:async';
import 'package:flutter/material.dart';

class BookingItem {
  final String id;
  final String name;
  final String venueName;
  final String date; // display-friendly
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
  // profile
  String _username = 'owner test';
  String _fullName = 'owner test';
  String _phoneRaw = '+621725361253';
  String _role = 'Owner';
  String? _profilePicture;
  int _countBookings = 3;
  int _countEquipment = 0;
  int _countReviews = 0;

  // panels & infinite scroll
  final ScrollController _bookingsController = ScrollController();
  final ScrollController _courtsController = ScrollController();
  final List<BookingItem> _bookings = [];
  final List<BookingItem> _courts = [];

  bool _bookingsLoading = false;
  bool _courtsLoading = false;
  bool _bookingsHasMore = true;
  bool _courtsHasMore = true;
  int _bookingsOffset = 0;
  int _courtsOffset = 0;
  final int _limit = 12;

  // which tab is active: 0 = bookings, 1 = my courts
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMoreBookings();
    _loadMoreCourts();

    _bookingsController.addListener(() {
      if (_bookingsController.position.pixels >=
              _bookingsController.position.maxScrollExtent - 200 &&
          !_bookingsLoading &&
          _bookingsHasMore) {
        _loadMoreBookings();
      }
    });

    _courtsController.addListener(() {
      if (_courtsController.position.pixels >=
              _courtsController.position.maxScrollExtent - 200 &&
          !_courtsLoading &&
          _courtsHasMore) {
        _loadMoreCourts();
      }
    });
  }

  @override
  void dispose() {
    _bookingsController.dispose();
    _courtsController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreBookings() async {
    if (_bookingsLoading || !_bookingsHasMore) return;
    setState(() => _bookingsLoading = true);
    await Future.delayed(const Duration(milliseconds: 650));

    // TODO: replace with fetch to actual booking API
    final newItems = List.generate(_limit, (i) {
      final index = _bookingsOffset + i + 1;
      return BookingItem(
        id: 'b_$index',
        name: 'Futsal Cipinang Melayu',
        venueName: 'Futsal Cipinang Melayu',
        date: 'Saturday, 8 November 2025',
        startTime: '05:28:00',
        endTime: '06:28:00',
        totalPrice: 65000,
        imageUrl: null,
      );
    });

    setState(() {
      _bookings.addAll(newItems);
      _bookingsOffset += newItems.length;
      if (_bookings.length >= 48) _bookingsHasMore = false;
      _bookingsLoading = false;
    });
  }

  Future<void> _loadMoreCourts() async {
    if (_courtsLoading || !_courtsHasMore) return;
    setState(() => _courtsLoading = true);
    await Future.delayed(const Duration(milliseconds: 650));

    final newItems = List.generate(_limit, (i) {
      final index = _courtsOffset + i + 1;
      return BookingItem(
        id: 'c_$index',
        name: 'Gedung Squash',
        venueName: 'Gedung Squash',
        date: 'Wednesday, 12 November 2025',
        startTime: '19:00',
        endTime: '20:30',
        totalPrice: 0,
        imageUrl: null,
      );
    });

    setState(() {
      _courts.addAll(newItems);
      _courtsOffset += newItems.length;
      if (_courts.length >= 36) _courtsHasMore = false;
      _courtsLoading = false;
    });
  }

  // phone formatting helper
  String _formatPhone(String? input) {
    if (input == null || input.isEmpty) return '';
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = '62' + digits.substring(1);
    if (!digits.startsWith('62')) {
      if (digits.length <= 12) digits = '62' + digits;
    }
    if (!digits.startsWith('62')) digits = '62' + digits;
    final rest = digits.substring(2);
    if (rest.isEmpty) return '+62';
    final a = rest.length >= 3 ? rest.substring(0, 3) : rest;
    final b = rest.length > 3 ? rest.substring(3, (rest.length >= 7 ? 7 : rest.length)) : '';
    final c = rest.length > 7 ? rest.substring(7) : '';
    var out = '+62 $a';
    if (b.isNotEmpty) out += '-$b';
    if (c.isNotEmpty) out += '-$c';
    return out;
  }

  // Edit profile modal (simulated POST)
  Future<void> _openEditProfileModal() async {
    final usernameController = TextEditingController(text: _username);
    final nameController = TextEditingController(text: _fullName);
    final numberController = TextEditingController(text: _phoneRaw);
    final pictureController = TextEditingController(text: _profilePicture ?? '');

    final res = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Edit profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                    IconButton(onPressed: () => Navigator.of(context).pop(false), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
                const SizedBox(height: 8),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full name')),
                const SizedBox(height: 8),
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    helperText: 'Enter digits only, no leading 0 or +62',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(controller: pictureController, decoration: const InputDecoration(labelText: 'Profile picture (URL)')),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // You would normally POST to edit endpoint here.
                      Navigator.of(context).pop(true);
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

      // show toast
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!'), duration: Duration(milliseconds: 1800)),
      );
    }
  }

  // Delete confirmation (simulated)
  Future<void> _openDeleteConfirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('This will permanently delete your profile and you will be logged out.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // TODO: call delete endpoint
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile deleted (simulated).'), duration: Duration(seconds: 2)),
      );
      setState(() {
        _username = '';
        _fullName = '';
        _phoneRaw = '';
        _profilePicture = null;
        _role = '';
      });
    }
  }

  // Builds one list item using layout similar to renderCard()
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
            clipBehavior: Clip.hardEdge,
            child: item.imageUrl != null
                ? Image.network(item.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _noImage())
                : _noImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (item.venueName.isNotEmpty) Text(item.venueName, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 4),
              Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(children: [
                if (item.date.isNotEmpty) ...[
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(child: Text(item.date, style: const TextStyle(color: Colors.black87))),
                ]
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.access_time, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Text('${item.startTime}${item.endTime.isNotEmpty ? ' - ${item.endTime}' : ''}', style: const TextStyle(color: Colors.black87)),
              ]),
              if (price != null) ...[
                const SizedBox(height: 8),
                Text(price, style: const TextStyle(color: Colors.black87)),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _noImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.image_not_supported_outlined, size: 28, color: Colors.black26),
          SizedBox(height: 6),
          Text('NO IMAGE\nAVAILABLE', textAlign: TextAlign.center, style: TextStyle(color: Colors.black26, fontSize: 12)),
        ]),
      ),
    );
  }

  // the panel list builder used for both bookings & courts
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
            // blank space to allow scroll to trigger loadMore
            return const SizedBox(height: 48);
          }
        },
      ),
    );
  }

  // Left profile card mirroring the screenshot
  Widget _buildLeftCard() {
    final avatar = _profilePicture;
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF9DD3FF), Color(0xFF89E0C6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Column(
        children: [
          // avatar with white border similar to web
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 44,
              backgroundImage: avatar != null && avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar == null ? Image.asset('assets/user.png', fit: BoxFit.cover) : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(_fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (_phoneRaw.isNotEmpty) Text(_formatPhone(_phoneRaw), style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(_role, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _miniStat('Bookings', _countBookings),
            _miniStat('Equipment', _countEquipment),
            _miniStat('Reviews', _countReviews),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton.icon(
              onPressed: _openEditProfileModal,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _openDeleteConfirm,
              icon: const Icon(Icons.close, size: 16, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                backgroundColor: Colors.red.withOpacity(0.06),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _miniStat(String title, int value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }

  // Tab pill widget
  Widget _tabPill(String label, int index) {
    final active = _tabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(999),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)] : null,
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: active ? const Color(0xFF065F46) : Colors.black87)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final rightCardHeight = screenH * 0.5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LapaNG'),
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.menu))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: isWide ? 320 : double.infinity, child: _buildLeftCard()),
                  const SizedBox(width: 12, height: 12),
                  Expanded(
                    child: Container(
                      height: rightCardHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF9DD3FF), Color(0xFF89E0C6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
                      ),
                      child: Column(
                        children: [
                          // header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_tabIndex == 0 ? 'Booked Courts' : 'My Courts',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF065F46))),
                                Row(children: [ _tabPill('Booked Courts', 0), const SizedBox(width: 8), _tabPill('My Courts', 1) ]),
                              ],
                            ),
                          ),
                          // content panel (absolute-like behavior)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Stack(
                                children: [
                                  // Bookings panel
                                  Offstage(
                                    offstage: _tabIndex != 0,
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
                                  // Courts panel
                                  Offstage(
                                    offstage: _tabIndex != 1,
                                    child: _buildInfiniteList(
                                      controller: _courtsController,
                                      items: _courts,
                                      isLoading: _courtsLoading,
                                      hasMore: _courtsHasMore,
                                      onRefresh: () async {
                                        setState(() {
                                          _courts.clear();
                                          _courtsOffset = 0;
                                          _courtsHasMore = true;
                                        });
                                        await _loadMoreCourts();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
