import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

/// Registration screen with role selection (Passenger / Driver).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String _selectedRole = 'passenger';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().register(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            role: _selectedRole,
          );
    }
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (state is AuthOtpSent) {
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
        appBar: AppBar(
          title: const Text(AppStrings.register),
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
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.vmd,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: AppSpacing.vmd),
                        _buildRoleSelector(),
                        SizedBox(height: AppSpacing.vxl),
                        CustomTextField(
                          label: AppStrings.fullName,
                          controller: _nameController,
                          validator: AppValidators.fullName,
                          prefixIcon: Icons.person_outlined,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: AppSpacing.vmd),
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
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: AppSpacing.vmd),
                        CustomTextField(
                          label: AppStrings.confirmPassword,
                          controller: _confirmController,
                          validator: AppValidators.confirmPassword(
                              _passwordController.text),
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _onRegister(),
                        ),
                        SizedBox(height: AppSpacing.vxl),
                        CustomButton(
                          label: AppStrings.register,
                          onPressed: isLoading ? null : _onRegister,
                          isLoading: isLoading,
                        ),
                        SizedBox(height: AppSpacing.vlg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppStrings.haveAccount,
                                style: AppTextStyles.bodyMedium),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: Text(AppStrings.login,
                                  style: AppTextStyles.labelLarge
                                      .copyWith(color: AppColors.primary)),
                            ),
                          ],
                        ),
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
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.selectRole, style: AppTextStyles.titleSmall),
        SizedBox(height: AppSpacing.vsm),
        Row(
          children: [
            _RoleChip(
              label: AppStrings.passenger,
              icon: Icons.person_outlined,
              isSelected: _selectedRole == 'passenger',
              onTap: () => setState(() => _selectedRole = 'passenger'),
            ),
            SizedBox(width: AppSpacing.sm),
            _RoleChip(
              label: AppStrings.driver,
              icon: Icons.drive_eta_outlined,
              isSelected: _selectedRole == 'driver',
              onTap: () => setState(() => _selectedRole = 'driver'),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
              vertical: AppSpacing.md, horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.grey200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.grey600,
                size: 20.sp,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.grey600,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
