import 'package:flutter/material.dart';
import 'package:lapang/screens/feeds/feeds_page.dart';
import 'package:lapang/screens/home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapang/screens/auth/login.dart';
// TODO: Import halaman teman-teman lain di sini
import 'package:lapang/screens/booking/booking_list_screen.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
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
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),

          // === LOGOUT ===
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final response = await request.logout(
                "http://localhost:8000/api/auth/logout/",
              );
              String message = response["message"];
              if (context.mounted) {
                if (response['status']) {
                    String uname = response["username"];
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("$message See you again, $uname."),
                    ));
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(message),
                        ),
                    );
                }
              }
            },
          ),

          // === Navigasi Feeds ===
          ListTile(
            leading: const Icon(Icons.dynamic_feed),
            title: const Text('Feeds'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedsPage()),
              );
            },
          ),

          // === Booking List ===
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Booking Saya'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingListScreen(),
                ),
              );
            },
          ),

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

