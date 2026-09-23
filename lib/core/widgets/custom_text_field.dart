import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/screen_util_helper.dart';

/// RTL-ready custom text field with label, hint, validation, and icons.
///
/// ```dart
/// CustomTextField(
///   label: 'رقم الجوال',
///   hint: '05xxxxxxxx',
///   prefixIcon: Icons.phone,
///   validator: AppValidators.phone,
///   keyboardType: TextInputType.phone,
///   controller: _phoneController,
/// )
/// ```
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.isPassword = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.initialValue,
    this.focusNode,
    this.autofillHints,
    this.textAlign = TextAlign.start,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool isPassword;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final String? initialValue;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final TextAlign textAlign;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.isPassword && _obscure,
      enabled: widget.enabled,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      focusNode: widget.focusNode,
      autofillHints: widget.autofillHints,
      textAlign: widget.textAlign,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20.sp, color: AppColors.grey600)
            : null,
        suffixIcon: _buildSuffixIcon(),
        counterText: '',
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20.sp,
          color: AppColors.grey600,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon, size: 20.sp, color: AppColors.grey600),
        onPressed: widget.onSuffixTap,
      );
    }
    return null;
  }
}
