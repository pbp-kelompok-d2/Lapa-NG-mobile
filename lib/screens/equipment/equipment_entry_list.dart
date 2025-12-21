import 'package:flutter/material.dart';
import 'package:lapang/models/equipments_entry.dart';
import 'package:lapang/widgets/left_drawer.dart';
import 'package:lapang/widgets/equipment/equipment_entry_card.dart';
import 'package:lapang/screens/equipment/add_equipment.dart';
import 'package:lapang/screens/equipment/edit_equipmentpage.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EquipmentEntryListPage extends StatefulWidget {
  const EquipmentEntryListPage({super.key});

  @override
  State<EquipmentEntryListPage> createState() => _EquipmentEntryListPageState();
}

class _EquipmentEntryListPageState extends State<EquipmentEntryListPage> {
  String? selectedSport;
  String? selectedRegion;
  String searchQuery = '';

  final Map<String, String> sportCategories = {
    'soccer': 'Soccer',
    'tennis': 'Tennis',
    'badminton': 'Badminton',
    'futsal': 'Futsal',
    'basketball': 'Basketball',
    'multi_sport': 'Multi-sport',
  };

  final Map<String, String> regions = {
    'jakarta_pusat': 'Jakarta Pusat',
    'jakarta_selatan': 'Jakarta Selatan',
    'jakarta_barat': 'Jakarta Barat',
    'jakarta_timur': 'Jakarta Timur',
    'jakarta_utara': 'Jakarta Utara',
  };

  Future<List<EquipmentEntry>> fetchEquipment(CookieRequest request) async {
    final response = await request.get('https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/equipment/json/');
    var data = response;

    List<EquipmentEntry> listEquipment = [];
    for (var d in data) {
      if (d != null) {
        listEquipment.add(EquipmentEntry.fromJson(d));
      }
    }

    listEquipment = listEquipment.where((e) {
      final matchSport = selectedSport == null || e.sportCategory == selectedSport;
      final matchRegion = selectedRegion == null || e.region == selectedRegion;
      final matchSearch = searchQuery.isEmpty ||
          e.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchSport && matchRegion && matchSearch;
    }).toList();

    return listEquipment;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final currentUsername = request.jsonData['username'] ?? '';
    final isOwner = request.jsonData['role'] == 'owner';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text(
          'Rent Equipment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1B5E20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      floatingActionButton: isOwner ? _buildFab(context) : null,
      body: Column(
        children: [
          // --- Header Section ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search equipment...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2E7D32), size: 22),
                        prefixIconConstraints: const BoxConstraints(minWidth: 40),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Filter Buttons Row
                Row(
                  children: [
                    _buildModernFilter(
                      label: 'Sport',
                      icon: Icons.sports_soccer,
                      value: selectedSport,
                      items: sportCategories,
                      onChanged: (v) => setState(() => selectedSport = v),
                    ),
                    const SizedBox(width: 12),
                    _buildModernFilter(
                      label: 'Region',
                      icon: Icons.location_on_outlined,
                      value: selectedRegion,
                      items: regions,
                      onChanged: (v) => setState(() => selectedRegion = v),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Equipment List ---
          Expanded(
            child: FutureBuilder<List<EquipmentEntry>>(
              future: fetchEquipment(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      final item = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: EquipmentEntryCard(
                          equipment: item,
                          currentUsername: currentUsername,
                          onEdit: isOwner ? () => _handleEdit(context, item) : null,
                          onDelete: isOwner ? () => _handleDelete(request, context, item) : null,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: const Color(0xFF1B5E20),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EquipmentFormPage()))
              .then((_) => setState(() {}));
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No equipment found", style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _handleEdit(BuildContext context, EquipmentEntry item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditEquipmentPage(equipment: item)),
    ).then((value) {
      if (value == true) setState(() {});
    });
  }

  Future<void> _handleDelete(CookieRequest request, BuildContext context, EquipmentEntry item) async {
    final response = await request.post('http://localhost:8000/equipment/delete-equipment/${item.id}/', {});
    if (response['status'] == 'success') {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipment deleted successfully')));
    }
  }

  Widget _buildModernFilter({
    required String label,
    required IconData icon,
    required String? value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
            dropdownColor: const Color(0xFF2E7D32),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            hint: Row(
              children: [
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
            items: [
              DropdownMenuItem<String>(value: null, child: Text("All $label")),
              ...items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}