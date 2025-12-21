import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lapang/models/equipments_entry.dart';
import 'package:lapang/models/custom_user.dart';

class EquipmentEntryCard extends StatelessWidget {
  final EquipmentEntry equipment;
  final String currentUsername;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  static const primaryGreen = Color(0xFF2E7D32);
  static const accentGreen = Color(0xFFE8F5E9);

  const EquipmentEntryCard({
    super.key,
    required this.equipment,
    required this.currentUsername,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  bool get isOwner => equipment.user.username == currentUsername;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: _buildThumbnail(),
                ),

                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2), 
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                ),

                // Tombol kontak owner
                if (!isOwner)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => showContactOwner(context, equipment.user),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/WhatsApp.svg/1024px-WhatsApp.svg.png',
                            width: 22,
                            height: 22,
                            errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.chat, size: 22, color: primaryGreen),
                          ),
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: equipment.available ? Colors.green : Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Text(
                      equipment.available ? 'AVAILABLE' : 'RENTED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          equipment.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 1, 15, 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTag(Icons.sports_soccer, toTitleCase(equipment.sportCategory)),
                      _buildTag(Icons.location_on_outlined, toTitleCase(equipment.region)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Rp ${equipment.pricePerHour}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: primaryGreen,
                        ),
                      ),
                      const Text(' / hour', style: TextStyle(color: Colors.grey)),
                      const Spacer(),
                      const Icon(Icons.layers_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Stock: ${equipment.quantity}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),

            if (isOwner) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(foregroundColor: primaryGreen),
                    ),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BUILDER THUMBNAIL
  // ==========================================
  Widget _buildThumbnail() {
    // Jika tidak ada URL thumbnail
    if (equipment.thumbnail.isEmpty) {
      return _buildPlaceholder();
    }

    final imageUrl = 'https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/equipment/get-equipment/?url=${Uri.encodeComponent(equipment.thumbnail)}';

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      // Jika loading
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: primaryGreen.withOpacity(0.5),
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      // Jika error (misal server mati atau gambar rusak)
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(isError: true);
      },
    );
  }

  Widget _buildPlaceholder({bool isError = false}) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isError ? Icons.broken_image_outlined : Icons.sports_basketball_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              isError ? 'Image Error' : 'No Image',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accentGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

void showContactOwner(BuildContext context, CustomUser owner) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== AVATAR =====
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: EquipmentEntryCard.primaryGreen.withOpacity(0.25),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: EquipmentEntryCard.accentGreen,
                  child: Icon(
                    Icons.person,
                    size: 38,
                    color: EquipmentEntryCard.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // ===== NAME =====
              Text(
                owner.name,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              // ===== USERNAME =====
              Text(
                '@${owner.username ?? '-'}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 22),
              // ===== CONTACT CARD =====
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: EquipmentEntryCard.accentGreen,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/WhatsApp.svg/1024px-WhatsApp.svg.png',
                      width: 26,
                      height: 26,
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.chat, color: EquipmentEntryCard.primaryGreen),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        owner.formattedNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: owner.formattedNumber),
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contact number copied'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      color: EquipmentEntryCard.primaryGreen,
                      tooltip: 'Copy number',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              // ===== ACTION =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: EquipmentEntryCard.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ================= FORMATTERS =================
String toTitleCase(String text) {
  return text
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) =>
          word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '')
      .join(' ');
}

String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}