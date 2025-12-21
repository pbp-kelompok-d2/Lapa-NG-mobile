import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapang/models/equipments_entry.dart';

class EditEquipmentPage extends StatefulWidget {
  final EquipmentEntry equipment;

  const EditEquipmentPage({super.key, required this.equipment});

  @override
  State<EditEquipmentPage> createState() => _EditEquipmentPageState();
}

class _EditEquipmentPageState extends State<EditEquipmentPage> {
  final _formKey = GlobalKey<FormState>();
  static const primaryGreen = Color(0xFF2E7D32);

  late String name;
  late String pricePerHour;
  late String sportCategory;
  late String region;
  late int quantity;
  late bool available;
  late String? thumbnail;

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

  @override
  void initState() {
    super.initState();
    final e = widget.equipment;
    name = e.name;
    pricePerHour = e.pricePerHour;
    sportCategory = e.sportCategory;
    region = e.region;
    quantity = e.quantity;
    available = e.available;
    thumbnail = e.thumbnail;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Equipment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 50,
              decoration: const BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Equipment Name',
                            initialValue: name,
                            icon: Icons.inventory_2_outlined,
                            onSaved: (v) => name = v!,
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),

                          _buildTextField(
                            label: 'Price per Hour (Rp)',
                            initialValue: pricePerHour.toString(),
                            icon: Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                            onSaved: (v) => pricePerHour = v!.trim(),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (int.tryParse(v.trim()) == null) return 'Invalid number';
                              return null;
                            },
                          ),

                          _buildSportDropdown(),
                          _buildRegionDropdown(),

                          _buildTextField(
                            label: 'Quantity',
                            initialValue: quantity.toString(),
                            icon: Icons.layers_outlined,
                            keyboardType: TextInputType.number,
                            onSaved: (v) => quantity = int.parse(v!),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (int.tryParse(v) == null) return 'Invalid number';
                              return null;
                            },
                          ),

                          _buildTextField(
                            label: 'Thumbnail URL (Optional)',
                            initialValue: thumbnail,
                            icon: Icons.image_outlined,
                            onSaved: (v) => thumbnail = v,
                            validator: null,
                          ),

                          const SizedBox(height: 10),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: SwitchListTile(
                              title: const Text(
                                'Status Availability',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              subtitle: Text(available ? 'Available for rent' : 'Not available'),
                              value: available,
                              activeColor: primaryGreen,
                              onChanged: (v) => setState(() => available = v),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // --- BUTTON SECTION ---
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate()) return;
                                    _formKey.currentState!.save();

                                    final response = await request.postJson(
                                      'http://localhost:8000/equipment/edit-equipment/${widget.equipment.id}/',
                                      jsonEncode({
                                        'name': name,
                                        'price_per_hour': pricePerHour,
                                        'sport_category': sportCategory,
                                        'region': region,
                                        'quantity': quantity,
                                        'available': available,
                                        'thumbnail': thumbnail,
                                      }),
                                    );

                                    if (!mounted) return;
                                    print("RAW RESPONSE: $response");
                                    if (response['status'] == 'success') {
                                      Navigator.pop(context, true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Changes saved successfully!'),
                                          backgroundColor: primaryGreen,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(response['message'] ?? 'Update failed'),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Save Changes',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // TOMBOL CANCEL
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.grey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryGreen),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryGreen, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSportDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: sportCategory,
        items: sportCategories.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) => setState(() => sportCategory = v!),
        decoration: InputDecoration(
          labelText: 'Sport Category',
          prefixIcon: const Icon(Icons.sports, color: primaryGreen),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: region,
        items: regions.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) => setState(() => region = v!),
        decoration: InputDecoration(
          labelText: 'Region / Location',
          prefixIcon: const Icon(Icons.location_on_outlined, color: primaryGreen),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}