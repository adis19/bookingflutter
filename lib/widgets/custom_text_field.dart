import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? hintText;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          borderSide: const BorderSide(color: AppConstants.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          borderSide: const BorderSide(color: AppConstants.errorColor),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
      ),
    );
  }
} 