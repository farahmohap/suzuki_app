import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/profile_models.dart';
import '../cubit/profile_cubit.dart';

class PassengerProfileSetupScreen extends StatelessWidget {
  const PassengerProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ProfileCubit>()..loadDistricts(),
    child: const _PassengerRegistrationForm(),
  );
}

class _PassengerRegistrationForm extends StatefulWidget {
  const _PassengerRegistrationForm();

  @override
  State<_PassengerRegistrationForm> createState() =>
      _PassengerRegistrationFormState();
}

class _PassengerRegistrationFormState
    extends State<_PassengerRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  DateTime? _birthDate;
  Gender _gender = Gender.male;
  DistrictModel? _district;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _chooseBirthDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime(today.year - 25, today.month, today.day),
      firstDate: DateTime(1900, 1, 2),
      lastDate: today,
      locale: const Locale('ar'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _birthDate = date);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final date = _birthDate;
    if (date == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر تاريخ الميلاد')));
      return;
    }
    context.read<ProfileCubit>().savePassengerProfile(
      PassengerProfileInput(
        fullName: _name.text.trim(),
        birthDate: date,
        gender: _gender,
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        districtId: _district?.id,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<ProfileCubit, ProfileState>(
    listenWhen: (a, b) => a.saveStatus != b.saveStatus,
    listener: (context, state) {
      if (state.saveStatus == LoadStatus.success && state.savedUser != null) {
        context.read<AuthCubit>().updateUser(state.savedUser!);
      } else if (state.saveStatus == LoadStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error ?? 'تعذّر حفظ البيانات')),
        );
      }
    },
    builder: (context, state) {
      final busy = state.saveStatus == LoadStatus.loading;
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text('إنشاء حساب راكب', style: _titleStyle(18)),
          actions: [
            TextButton(
              onPressed: busy ? null : () => context.read<AuthCubit>().logout(),
              child: const Text('خروج'),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: AppColors.stitchCobaltLight,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        color: AppColors.stitchCobalt,
                        size: 30.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('بياناتك الشخصية', style: _titleStyle(16)),
                            Text(
                              'أكمل التسجيل للبدء باستخدام سوزوكي',
                              style: _bodyStyle(12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                _sectionTitle('المعلومات الأساسية'),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: _name,
                  maxLength: 120,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'الاسم مطلوب';
                    if (text.length < 2) {
                      return 'الاسم يجب أن يكون حرفين على الأقل';
                    }
                    return null;
                  },
                  decoration: _dec('الاسم بالكامل', Icons.badge_outlined),
                ),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: _chooseBirthDate,
                  borderRadius: BorderRadius.circular(14.r),
                  child: InputDecorator(
                    decoration: _dec('تاريخ الميلاد', Icons.cake_outlined),
                    child: Text(
                      _birthDate == null
                          ? 'اختر تاريخ الميلاد'
                          : '${_birthDate!.year.toString().padLeft(4, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
                      style: _bodyStyle(14),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text('النوع', style: _titleStyle(14)),
                SizedBox(height: 8.h),
                SegmentedButton<Gender>(
                  showSelectedIcon: false,
                  segments: [
                    for (final gender in Gender.values)
                      ButtonSegment(value: gender, label: Text(gender.labelAr)),
                  ],
                  selected: {_gender},
                  onSelectionChanged: (selection) =>
                      setState(() => _gender = selection.first),
                ),
                SizedBox(height: 20.h),
                _sectionTitle('العنوان (اختياري)'),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: _address,
                  maxLength: 255,
                  maxLines: 2,
                  decoration: _dec('العنوان بالتفصيل', Icons.home_outlined),
                ),
                SizedBox(height: 12.h),
                _districtField(state),
                SizedBox(height: 24.h),
                SizedBox(
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: busy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: busy
                        ? SizedBox(
                            width: 22.r,
                            height: 22.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'إنشاء الحساب',
                            style: _titleStyle(15, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _districtField(ProfileState state) {
    if (state.districtsStatus == LoadStatus.initial ||
        state.districtsStatus == LoadStatus.loading) {
      return const LinearProgressIndicator();
    }
    if (state.districtsStatus == LoadStatus.failure) {
      return Row(
        children: [
          Expanded(child: Text(state.error ?? 'تعذّر تحميل الأحياء')),
          TextButton(
            onPressed: () => context.read<ProfileCubit>().loadDistricts(),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      );
    }
    return DropdownButtonFormField<DistrictModel>(
      value: _district,
      isExpanded: true,
      decoration: _dec('الحي (اختياري)', Icons.location_city_outlined),
      items: [
        for (final district in state.districts)
          DropdownMenuItem(value: district, child: Text(district.nameAr)),
      ],
      onChanged: (district) => setState(() => _district = district),
    );
  }

  Widget _sectionTitle(String text) => Text(text, style: _titleStyle(15));

  TextStyle _titleStyle(double size, {Color color = AppColors.onSurface}) =>
      TextStyle(
        fontFamily: 'Cairo',
        fontSize: size.sp,
        fontWeight: FontWeight.bold,
        color: color,
      );

  TextStyle _bodyStyle(double size) => TextStyle(
    fontFamily: 'Cairo',
    fontSize: size.sp,
    color: AppColors.grey600,
  );

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
  );
}
