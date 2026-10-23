import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/profile_models.dart';
import '../cubit/profile_cubit.dart';

/// Passenger registration, step 2 (after OTP): name, gender, age, district,
/// address and a map pin inside Obour City.
class PassengerProfileSetupScreen extends StatelessWidget {
  const PassengerProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadDistricts(),
      child: const _SetupView(),
    );
  }
}

class _SetupView extends StatefulWidget {
  const _SetupView();

  @override
  State<_SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<_SetupView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _address = TextEditingController();

  Gender _gender = Gender.male;
  DistrictModel? _district;
  LatLng? _pin;
  bool _acceptTerms = false;
  String? _pinError;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _address.dispose();
    super.dispose();
  }

  void _submit() {
    final formOk = _formKey.currentState?.validate() ?? false;
    String? pinError;
    if (_pin == null) {
      pinError = 'حدد موقعك على الخريطة';
    } else if (!AppConfig.isInsideObourHint(_pin!.latitude, _pin!.longitude)) {
      pinError = 'الخدمة متاحة داخل مدينة العبور فقط';
    }
    setState(() => _pinError = pinError);
    if (!formOk || pinError != null || _district == null) return;

    context.read<ProfileCubit>().savePassengerProfile(
      PassengerProfileInput(
        fullName: _name.text.trim(),
        gender: _gender,
        age: int.parse(AppValidators.toAsciiDigits(_age.text).trim()),
        districtId: _district!.id,
        addressText: _address.text.trim(),
        latitude: _pin!.latitude,
        longitude: _pin!.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (a, b) => a.saveStatus != b.saveStatus,
      listener: (context, state) {
        if (state.saveStatus == LoadStatus.success && state.savedUser != null) {
          // Router redirect sends the passenger to Home once the user updates.
          context.read<AuthCubit>().updateUser(state.savedUser!);
        } else if (state.saveStatus == LoadStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? 'تعذّر حفظ البيانات')),
          );
        }
      },
      builder: (context, state) {
        final saving = state.saveStatus == LoadStatus.loading;
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'أكمل بياناتك',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: AppColors.onSurface,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                //context.read<AuthCubit>().logout(),
                child: const Text('خروج'),
              ),
            ],
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.r),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: _dec(
                      'الاسم بالكامل',
                      Icons.badge_outlined,
                      state.fieldErrors['full_name'],
                    ),
                    validator: AppValidators.fullName,
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: _dec(
                            'السن',
                            Icons.cake_outlined,
                            state.fieldErrors['birth_year'],
                          ),
                          validator: AppValidators.age,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: SegmentedButton<Gender>(
                          showSelectedIcon: false,
                          segments: [
                            for (final g in Gender.values)
                              ButtonSegment(value: g, label: Text(g.labelAr)),
                          ],
                          selected: {_gender},
                          onSelectionChanged: (s) =>
                              setState(() => _gender = s.first),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  _districtField(state),
                  SizedBox(height: 14.h),
                  TextFormField(
                    controller: _address,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: _dec(
                      'العنوان بالتفصيل',
                      Icons.home_outlined,
                      state.fieldErrors['address_text'],
                    ),
                    validator: AppValidators.minLength(5, label: 'العنوان'),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'حدد موقعك على الخريطة (اضغط لوضع الدبوس)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: SizedBox(height: 220.h, child: _map()),
                  ),
                  if (_pinError != null)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        _pinError!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  SizedBox(height: 12.h),
                  CheckboxListTile(
                    value: _acceptTerms,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                    title: Text(
                      'أوافق على شروط الاستخدام وقواعد الركوب الآمن',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: (_acceptTerms && !saving) ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      minimumSize: Size(double.infinity, 54.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'إنشاء الحساب',
                            style: TextStyle(
                              fontFamily: 'Cairo',
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
      },
    );
  }

  Widget _districtField(ProfileState state) {
    if (state.districtsStatus == LoadStatus.loading ||
        state.districtsStatus == LoadStatus.initial) {
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
      decoration: _dec(
        'الحي',
        Icons.location_city_outlined,
        state.fieldErrors['district_id'],
      ),
      items: [
        for (final d in state.districts)
          DropdownMenuItem(value: d, child: Text(d.nameAr)),
      ],
      onChanged: (d) => setState(() => _district = d),
      validator: (d) => d == null ? 'اختر الحي' : null,
    );
  }

  Widget _map() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(
          AppConfig.obourCenterLat,
          AppConfig.obourCenterLng,
        ),
        initialZoom: 13,
        onTap: (_, point) => setState(() {
          _pin = point;
          _pinError = null;
        }),
      ),
      children: [
        TileLayer(
          urlTemplate: AppConfig.osmTileUrl,
          userAgentPackageName: 'com.suzuki.app',
        ),
        if (_pin != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _pin!,
                width: 44,
                height: 44,
                child: const Icon(
                  Icons.location_pin,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  InputDecoration _dec(String label, IconData icon, String? serverError) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        errorText: serverError,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
      );
}
