import 'package:flutter/material.dart';

class ActiveTrackingScreen extends StatelessWidget {
  const ActiveTrackingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('ActiveTrackingScreen'),
      ),
    );
  }
}
