import 'package:flutter/material.dart';
import 'package:suzuki_app/features/auth/data/models/auth_model.dart';

class VehiclePlateCard extends StatelessWidget {
  const VehiclePlateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('رقم اللوحة المعدنية (لوحة أجرة مصر):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFDAE2FD), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: const BoxDecoration(color: Color(0xFFFEA619), borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('مـصــر', style: TextStyle(fontWeight: FontWeight.bold)), Text('EGYPT', style: TextStyle(fontWeight: FontWeight.bold))],
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('٢ ٨ ٤ ٥', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 30, child: VerticalDivider(thickness: 2)),
                    Text('ق ن ص', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ZoneAndPaymentFieldsStep extends StatefulWidget {
  final DriverRegistrationModel formData;
  final List<String> elObourDistricts;

  const ZoneAndPaymentFieldsStep({
    super.key,
    required this.formData,
    required this.elObourDistricts,
  });

  @override
  State<ZoneAndPaymentFieldsStep> createState() => _ZoneAndPaymentFieldsStepState();
}

class _ZoneAndPaymentFieldsStepState extends State<ZoneAndPaymentFieldsStep> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('اختر أحياء مدينة العبور المفضل العمل بها:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: widget.elObourDistricts.map((district) {
            final isSelected = widget.formData.selectedElObourDistricts.contains(district);
            return FilterChip(
              label: Text(district, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
              selected: isSelected,
              selectedColor: const Color(0xFF00288E),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    widget.formData.selectedElObourDistricts.add(district);
                  } else {
                    widget.formData.selectedElObourDistricts.remove(district);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: widget.formData.cashWalletNumber,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'رقم محفظة كاش للتسويات المالية',
            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => widget.formData.cashWalletNumber = v,
        ),
      ],
    );
  }
}