import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/screen_util_helper.dart';
import 'custom_button.dart';

/// Reusable error state widget with icon, title, message, and retry button.
///
/// ```dart
/// ErrorView(
///   message: failure.message,
///   onRetry: () => context.read<MyCubit>().load(),
/// )
/// ```
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'إعادة المحاولة',
    this.icon = Icons.error_outline_rounded,
    this.iconColor,
  });

  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72.w,
              color: iconColor ?? AppColors.error.withOpacity(0.7),
            ),
            SizedBox(height: AppSpacing.lg),
            if (title != null) ...[
              Text(
                title!,
                style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
            ],
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.xl),
              CustomButton(
                label: retryLabel,
                onPressed: onRetry,
                variant: ButtonVariant.outline,
                width: 180.w,
                prefixIcon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lightweight empty-state widget.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.title = 'لا توجد بيانات',
    this.message,
    this.onAction,
    this.actionLabel,
  });

  final String title;
  final String? message;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 72.w,
              color: AppColors.grey400,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: AppSpacing.xl),
              CustomButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 200.w,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
