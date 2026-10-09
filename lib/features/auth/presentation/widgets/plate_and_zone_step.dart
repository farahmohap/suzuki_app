import 'package:flutter/material.dart';
import 'package:suzuki_app/features/auth/data/models/auth_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suzuki_app/core/constants/app_colors.dart';

class InteractiveVehiclePlateCard extends StatefulWidget {
  final ValueChanged<String>? onNumbersChanged;
  final ValueChanged<String>? onLettersChanged;

  const InteractiveVehiclePlateCard({
    super.key,
    this.onNumbersChanged,
    this.onLettersChanged,
  });

  @override
  State<InteractiveVehiclePlateCard> createState() =>
      _InteractiveVehiclePlateCardState();
}

class _InteractiveVehiclePlateCardState
    extends State<InteractiveVehiclePlateCard> {
  final TextEditingController _numbersController = TextEditingController();
  final TextEditingController _lettersController = TextEditingController();

  @override
  void dispose() {
    _numbersController.dispose();
    _lettersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم اللوحة المعدنية (ادخل الأرقام والحروف):',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              // Plate Header (Egypt Band)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مـصــر',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      'EGYPT',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              // Interactive Plate Body Inputs
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                child: Row(
                  children: [
                    // 1. Plate Numbers Field (Right side in LTR layout)
                    Expanded(
                      child: TextFormField(
                        controller: _numbersController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.w,
                          color: AppColors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: '٤٣٢١',
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.outlineVariant,
                            fontSize: 18.sp,
                            letterSpacing: 0,
                          ),
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: widget.onNumbersChanged,
                      ),
                    ),

                    // Divider
                    SizedBox(
                      height: 35.h,
                      child: VerticalDivider(
                        thickness: 2,
                        color: AppColors.outlineVariant,
                      ),
                    ),

                    // 2. Plate Letters Field (Left side)
                    Expanded(
                      child: TextFormField(
                        controller: _lettersController,
                        textAlign: TextAlign.center,
                        maxLength: 3,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.w,
                          color: AppColors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'أ ب ج',
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.outlineVariant,
                            fontSize: 18.sp,
                            letterSpacing: 0,
                          ),
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: widget.onLettersChanged,
                      ),
                    ),
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
  State<ZoneAndPaymentFieldsStep> createState() =>
      _ZoneAndPaymentFieldsStepState();
}

class _ZoneAndPaymentFieldsStepState extends State<ZoneAndPaymentFieldsStep> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر أحياء مدينة العبور المفضل العمل بها:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: widget.elObourDistricts.map((district) {
            final isSelected = widget.formData.selectedElObourDistricts
                .contains(district);
            return FilterChip(
              label: Text(
                district,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF00288E),
              onSelected: (selected) {
                setState(() {
                  // تحويل القائمة إلى Mutable List لضمان إمكانية الإضافة والحذف
                  final currentList = List<String>.from(
                    widget.formData.selectedElObourDistricts,
                  );

                  if (selected) {
                    currentList.add(district);
                  } else {
                    currentList.remove(district);
                  }

                  widget.formData.selectedElObourDistricts = currentList;
                });
              },
            );
          }).toList(),
        ),
        // const SizedBox(height: 12),
        // TextFormField(
        //   initialValue: widget.formData.cashWalletNumber,
        //   keyboardType: TextInputType.phone,
        //   decoration: const InputDecoration(
        //     labelText: 'رقم محفظة كاش للتسويات المالية',
        //     prefixIcon: Icon(Icons.account_balance_wallet_outlined),
        //     border: OutlineInputBorder(),
        //   ),
        //   onChanged: (v) => widget.formData.cashWalletNumber = v,
        // ),
      ],
    );
  }
}
