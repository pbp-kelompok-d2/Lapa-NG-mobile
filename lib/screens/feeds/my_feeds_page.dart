import 'package:flutter/material.dart';
import 'package:lapang/models/feeds.dart';
import 'package:lapang/screens/feeds/feeds_page.dart';
import 'package:lapang/widgets/feeds/feeds_card.dart';
import 'package:lapang/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MyFeedsPage extends StatelessWidget {
  const MyFeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeedsPage(); // sama saja, nanti user tinggal pencet tombol "My Feeds"
  }
}
