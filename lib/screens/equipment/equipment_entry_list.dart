import 'package:flutter/material.dart';
import 'package:lapang/models/equipments_entry.dart';
import 'package:lapang/widgets/left_drawer.dart';
import 'package:lapang/widgets/equipment/equipment_entry_card.dart';
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
    final currentUsername = request.jsonData['userUsername'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Entry List'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchEquipment(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'There are no Equipment available for now.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => EquipmentEntryCard(
                  equipment: snapshot.data![index],
                  currentUsername: currentUsername,
                ),
              );
            }
          }
        },
      ),
    );
  }
}