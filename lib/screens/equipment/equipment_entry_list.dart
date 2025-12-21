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
  Future<List<EquipmentEntry>> fetchEquipment(CookieRequest request) async {
    // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
    // If you using chrome,  use URL http://localhost:8000
    
    final response = await request.get('http://localhost:8000/equipment/json/');
    
    // Decode response to json format
    var data = response;
    
    // Convert json data to EquipmentEntry objects
    List<EquipmentEntry> listEquipment = [];
    for (var d in data) {
      if (d != null) {
        listEquipment.add(EquipmentEntry.fromJson(d));
      }
    }
    return listEquipment;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final currentUsername = request.jsonData['username'] ?? '';
    final isOwner = request.jsonData['role'] == 'owner';
    return Scaffold(
    appBar: AppBar(
            title: const Text(
              'Lapa-NG Equipment',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ),
      drawer: const LeftDrawer(),
        floatingActionButton: isOwner
      ? FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EquipmentFormPage(),
            ),
          ).then((_) {
            setState(() {});
          });
          },
          child: const Icon(Icons.add),
        )
      : null,
      body: Container(
        color: const Color(0xFFF1F8F4),
        child: FutureBuilder(
          future: fetchEquipment(request),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.sports, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'No equipment available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EquipmentEntryCard(
                    equipment: snapshot.data![index],
                    currentUsername: currentUsername,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditEquipmentPage(
                              equipment: snapshot.data![index],
                            ),
                          ),
                        ).then((value) {
                          if (value == true) {
                            setState(() {}); 
                          }
                        });
                      },

                      onDelete: () async {
                        final response = await request.post(
                          'http://localhost:8000/equipment/delete-equipment/${snapshot.data![index].id}/',
                          {},
                        );

                        if (response['status'] == 'success') {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Equipment deleted')),
                          );
                        }
                      },
                  ),
                ),
              );
            }
          },
        ),
      ),
    );

  }
}