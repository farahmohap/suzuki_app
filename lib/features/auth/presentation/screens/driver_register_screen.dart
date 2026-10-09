import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suzuki_app/core/constants/app_colors.dart';
import 'package:suzuki_app/features/auth/data/models/auth_model.dart';
import 'package:suzuki_app/features/auth/presentation/widgets/docuemants_field_steps.dart';
import 'package:suzuki_app/features/auth/presentation/widgets/driver_header_banner.dart';
import 'package:suzuki_app/features/auth/presentation/widgets/personal_fields_step.dart';
import 'package:suzuki_app/features/auth/presentation/widgets/plate_and_zone_step.dart';
import 'package:suzuki_app/features/auth/presentation/widgets/section_card.dart';
import 'package:suzuki_app/features/auth/presentation/widgets/vehicle_fields_step.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final DriverRegistrationModel _formData = DriverRegistrationModel();
  bool _termsAccepted = false;

  final List<String> _elObourDistricts = const [
    'الحي الأول',
    'الحي الثاني',
    'الحي الخامس',
    'الحي السابع',
    'الحي التاسع',
    'المنطقة الصناعية',
    'العبور الجديدة',
    'حي الشباب',
    'الترانزيت / المحور الرئيسي',
  ];

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري إرسال طلب تسجيل السائق في مدينة العبور...'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'تسجيل سائق جديد',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.all(16.r),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const DriverHeaderBanner(),
                    SizedBox(height: 20.h),
                    SectionCard(
                      stepText: 'خطوة ١ من ٥',
                      title: 'البيانات الشخصية',
                      subtitle: 'الاسم ورقم الموبايل والفتوغرافيا',
                      icon: Icons.person_outline,
                      child: PersonalFieldsStep(
                        formData: _formData,
                        onPhotoChanged: (file) =>
                            setState(() => _formData.driverPhoto = file),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const SectionCard(
                      stepText: 'خطوة ٢ من ٥',
                      title: 'المستندات الرسمية',
                      subtitle: 'البطاقة الشخصية والرخص والفيش',
                      icon: Icons.verified_user_outlined,
                      child: DocumentsFieldsStep(),
                    ),
                    SizedBox(height: 16.h),
                    const SectionCard(
                      stepText: 'خطوة ٣ من ٥',
                      title: 'معرض صور السوزوكي',
                      subtitle: 'التقط صوراً واضحة للسيارة والصالون',
                      icon: Icons.add_a_photo_outlined,
                      child: VehiclePhotosStep(),
                    ),
                    SizedBox(height: 16.h),
                    const SectionCard(
                      stepText: 'خطوة ٤ من ٥',
                      title: 'بيانات اللوحة والسيارة',
                      subtitle: 'رقم اللوحة المعدنية وحالة الفحص',
                      icon: Icons.directions_car_outlined,
                      child: VehiclePlateCard(),
                    ),
                    SizedBox(height: 16.h),
                    SectionCard(
                      stepText: 'خطوة ٥ من ٥',
                      title: 'خط السير والمحفظة',
                      subtitle: 'تحديد أحياء العبور ومحفظة الكاش',
                      icon: Icons.alt_route_rounded,
                      child: ZoneAndPaymentFieldsStep(
                        formData: _formData,
                        elObourDistricts: _elObourDistricts,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          activeColor: AppColors.primary,
                          onChanged: (v) =>
                              setState(() => _termsAccepted = v ?? false),
                        ),
                        Expanded(
                          child: Text(
                            'أوافق على الشروط والأحكام الخاصة بنقل الركاب داخل مدينة العبور',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 54.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: _termsAccepted ? _handleSubmit : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'إرسال طلب التسجيل',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text('🚀', style: TextStyle(fontSize: 18.sp)),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
