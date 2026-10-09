import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isDriver = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برجاء إدخال رقم هاتف صحيح مكون من 11 رقم'),
        ),
      );
      return;
    }

    context.pushNamed(
      AppRoute.otp.routeName,
      extra: {'phone': phone, 'isDriver': _isDriver},
    );
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
          'تسجيل الدخول',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.onSurface,
              size: 20,
            ),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLow,
              shape: const CircleBorder(),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visual Brand Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(
                          Icons.wb_sunny_outlined,
                          size: 20,
                          color: AppColors.outlineVariant,
                        ),
                        Icon(
                          Icons.location_city_outlined,
                          size: 24,
                          color: AppColors.outlineVariant,
                        ),
                        Icon(
                          Icons.park_outlined,
                          size: 22,
                          color: AppColors.outlineVariant,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 96.r,
                          height: 96.r,
                          padding: EdgeInsets.all(8.r),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.directions_bus_filled_rounded,
                            size: 50.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        Positioned(
                          bottom: -4,
                          left: -4,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.electric_bolt,
                                  size: 13.sp,
                                  color: AppColors.onSecondaryContainer,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'سريع',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'سوق سوزوكي',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'مرحباً بك مجدداً! أدخل رقم الموبايل للدخول',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 14.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.near_me_outlined,
                              size: 16.sp,
                              color: AppColors.tertiary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'الشيخ زايد',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans',
                                fontSize: 11.sp,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Container(
                              height: 2.h,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'موقف الحصري',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans',
                                fontSize: 11.sp,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.pin_drop,
                              size: 16.sp,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Segmented Toggle Control
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isDriver = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: !_isDriver
                                ? AppColors.surfaceContainerLowest
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: !_isDriver
                                ? [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: 20.sp,
                                color: !_isDriver
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'راكب',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: !_isDriver
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isDriver = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: _isDriver
                                ? AppColors.surfaceContainerLowest
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: _isDriver
                                ? [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_taxi,
                                size: 20.sp,
                                color: _isDriver
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'كابتن سوزوكي (سائق)',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _isDriver
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // Dynamic Role Description Banner
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        _isDriver
                            ? 'انضم لشبكة كباتن سوزوكي وزود دخلك اليومي برحلات منتظمة.'
                            : 'احجز كرسيك في التمناية بضغطة واحدة وبدون انتظار.',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans',
                          fontSize: 12.sp,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Phone Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.smartphone,
                            size: 18.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'رقم الموبايل',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'تأكيد فوري عبر SMS',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans',
                          fontSize: 11.sp,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Text('🇪🇬', style: TextStyle(fontSize: 16.sp)),
                              SizedBox(width: 6.w),
                              Text(
                                '+20',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            decoration: const InputDecoration(
                              hintText: '01X XXXX XXXX',
                              hintStyle: TextStyle(
                                color: AppColors.outlineVariant,
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Submit Button
              ElevatedButton(
                onPressed: _handleSendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'إرسال كود التفعيل (OTP)',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    const Icon(Icons.arrow_forward, size: 22),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Navigation to Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'أول مرة تنورنا؟ ',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans',
                      fontSize: 14.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        AppRoute.register.routeName,
                        extra: {'role': _isDriver ? 'driver' : 'passenger'},
                      );
                    },
                    child: Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
