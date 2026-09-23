import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/screen_util_helper.dart';

/// Branded circular loading indicator.
///
/// Use [LoadingIndicator.overlay] inside a [Stack] to show a full-screen
/// translucent overlay.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 3.0,
  });

  final double? size;
  final Color? color;
  final double strokeWidth;

  /// Full-screen translucent overlay — use inside a [Stack].
  static Widget overlay({String? message}) {
    return ColoredBox(
      color: Colors.black26,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoadingIndicator(),
              if (message != null) ...[
                SizedBox(height: AppSpacing.md),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = size ?? 40.w;
    return SizedBox(
      width: s,
      height: s,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}
