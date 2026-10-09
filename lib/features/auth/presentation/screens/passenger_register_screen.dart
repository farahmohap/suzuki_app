import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';

class PassengerRegisterScreen extends StatefulWidget {
  const PassengerRegisterScreen({super.key});

  @override
  State<PassengerRegisterScreen> createState() =>
      _PassengerRegisterScreenState();
}

class _PassengerRegisterScreenState extends State<PassengerRegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isMale = true;
  bool _acceptTerms = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.85),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: Center(
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => Navigator.maybePop(context),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLow,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Text(
          'تسجيل راكب جديد',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Column(
                children: [
                  Container(
                    width: 80.r,
                    height: 80.r,
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.directions_bus_filled_rounded,
                      size: 40.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hail,
                          size: 16.sp,
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'حساب راكب جديد',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans',
                            fontSize: 11.sp,
                            color: AppColors.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'سجل الآن لتصل إلى أقرب سوزوكي في مدينتك بكل سهولة وأمان',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans',
                      fontSize: 12.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Avatar Picker
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 48.r,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          child: Icon(
                            Icons.person,
                            size: 48.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16.r,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.photo_camera,
                              size: 18.sp,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'أضف صورة شخصية (اختياري)',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 12.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Main Form Container Card
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _buildLabel('الاسم بالكامل', Icons.badge, isRequired: true),
                    SizedBox(height: 6.h),
                    _buildInputField(
                      _fullNameController,
                      'مثال: أحمد مصطفى عبد الرحمن',
                    ),
                    SizedBox(height: 16.h),

                    // Phone Number
                    _buildLabel(
                      'رقم الموبايل',
                      Icons.smartphone,
                      isRequired: true,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Container(
                          height: 52.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Text('🇪🇬', style: TextStyle(fontSize: 16.sp)),
                              SizedBox(width: 4.w),
                              Text(
                                '+20',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildInputField(
                            _phoneController,
                            '010 1234 5678',
                            inputType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'سنرسل لك كود تفعيل فوري في رسالة SMS',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 11.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Age & Gender
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('السن', Icons.cake, isRequired: true),
                              SizedBox(height: 6.h),
                              _buildInputField(
                                _ageController,
                                '26',
                                inputType: TextInputType.number,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                'النوع',
                                Icons.group,
                                isRequired: true,
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                height: 52.h,
                                padding: EdgeInsets.all(4.r),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            setState(() => _isMale = true),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _isMale
                                                ? AppColors
                                                      .surfaceContainerLowest
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'ذكر',
                                            style: TextStyle(
                                              fontFamily: 'IBM Plex Sans',
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              color: _isMale
                                                  ? AppColors.primary
                                                  : AppColors.outline,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            setState(() => _isMale = false),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          decoration: BoxDecoration(
                                            color: !_isMale
                                                ? AppColors
                                                      .surfaceContainerLowest
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'أنثى',
                                            style: TextStyle(
                                              fontFamily: 'IBM Plex Sans',
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              color: !_isMale
                                                  ? AppColors.primary
                                                  : AppColors.outline,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Email
                    _buildLabel(
                      'البريد الإلكتروني',
                      Icons.mail,
                      subLabel: '(اختياري للإيصالات)',
                    ),
                    SizedBox(height: 6.h),
                    _buildInputField(
                      _emailController,
                      'name@example.com',
                      inputType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.h),

                    // Address
                    _buildLabel(
                      'العنوان بالتفصيل',
                      Icons.home_mini,
                      isRequired: true,
                    ),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: _addressController,
                      maxLines: 3,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'مثال: مدينة 6 أكتوبر - الحي الرابع - المجاورة 2 - عمارة 15 بالقرب من مسجد الحصري',
                        hintStyle: TextStyle(
                          fontFamily: 'IBM Plex Sans',
                          fontSize: 12.sp,
                          color: AppColors.outlineVariant,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Location Card Map Mock
                    Container(
                      height: 160.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 10.h,
                            right: 10.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest
                                    .withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                'موقف الحصري • أكتوبر',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.directions_subway_outlined,
                            size: 32.sp,
                            color: AppColors.primary,
                          ),
                          Positioned(
                            bottom: 10.h,
                            left: 10.w,
                            right: 10.w,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.my_location, size: 18),
                              label: const Text(
                                'حدد موقعك الحالي تلقائياً 📍',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.surfaceContainerLowest,
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Terms & Submit
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (val) =>
                        setState(() => _acceptTerms = val ?? true),
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Text(
                      'أوافق على شروط الاستخدام وقواعد الركوب الآمن في منظومة سوق سوزوكي.',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 12.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              ElevatedButton(
                onPressed: () =>
                    context.goNamed(AppRoute.passengerHome.routeName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'إنشاء الحساب',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(
    String title,
    IconData icon, {
    bool isRequired = false,
    String? subLabel,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primary),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans',
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (subLabel != null)
          Text(
            ' $subLabel',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans',
              fontSize: 11.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint, {
    TextInputType inputType = TextInputType.text,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Container(
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        textAlign: textAlign,
        style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'IBM Plex Sans',
            fontSize: 13.sp,
            color: AppColors.outlineVariant,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
