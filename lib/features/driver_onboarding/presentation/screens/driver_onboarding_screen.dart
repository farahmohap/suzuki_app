import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../profile/data/models/profile_models.dart';
import '../../data/models/onboarding_models.dart';
import '../cubit/driver_onboarding_cubit.dart';
import '../widgets/document_tile.dart';

/// Driver registration wizard: 1) personal  2) vehicle  3) documents.
/// Large controls and short Arabic text (low smartphone-literacy risk).
class DriverOnboardingScreen extends StatelessWidget {
  const DriverOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DriverOnboardingCubit>()..init(),
      child: const _WizardView(),
    );
  }
}

class _WizardView extends StatefulWidget {
  const _WizardView();

  @override
  State<_WizardView> createState() => _WizardViewState();
}

class _WizardViewState extends State<_WizardView> {
  final _personalKey = GlobalKey<FormState>();
  final _vehicleKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _nationalId = TextEditingController();
  final _plateNumbers = TextEditingController();
  final _plateLetters = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _color = TextEditingController();

  DateTime? _birthDate;
  DistrictModel? _district;

  @override
  void dispose() {
    for (final c in [
      _name,
      _nationalId,
      _plateNumbers,
      _plateLetters,
      _model,
      _year,
      _color,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static const _titles = [
    'البيانات الشخصية',
    'بيانات السيارة',
    'المستندات والصور',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverOnboardingCubit, OnboardingState>(
      listenWhen: (a, b) => a.error != b.error || a.submitted != b.submitted,
      listener: (context, state) {
        if (state.submitted) {
          // Status becomes "pending"; router moves the driver to the status page.
          context.read<AuthCubit>().refreshUser();
        } else if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: state.step > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: context.read<DriverOnboardingCubit>().back,
                  )
                : null,
            title: Text(
              'تسجيل كابتن جديد',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.read<AuthCubit>().logout(),
                child: const Text('خروج'),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الخطوة ${state.step + 1} من 3 — ${_titles[state.step]}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (state.step + 1) / 3,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  // IndexedStack keeps each step's form values when going back.
                  child: IndexedStack(
                    index: state.step,
                    children: [
                      _personalStep(context, state),
                      _vehicleStep(context, state),
                      _documentsStep(context, state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Step 1 ────────────────────────────────────────────────────────────────
  Widget _personalStep(BuildContext context, OnboardingState state) {
    final cubit = context.read<DriverOnboardingCubit>();
    return Form(
      key: _personalKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: () async {
                final f = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                  maxWidth: 1024,
                  preferredCameraDevice: CameraDevice.front,
                );
                if (f != null) cubit.setAvatar(f.path);
              },
              child: CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: state.avatarPath != null
                    ? FileImage(File(state.avatarPath!))
                    : null,
                child: state.avatarPath == null
                    ? const Icon(
                        Icons.add_a_photo,
                        size: 36,
                        color: AppColors.primary,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(child: Text('صورتك الشخصية')),
          const SizedBox(height: 16),
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
            validator: AppValidators.nationalId,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: FormField<DateTime>(
              validator: (_) =>
                  _birthDate == null ? 'تاريخ الميلاد مطلوب' : null,
              builder: (field) => InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime(now.year - 30),
                    firstDate: DateTime(now.year - 80),
                    lastDate: DateTime(now.year - 18, now.month, now.day),
                  );
                  if (d != null) {
                    setState(() => _birthDate = d);
                    field.didChange(d);
                  }
                },
                child: InputDecorator(
                  decoration: _dec(
                    'تاريخ الميلاد',
                    Icons.cake_outlined,
                  ).copyWith(errorText: field.errorText),
                  child: Text(
                    _birthDate == null
                        ? 'اختر التاريخ'
                        : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                  ),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 14),
          //   child: DropdownButtonFormField<DistrictModel>(
          //     value: _district,
          //     isExpanded: true,
          //     decoration: _dec(
          //       'الحي الذي تسكن فيه',
          //       Icons.location_city_outlined,
          //     ),
          //     items: [
          //       for (final d in state.districts)
          //         DropdownMenuItem(value: d, child: Text(d.nameAr)),
          //     ],
          //     onChanged: (d) => setState(() => _district = d),
          //     // validator: (d) => d == null ? 'اختر الحي' : null,
          //   ),
          // ),
          _bigButton(
            label: 'التالي',
            busy: state.busy,
            onPressed: () {
              if (!(_personalKey.currentState?.validate() ?? false)) return;
              cubit.savePersonal(
                fullName: _name.text.trim(),
                nationalId: AppValidators.toAsciiDigits(
                  _nationalId.text,
                ).trim(),
                birthDate: _birthDate!,
                //change
                districtId: "0",
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Step 2 ────────────────────────────────────────────────────────────────
  Widget _vehicleStep(BuildContext context, OnboardingState state) {
    final cubit = context.read<DriverOnboardingCubit>();
    return Form(
      key: _vehicleKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'لوحة السوزوكي (أجرة)',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _field(
                  _plateLetters,
                  'الحروف (مثال: ق ن ص)',
                  null,
                  validator: AppValidators.plateLetters,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: _field(
                    _plateNumbers,
                    'الأرقام (مثال: 2845)',
                    null,
                    keyboard: TextInputType.number,
                    validator: AppValidators.plateNumbers,
                  ),
                ),
              ),
            ],
          ),
          _field(
            _model,
            'الموديل (مثال: سوزوكي إيفري)',
            Icons.directions_car_outlined,
            validator: (v) => AppValidators.required(v, label: 'الموديل'),
          ),
          Row(
            children: [
              Expanded(
                child: _field(
                  _year,
                  'سنة الصنع',
                  Icons.event,
                  keyboard: TextInputType.number,
                  validator: (v) {
                    final y = int.tryParse(
                      AppValidators.toAsciiDigits(v ?? '').trim(),
                    );
                    if (y == null || y < 1990 || y > DateTime.now().year + 1) {
                      return 'سنة غير صحيحة';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  _color,
                  'اللون',
                  Icons.palette_outlined,
                  validator: (v) => AppValidators.required(v, label: 'اللون'),
                ),
              ),
            ],
          ),
          const Text(
            'عدد المقاعد: 7 (ثابت) — سيتم فحص السيارة في موقف العبور قبل التفعيل.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          _bigButton(
            label: 'التالي',
            busy: state.busy,
            onPressed: () {
              if (!(_vehicleKey.currentState?.validate() ?? false)) return;
              cubit.saveVehicle(
                VehicleInput(
                  plateNumbers: AppValidators.toAsciiDigits(
                    _plateNumbers.text,
                  ).trim(),
                  plateLetters: _plateLetters.text.trim(),
                  model: _model.text.trim(),
                  year: int.parse(
                    AppValidators.toAsciiDigits(_year.text).trim(),
                  ),
                  color: _color.text.trim(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Step 3 ────────────────────────────────────────────────────────────────
  Widget _documentsStep(BuildContext context, OnboardingState state) {
    final cubit = context.read<DriverOnboardingCubit>();
    const icons = {
      DocType.nationalIdFront: Icons.credit_card,
      DocType.nationalIdBack: Icons.credit_card,
      DocType.drivingLicense: Icons.contact_emergency,
      DocType.vehicleLicense: Icons.description_outlined,
      DocType.criminalRecord: Icons.verified_user_outlined,
      DocType.vanFront: Icons.directions_car,
      DocType.vanRear: Icons.directions_car,
      DocType.vanInterior: Icons.airline_seat_recline_normal,
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final t in DocType.values)
          DocumentTile(
            label: t.labelAr,
            icon: icons[t]!,
            slot: state.slot(t),
            onPicked: (path) => cubit.uploadDocument(t, path),
            onRemove: () => cubit.removeDocument(t),
          ),
        const SizedBox(height: 8),
        _bigButton(
          label: 'إرسال الطلب',
          busy: state.busy,
          onPressed: (state.allDocsUploaded && !state.anyUploading)
              ? () => _confirmSubmit(context, cubit)
              : null,
        ),
      ],
    );
  }

  Future<void> _confirmSubmit(
    BuildContext context,
    DriverOnboardingCubit cubit,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إرسال الطلب؟'),
        content: const Text(
          'بعد الإرسال سنراجع مستنداتك. ستحتاج لإحضار السيارة لموقف العبور للفحص.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
    if (ok == true) cubit.submit();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _field(
    TextEditingController c,
    String label,
    IconData? icon, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: c,
      keyboardType: keyboard,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 16),
      decoration: _dec(label, icon),
      validator: validator,
    ),
  );

  InputDecoration _dec(String label, IconData? icon) => InputDecoration(
    labelText: label,
    prefixIcon: icon == null ? null : Icon(icon),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );

  Widget _bigButton({
    required String label,
    required bool busy,
    required VoidCallback? onPressed,
  }) => ElevatedButton(
    onPressed: busy ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 58),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    child: busy
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
  );
}
