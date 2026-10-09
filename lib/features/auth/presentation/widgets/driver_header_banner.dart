import 'package:flutter/material.dart';

class DriverHeaderBanner extends StatelessWidget {
  const DriverHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEA619).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 4, backgroundColor: Color(0xFF684000)),
              SizedBox(width: 6),
              Text(
                'شريك نقل معتمد - مدينة العبور',
                style: TextStyle(
                  color: Color(0xFF684000),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'تسجيل حساب سائق جديد',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'انضم لشبكة مواصلات مدينة العبور وأحيائها وابدأ استقبال الرحلات',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF757684)),
        ),
      ],
    );
  }
}