import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suzuki_app/core/constants/app_colors.dart';
import 'package:suzuki_app/core/di/injection.dart';
import 'package:suzuki_app/core/utils/validators.dart';
import 'package:suzuki_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:suzuki_app/features/driver_onboarding/data/models/onboarding_models.dart';
import 'package:suzuki_app/features/driver_onboarding/presentation/cubit/driver_onboarding_cubit.dart';
import 'package:suzuki_app/features/driver_onboarding/presentation/widgets/document_tile.dart';
import 'package:suzuki_app/features/profile/data/models/profile_models.dart';

class DriverOnboardingScreen extends StatelessWidget {
  const DriverOnboardingScreen({super.key, this.previewMode = false});

  final bool previewMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DriverOnboardingCubit>()..init(previewMode: previewMode),
      child: _WizardView(previewMode: previewMode),
    );
  }
}

class _WizardView extends StatefulWidget {
  const _WizardView({required this.previewMode});

  final bool previewMode;

  @override
  State<_WizardView> createState() => _WizardViewState();
}

class _WizardViewState extends State<_WizardView> {
  final _personalFormKey = GlobalKey<FormState>();
  final _vehicleFormKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _nationalId = TextEditingController();
  final _plateNumbers = TextEditingController();
  final _plateLetters = TextEditingController();
  final _model = TextEditingController();

  DateTime? _birthDate;
  Gender _gender = Gender.male;
  DistrictModel? _district;
  String? _carColor;

  /// Sent to the backend as `car_color` (Arabic label).
  static const _carColors = [
    'أبيض',
    'أسود',
    'فضي',
    'رمادي',
    'أزرق',
    'أحمر',
    'أخضر',
    'بيج',
    'ذهبي',
    'أخرى',
  ];

  static const _titles = [
    'البيانات الشخصية',
    'بيانات السيارة',
    'المستندات والصور',
  ];

  static const _subtitles = [
    'الاسم والبيانات الأساسية للسائق',
    'بيانات السوزوكي ورقم اللوحة',
    'ارفع المستندات والصور المطلوبة',
  ];

  static const _icons = [
    Icons.person_outline,
    Icons.directions_car_outlined,
    Icons.verified_user_outlined,
  ];

