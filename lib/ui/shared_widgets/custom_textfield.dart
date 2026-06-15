import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/core_constants/colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool expandable;
  final VoidCallback? onTap;
  final String? hintText;
  final String? fontFamily;
  final Widget? suffixIcon;
  final Widget? prefix;
  final String? labelText;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final double? borderRadius;
  final double? fontSize;
  final Color? borderRadiusColor;
  final int minLines;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChanged;
  final Function()? onEditingComplete;
  final bool defaultValidation;

  const CustomTextField({
    super.key,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.expandable = false,
    this.onTap,
    this.onEditingComplete,
    this.autovalidateMode,
    this.hintText,
    this.labelText,
    this.focusNode,
    this.onChanged,
    this.minLines = 1,
    this.suffixIcon,
    this.fontSize,
    this.fontFamily,
    this.borderRadius,
    this.borderRadiusColor,
    this.prefix,
    this.prefixIcon,
    this.inputFormatters,
    this.validator,
    this.defaultValidation = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: widget.borderRadiusColor ?? AppColors.textFieldBorderColor, width: 1),
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.r),
    );

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.expandable ? 5 : 1,
      minLines: widget.expandable ? 5 : 1,
      onTap: widget.onTap,
      style: TextStyle(
        fontSize: widget.fontSize ?? 16,
        fontFamily: widget.fontFamily ?? "Inter",
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.48,
        height: 1.2,
      ),
      cursorColor: AppColors.primaryColor,
      onTapOutside: (_) => _focusNode.unfocus(),
      onEditingComplete: widget.onEditingComplete,
      onChanged: widget.onChanged,
      autovalidateMode: widget.autovalidateMode,
      decoration: InputDecoration(
        border: border,
        filled: true,
        fillColor: AppColors.white,
        enabledBorder: border,
        focusedBorder: border,
        disabledBorder: border,
        hintText: widget.hintText,
        labelText: widget.labelText,
        errorBorder: border,
        errorStyle: TextStyle(
          fontSize: widget.fontSize ?? 16,
          fontFamily:  widget.fontFamily ?? "Inter",
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.48,
          height: 1.2,
        ),
        labelStyle: TextStyle(
          fontSize: widget.fontSize ?? 16,
          fontFamily:  widget.fontFamily ?? "Inter",
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.48,
          height: 1.2,
        ),
        suffixIcon: widget.suffixIcon,
        hintStyle: TextStyle(
          fontSize: widget.fontSize ?? 16,
          fontFamily:  widget.fontFamily ?? "Inter",
          color: AppColors.textFieldHintColor,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.48,
          height: 1.2,
        ),
        prefix: widget.prefix,
        prefixIcon: widget.prefixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      inputFormatters: widget.inputFormatters,
      validator: widget.defaultValidation
          ? (value) {
        if (value == null || value.isEmpty) {
          return 'Required Field';
        }
        return widget.validator?.call(value);
      }
          : widget.validator,
    );
  }
}