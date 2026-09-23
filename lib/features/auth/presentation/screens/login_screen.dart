import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/screen_util_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Login screen supporting both Passenger and Driver roles.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      final route =
          state.user.isDriver ? '/driver/dashboard' : '/passenger/home';
      context.go(route);
    } else if (state is AuthOtpSent) {
      context.pushNamed(
        AppRoute.otp.name,
        queryParameters: {'phone': state.phone},
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
        body: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.vxl,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: AppSpacing.vxxl),
                          _buildHeader(),
                          SizedBox(height: AppSpacing.vxxl),
                          CustomTextField(
                            label: AppStrings.phone,
                            hint: '05xxxxxxxx',
                            controller: _phoneController,
                            validator: AppValidators.phone,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: AppSpacing.vmd),
                          CustomTextField(
                            label: AppStrings.password,
                            controller: _passwordController,
                            validator: AppValidators.password,
                            isPassword: true,
                            prefixIcon: Icons.lock_outlined,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onLogin(),
                          ),
                          SizedBox(height: AppSpacing.vxl),
                          CustomButton(
                            label: AppStrings.login,
                            onPressed: isLoading ? null : _onLogin,
                            isLoading: isLoading,
                          ),
                          SizedBox(height: AppSpacing.vlg),
                          _buildRegisterLink(),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading)
                    Positioned.fill(child: LoadingIndicator.overlay()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_car_rounded,
            color: AppColors.onPrimary,
            size: 40.sp,
          ),
        ),
        SizedBox(height: AppSpacing.vlg),
        Text(
          AppStrings.appName,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.vsm),
        Text(
          AppStrings.appTagline,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.noAccount, style: AppTextStyles.bodyMedium),
        TextButton(
          onPressed: () => context.pushNamed(AppRoute.register.name),
          child: Text(
            AppStrings.register,
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
