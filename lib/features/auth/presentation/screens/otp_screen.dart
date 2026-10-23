import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/auth_model.dart';
import '../cubit/auth_cubit.dart';

/// Step 2 of login: 6-digit SMS code. On success the router redirect moves
/// the user to the right place (profile setup / onboarding / home).
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isDriver = false,
  });

  /// Normalized `+201XXXXXXXXX`.
  final String phoneNumber;
  final bool isDriver;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _length = 6;
  static const _resendSeconds = 60;

  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _verify() async {
    if (_busy) return;
    final code = AppValidators.toAsciiDigits(_controller.text).trim();
    final err = AppValidators.otp(code);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final message = await context
        .read<AuthCubit>()
        .verifyOtp(phone: widget.phoneNumber, code: code);
    if (!mounted) return;
    // On success the router redirects away from this screen.
    setState(() {
      _busy = false;
      _error = message;
    });
    if (message != null) _controller.clear();
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _busy) return;
    final message = await context.read<AuthCubit>().requestOtp(
          phone: widget.phoneNumber,
          role: widget.isDriver ? UserRole.driver : UserRole.passenger,
        );
    if (!mounted) return;
    if (message == null) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال رمز جديد')),
      );
    } else {
      setState(() => _error = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'التحقق من رقم الموبايل',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: 6.h),
            Text.rich(
              TextSpan(
                text: 'أرسلنا رمزًا من $_length أرقام إلى ',
                children: [
                  TextSpan(
                    // Phone numbers stay LTR inside RTL text.
                    text: '\u202A${widget.phoneNumber}\u202C',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                color: AppColors.grey600,
              ),
            ),
            SizedBox(height: 28.h),
            // One real field (autofill / paste friendly) + 6 display boxes.
            GestureDetector(
              onTap: _focus.requestFocus,
              child: Stack(
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_length, (i) {
                        final filled = i < text.length;
                        final active = i == text.length && _focus.hasFocus;
                        return Container(
                          width: 46.w,
                          height: 56.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: _error != null
                                  ? AppColors.error
                                  : (active
                                      ? AppColors.primary
                                      : AppColors.grey600.withOpacity(0.3)),
                              width: active ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            filled ? text[i] : '',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        maxLength: _length,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                        ],
                        onChanged: (v) {
                          setState(() => _error = null);
                          if (v.length == _length) _verify();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              SizedBox(height: 10.h),
              Text(
                _error!,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: AppColors.error,
                ),
              ),
            ],
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _busy ? null : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.stitchCobalt,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 52.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'تأكيد الدخول',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: _secondsLeft == 0 ? _resend : null,
              child: Text(
                _secondsLeft == 0
                    ? 'إعادة إرسال الرمز'
                    : 'إعادة الإرسال خلال $_secondsLeft ثانية',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
