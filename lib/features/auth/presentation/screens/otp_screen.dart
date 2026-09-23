import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('OtpScreen'),
      ),
    );
  }
}
