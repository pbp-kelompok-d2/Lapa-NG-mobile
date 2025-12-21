import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EquipmentFormPage extends StatefulWidget {
  const EquipmentFormPage({super.key});

  @override
  State<EquipmentFormPage> createState() => _EquipmentFormPageState();
}

class _EquipmentFormPageState extends State<EquipmentFormPage> {
  final _formKey = GlobalKey<FormState>();

  static const primaryGreen = Color(0xFF2E7D32);

  String name = '';
  int pricePerHour = 0;
  String sportCategory = 'multi_sport';
  String region = 'jakarta_pusat';
  int quantity = 1;
  bool available = true;
  String? thumbnail = '';

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
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Add New Equipment',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Decorative Header Background
            Container(
              width: double.infinity,
              height: 60,
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
                  offset: const Offset(0, -40),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            label: 'Equipment Name',
                            icon: Icons.inventory_2_outlined,
                            onSaved: (v) => name = v!,
                            validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                          ),

                          _buildTextField(
                            label: 'Price per Hour (Rp)',
                            icon: Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                            onSaved: (v) => pricePerHour = int.parse(v!),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Price is required';
                              if (int.tryParse(v) == null) return 'Invalid number';
                              if (int.parse(v) <= 0) return 'Must be > 0';
                              return null;
                            },
                          ),

                          _buildSportDropdown(),

                          _buildRegionDropdown(),

                          _buildTextField(
                            label: 'Quantity',
                            icon: Icons.layers_outlined,
                            keyboardType: TextInputType.number,
                            onSaved: (v) => quantity = int.parse(v!),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Quantity is required';
                              if (int.tryParse(v) == null) return 'Invalid number';
                              if (int.parse(v) <= 0) return 'Must be > 0';
                              return null;
                            },
                          ),

                          _buildTextField(
                            label: 'Thumbnail URL (Optional)',
                            icon: Icons.image_outlined,
                            onSaved: (v) => thumbnail = v,
                          ),

                          const SizedBox(height: 10),

                          // Availability Switch with Style
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: SwitchListTile(
                              title: const Text(
                                'Availability',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              subtitle: Text(
                                available ? 'Item is ready to rent' : 'Currently unavailable',
                                style: TextStyle(color: available ? primaryGreen : Colors.red),
                              ),
                              value: available,
                              activeColor: primaryGreen,
                              onChanged: (v) => setState(() => available = v),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Primary Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  final response = await request.postJson(
                                    'https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/equipment/create-flutter/',
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
                                  if (response['status'] == 'success') {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Equipment successfully listed!'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: primaryGreen,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(response['message'] ?? 'Failed to save'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Save Equipment',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
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

  // ===================== CUSTOM BUILDERS =====================

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]),
          prefixIcon: Icon(icon, color: primaryGreen),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
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