import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:lapang/widgets/left_drawer.dart';
import 'package:lapang/main.dart';

import 'package:lapang/models/venue.dart';
import 'package:lapang/models/custom_user.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LapaNG',
        ),
      ),
      body: Column(children: [
        //user info, bookings listing
      ],)
    );
  }
}