  @override
  void dispose() {
    _name.dispose();
    _nationalId.dispose();
    _plateNumbers.dispose();
    _plateLetters.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverOnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          previous.error != current.error ||
          previous.submitted != current.submitted,
      listener: (context, state) {
        if (state.submitted) {
          if (!widget.previewMode) context.read<AuthCubit>().refreshUser();
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error!,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(context, state),
          body: state.submitted && widget.previewMode
              ? _previewCompleteBody()
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(state),
                        SizedBox(height: 20.h),

                        // Preserve values when moving back between steps.
                        IndexedStack(
                          index: state.step,
                          children: [
                            _personalSection(context, state),
                            _vehicleSection(context, state),
                            _documentsSection(context, state),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _previewCompleteBody() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 72.sp, color: AppColors.primary),
              SizedBox(height: 16.h),
              Text(
                'اكتملت معاينة التسجيل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'لم يتم إرسال أي بيانات إلى الخادم.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    OnboardingState state,
  ) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: state.step > 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: context.read<DriverOnboardingCubit>().back,
            )
          : IconButton(
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
      actions: [
        TextButton(
          onPressed: () => context.read<AuthCubit>().logout(),
          child: Text(
            'خروج',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(OnboardingState state) {
    final progress = (state.step + 1) / 3;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFEA619).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF684000),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'شريك نقل معتمد - مدينة العبور',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: const Color(0xFF684000),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        Text(
          'تسجيل حساب سائق جديد',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          'انضم لشبكة مواصلات مدينة العبور وابدأ استقبال الرحلات',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11.sp,
            color: AppColors.onSurfaceVariant,
          ),
        ),

        SizedBox(height: 20.h),

        _buildProgressIndicator(state.step, progress),
      ],
    );
  }

  Widget _buildProgressIndicator(int currentStep, double progress) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive || isCompleted
                            ? AppColors.primary
                            : AppColors.surfaceContainerHigh,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16.sp,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                      ),
                    ),
                    if (index < 2)
                      Expanded(
                        child: Container(
                          height: 2.h,
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                          color: index < currentStep
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'خطوة ${currentStep + 1} من 3',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                _titles[currentStep],
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.h,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1
  // ---------------------------------------------------------------------------

  Widget _personalSection(BuildContext context, OnboardingState state) {
    return _sectionCard(
      stepText: 'خطوة ١ من ٣',
      title: _titles[0],
      subtitle: _subtitles[0],
      icon: _icons[0],
      child: _personalStep(context, state),
    );
  }

  Widget _personalStep(BuildContext context, OnboardingState state) {
    return Form(
      key: _personalFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          _buildDriverPhoto(context, state),
          SizedBox(height: 20.h),

          _field(
            _name,
            'الاسم بالكامل',
            Icons.badge_outlined,
            validator: AppValidators.fullName,
          ),

          _field(
            _nationalId,
            'الرقم القومي (14 رقم)',
            Icons.credit_card,
            keyboard: TextInputType.number,
            textDirection: TextDirection.ltr,
            validator: AppValidators.nationalId,
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
                  child: Text(
                    'النوع',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<Gender>(
                    showSelectedIcon: false,
                    segments: [
                      for (final gender in Gender.values)
                        ButtonSegment<Gender>(
                          value: gender,
                          label: Text(gender.labelAr),
                        ),
                    ],
                    selected: {_gender},
                    onSelectionChanged: (selection) =>
                        setState(() => _gender = selection.first),
                  ),
                ),
              ],
            ),
          ),

          _buildBirthDateField(context),

          _buildDistrictField(state),

          SizedBox(height: 4.h),

          _bigButton(
            label: 'التالي',
            icon: Icons.arrow_forward,
            busy: state.busy,
            onPressed: () => _savePersonal(context),
          ),
        ],
      ),
    );
  }

  Future<void> _savePersonal(BuildContext context) async {
    if (!(_personalFormKey.currentState?.validate() ?? false)) return;
    final district = _district;
    final birthDate = _birthDate;
    if (district == null || birthDate == null) return;
    await context.read<DriverOnboardingCubit>().savePersonal(
      fullName: _name.text.trim(),
      nationalId: AppValidators.toAsciiDigits(_nationalId.text).trim(),
      birthDate: birthDate,
      districtId: district.id,
      gender: _gender,
    );
  }

  Widget _buildDistrictField(OnboardingState state) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: DropdownButtonFormField<DistrictModel>(
        value: _district,
        isExpanded: true,
        decoration: _dec('المنطقة', Icons.location_on_outlined),
        items: [
          for (final district in state.districts)
            DropdownMenuItem(value: district, child: Text(district.nameAr)),
        ],
        onChanged: (district) => setState(() => _district = district),
        validator: (district) => district == null ? 'اختر المنطقة' : null,
      ),
    );
  }

  Widget _buildDriverPhoto(
    BuildContext context,
    OnboardingState state,
    // DriverOnboardingCubit cubit,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final file = await ImagePicker().pickImage(
              source: ImageSource.camera,
              imageQuality: 80,
              maxWidth: 1024,
              preferredCameraDevice: CameraDevice.front,
            );

            if (file != null) {
              context.read<DriverOnboardingCubit>().setAvatar(file.path);
            }
          },
          child: Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: state.avatarPath != null
                      ? Image.file(File(state.avatarPath!), fit: BoxFit.cover)
                      : Icon(
                          Icons.person_outline,
                          size: 45.sp,
                          color: AppColors.primary,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 3),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'الصورة الشخصية',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'التقط صورة واضحة لوجهك',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10.sp,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBirthDateField(BuildContext context) {
    return FormField<DateTime>(
      validator: (_) => _birthDate == null ? 'تاريخ الميلاد مطلوب' : null,
      builder: (field) {
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: InkWell(
            onTap: () async {
              final now = DateTime.now();

              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(now.year - 30),
                firstDate: DateTime(now.year - 80),
                lastDate: DateTime(now.year - 18, now.month, now.day),
              );

              if (date != null) {
                setState(() => _birthDate = date);
                field.didChange(date);
              }
            },
            borderRadius: BorderRadius.circular(12.r),
            child: InputDecorator(
              decoration: _dec(
                'تاريخ الميلاد',
                Icons.cake_outlined,
              ).copyWith(errorText: field.errorText),
              child: Text(
                _birthDate == null
                    ? 'اختر تاريخ الميلاد'
                    : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  color: _birthDate == null
                      ? AppColors.onSurfaceVariant
                      : AppColors.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2
  // ---------------------------------------------------------------------------

  Widget _vehicleSection(BuildContext context, OnboardingState state) {
    return _sectionCard(
      stepText: 'خطوة ٢ من ٣',
      title: _titles[1],
      subtitle: _subtitles[1],
      icon: _icons[1],
      child: _vehicleStep(context, state),
    );
  }

  Widget _vehicleStep(BuildContext context, OnboardingState state) {
    final cubit = context.read<DriverOnboardingCubit>();
    const vehiclePhotoTypes = [
      DocType.vanFront,
      DocType.vanRear,
      DocType.vanInterior,
    ];
    const vehiclePhotoIcons = {
      DocType.vanFront: Icons.directions_car,
      DocType.vanRear: Icons.directions_car,
      DocType.vanInterior: Icons.airline_seat_recline_normal,
    };

    return Form(
      key: _vehicleFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPlatePreview(),

          SizedBox(height: 18.h),

          _field(
            _model,
            'موديل السوزوكي',
            Icons.directions_car_outlined,
            validator: (v) => AppValidators.required(v, label: 'الموديل'),
          ),

          // NEW: car color.
          _buildCarColorField(),

          SizedBox(height: 8.h),
          for (final type in vehiclePhotoTypes)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: DocumentTile(
                label: type.labelAr,
                icon: vehiclePhotoIcons[type]!,
                slot: state.slot(type),
                enabled: true,
                onPicked: (path) => cubit.uploadDocument(type, path),
                onRemove: () => cubit.removeDocument(type),
              ),
            ),

          Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'عدد المقاعد: 7 ثابت — سيتم فحص السيارة في موقف العبور قبل التفعيل.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _bigButton(
            label: 'التالي',
            icon: Icons.arrow_forward,
            busy: state.busy,
            onPressed: () => _saveVehicle(context),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVehicle(BuildContext context) async {
    if (!(_vehicleFormKey.currentState?.validate() ?? false)) return;
    final color = _carColor;
    if (color == null) return;
    await context.read<DriverOnboardingCubit>().saveVehicle(
      VehicleInput(
        plateNumbers: AppValidators.toAsciiDigits(_plateNumbers.text).trim(),
        plateLetters: _plateLetters.text.trim(),
        model: _model.text.trim(),
        carColor: color,
      ),
    );
  }

  Widget _buildCarColorField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: DropdownButtonFormField<String>(
        value: _carColor,
        isExpanded: true,
        decoration: _dec('لون السيارة', Icons.palette_outlined),
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14.sp,
          color: AppColors.onSurface,
        ),
        items: [
          for (final color in _carColors)
            DropdownMenuItem<String>(value: color, child: Text(color)),
        ],
        onChanged: (value) => setState(() => _carColor = value),
        validator: (value) => value == null ? 'اختر لون السيارة' : null,
      ),
    );
  }

  Widget _buildPlatePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم اللوحة المعدنية',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: 8.h),

        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                color: AppColors.secondaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مـصــر',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      'EGYPT',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _plateNumbers,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 4,
                        validator: (value) {
                          final digits = AppValidators.toAsciiDigits(
                            value ?? '',
                          ).trim();
                          return RegExp(r'^\d{1,4}$').hasMatch(digits)
                              ? null
                              : 'أدخل أرقام اللوحة';
                        },
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.w,
                        ),
                        decoration: InputDecoration(
                          hintText: '٤٣٢١',
                          counterText: '',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18.sp,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 35.h,
                      child: VerticalDivider(
                        thickness: 2,
                        color: AppColors.outlineVariant,
                      ),
                    ),

                    Expanded(
                      child: TextFormField(
                        controller: _plateLetters,
                        textAlign: TextAlign.center,
                        maxLength: 3,
                        validator: (value) =>
                            AppValidators.required(value, label: 'حروف اللوحة'),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.w,
                        ),
                        decoration: InputDecoration(
                          hintText: 'أ ب ج',
                          counterText: '',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18.sp,
                            color: AppColors.outlineVariant,
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
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3
  // ---------------------------------------------------------------------------

  Widget _documentsSection(BuildContext context, OnboardingState state) {
    return _sectionCard(
      stepText: 'خطوة ٣ من ٣',
      title: _titles[2],
      subtitle: _subtitles[2],
      icon: _icons[2],
      child: _documentsStep(context, state),
    );
  }

  Widget _documentsStep(BuildContext context, OnboardingState state) {
    final cubit = context.read<DriverOnboardingCubit>();

    const icons = {
      DocType.nationalIdFront: Icons.credit_card,
      DocType.nationalIdBack: Icons.credit_card,
      DocType.drivingLicense: Icons.contact_emergency,
      DocType.vehicleLicense: Icons.description_outlined,
      DocType.criminalRecord: Icons.verified_user_outlined,
    };

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'تأكد من أن الصور واضحة وجميع البيانات ظاهرة قبل الرفع.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        ...DocType.values
            .where(
              (type) =>
                  type != DocType.vanFront &&
                  type != DocType.vanRear &&
                  type != DocType.vanInterior,
            )
            .map(
              (type) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: DocumentTile(
                  label: type.labelAr,
                  icon: icons[type]!,
                  slot: state.slot(type),
                  enabled: true,
                  onPicked: (path) => cubit.uploadDocument(type, path),
                  onRemove: () => cubit.removeDocument(type),
                ),
              ),
            ),

        SizedBox(height: 8.h),

        _bigButton(
          label: 'إرسال طلب التسجيل',
          icon: Icons.rocket_launch_outlined,
          busy: state.busy,
          onPressed: () => cubit.submit(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------

  Widget _sectionCard({
    required String stepText,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22.sp),
                ),

                SizedBox(width: 10.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stepText,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.sp,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),

            child,
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData? icon, {
    TextInputType? keyboard,
    String? hint,
    TextDirection? textDirection,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    double bottomPadding = 14,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        textInputAction: TextInputAction.next,
        textDirection: textDirection,
        inputFormatters: formatters,
        validator: validator,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14.sp,
          color: AppColors.onSurface,
        ),
        decoration: _dec(label, icon).copyWith(hintText: hint),
      ),
    );
  }

  InputDecoration _dec(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 12.sp,
        color: AppColors.onSurfaceVariant,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(icon, size: 20.sp, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: AppColors.outlineVariant.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.error, width: 1.3),
      ),
    );
  }

  Widget _bigButton({
    required String label,
    required bool busy,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: busy
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (icon != null) ...[
                    SizedBox(width: 8.w),
                    Icon(icon, size: 18.sp),
                  ],
                ],
              ),
      ),
    );
  }
}
