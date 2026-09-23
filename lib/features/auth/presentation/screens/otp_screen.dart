import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/screen_util_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// 6-digit OTP verification screen with countdown timer and resend.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 120; // 2 minutes

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 120);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onVerify() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().verifyOtp(
            phone: widget.phone,
            otp: _otpController.text.trim(),
          );
    }
  }

  void _onResend() {
    if (_secondsLeft == 0) {
      context.read<AuthCubit>().resendOtp(phone: widget.phone);
      _startTimer();
    }
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      final route =
          state.user.isDriver ? '/driver/dashboard' : '/passenger/home';
      context.go(route);
    } else if (state is AuthOtpResent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إعادة إرسال رمز التحقق'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthState,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.otp),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: AppSpacing.vxl),
                      _buildHeader(),
                      SizedBox(height: AppSpacing.vxl),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _otpController,
                          validator: AppValidators.otp,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          style: AppTextStyles.headlineMedium
                              .copyWith(letterSpacing: 12),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '------',
                            hintStyle: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.grey300,
                              letterSpacing: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.vxl),
                      CustomButton(
                        label: AppStrings.verifyOtp,
                        onPressed: isLoading ? null : _onVerify,
                        isLoading: isLoading,
                      ),
                      SizedBox(height: AppSpacing.vlg),
                      _buildResendRow(),
                    ],
                  ),
                ),
                if (isLoading)
                  Positioned.fill(child: LoadingIndicator.overlay()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.sms_outlined,
          size: 64.sp,
          color: AppColors.primary,
        ),
        SizedBox(height: AppSpacing.vlg),
        Text(
          AppStrings.otpSent,
          style: AppTextStyles.titleMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.vsm),
        Text(
          widget.phone,
          style: AppTextStyles.titleLarge
              .copyWith(color: AppColors.primary, letterSpacing: 2),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResendRow() {
    final canResend = _secondsLeft == 0;
    return Column(
      children: [
        if (!canResend)
          Text(
            '${AppStrings.otpCountdown} ${DateFormatter.countdown(_secondsLeft)}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
          ),
        TextButton(
          onPressed: canResend ? _onResend : null,
          child: Text(
            AppStrings.otpResend,
            style: AppTextStyles.labelLarge.copyWith(
              color: canResend ? AppColors.primary : AppColors.grey400,
            ),
          ),
        ),
      ],
    );
  }
}

extension on AppColors {
  static const Color grey300 = Color(0xFFE0E0E0);
}
