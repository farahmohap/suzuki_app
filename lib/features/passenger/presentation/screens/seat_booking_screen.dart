import 'package:flutter/material.dart';

class SeatBookingScreen extends StatelessWidget {
  const SeatBookingScreen({super.key, required this.routeId});

  final String routeId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('SeatBookingScreen'),
      ),
    );
  }
}
