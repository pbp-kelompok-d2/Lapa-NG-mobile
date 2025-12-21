import 'package:flutter/material.dart';
import 'package:lapang/screens/equipment/equipment_entry_list.dart';
import 'package:lapang/screens/home/home_page.dart';
import 'package:lapang/screens/home/venues_page.dart';
import 'package:lapang/screens/feeds/feeds_page.dart';
import 'package:lapang/screens/reviews/reviews_page.dart';
import 'package:lapang/screens/auth/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapang/screens/booking/booking_list_screen.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Drawer(
      child: ListView(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Lapa-NG User"),
            accountEmail: Text("user@lapa-ng.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.green, size: 40),
            ),
            decoration: BoxDecoration(color: Colors.green),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.stadium_outlined),
            title: const Text('Venues'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VenuesPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Bookings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingListScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.sports_tennis_outlined), 
            title: const Text('Equipment'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const EquipmentEntryListPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.forum_outlined),
            title: const Text('Feeds'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FeedsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.reviews_outlined),
            title: const Text('Reviews'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ReviewsPage()),
              );
            },
          ),
          const Divider(),
          if (request.loggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final response = await request.logout("http://127.0.0.1:8000/auth/logout/");
                if (context.mounted) {
                  String message = response["message"];
                  if (response['status']) {
                    String uname = response["username"];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$message Sampai jumpa, $uname.")),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                }
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login, color: Colors.green),
              title: const Text('Login', style: TextStyle(color: Colors.green)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
        ],
      ),
    );
  }
}