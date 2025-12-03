import 'package:flutter/material.dart';
import 'package:lapang/models/equipments_entry.dart';

class EquipmentEntryCard extends StatelessWidget {
  final EquipmentEntry equipment;
  final String currentUsername;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onContactOwner;
  final VoidCallback? onTap;

  const EquipmentEntryCard({
    super.key,
    required this.equipment,
    required this.currentUsername,
    this.onEdit,
    this.onDelete,
    this.onContactOwner,
    this.onTap,
  });

  bool get isOwner => equipment.userUsername == currentUsername;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail + contact button
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                    equipment.thumbnail.isNotEmpty ?
                    'http://localhost:8000/equipment/get-equipment/?url=${Uri.encodeComponent(equipment.thumbnail)}' 
                    : 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.shutterstock.com%2Fimage-vector%2Fno-image-available-icon-flat-vector-1240855801&psig=AOvVaw19eNKxiQXCbhTIsLtViqAp&ust=1764660972034000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCPjv5sfwm5EDFQAAAAAdAAAAABAK',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: onContactOwner,
                      icon: Image.network(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQphGpv3nHmgfG8uZwIWDykLJk08vwHz_nXTQ&s',
                        width: 24,
                        height: 24,
                      ),
                      color: Colors.green,
                      tooltip: 'Contact Owner',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      equipment.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Category & Region
                    Text('Kategori: ${equipment.sportCategory}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    Text('Wilayah: ${equipment.region}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),

                    // Price & Quantity
                    Text('💰 Rp ${equipment.pricePerHour}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    Text('📦 Quantity: ${equipment.quantity}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),

                    // Availability
                    Text(
                      equipment.available ? 'Tersedia' : 'Tidak tersedia',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: equipment.available ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Edit & Delete Buttons (Owner only)
              if (isOwner)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: onEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(60, 36),
                        ),
                        child: const Text('Edit', style: TextStyle(fontSize: 14)),
                      ),
                      ElevatedButton(
                        onPressed: onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(60, 36),
                        ),
                        child: const Text('Delete', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}