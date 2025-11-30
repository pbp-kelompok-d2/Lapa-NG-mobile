import 'package:flutter/material.dart';
import 'package:lapang/screens/home/home_page.dart';
// TODO: Import halaman teman-teman lain di sini
// import 'package:lapang/screens/booking/booking_page.dart';
import 'package:lapang/screens/reviews/reviews_page.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green, // Sesuaikan warna tema Lapa-NG
            ),
            child: Column(
              children: [
                Text(
                  'Lapa-NG',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Text(
                  "Cari dan Booking Lapangan Favoritmu!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          // ===  NAVIGASI MAIN/HOME ===
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Halaman Utama'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ));
            },
          ),

          // ===  REVIEW ===
          ListTile(
            leading: const Icon(Icons.reviews),
            title: const Text('Review Lapangan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReviewsPage()),
              );
            },
          ),

          // === TEMPLATE  (TINGGAL COPAS) ===
          /* ListTile(
            leading: const Icon(Icons.shopping_basket), // Ganti Icon
            title: const Text('Booking Lapangan'),      // Ganti Nama Fitur
            onTap: () {
              // Route menu ke halaman booking
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookingPage()), // Ganti Page
              );
            },
          ),
          */

          // Contoh Integrasi Fitur Lain (Misal Review)
          /* ListTile(
            leading: const Icon(Icons.reviews),
            title: const Text('Lihat Review'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReviewPage()),
              );
            },
          ),
          */
        ],
      ),
    );
  }
}