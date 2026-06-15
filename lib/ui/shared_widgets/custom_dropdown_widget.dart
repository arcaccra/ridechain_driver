
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/core_constants/colors.dart';

class CustomDropdown extends StatefulWidget {
  /// List of items to display in the dropdown
  final List<String> items;

  /// Currently selected value
  final String? value;

  /// Callback when value changes
  final void Function(String?)? onChanged;

  /// Hint text displayed when no value is selected
  final String? hintText;

  /// Label text for the dropdown
  final String? labelText;

  /// Custom font family
  final String? fontFamily;

  /// Font size for text
  final double? fontSize;

  /// Border radius for the dropdown
  final double? borderRadius;

  /// Border color
  final Color? borderRadiusColor;

  /// Prefix icon widget
  final Widget? prefixIcon;

  /// Suffix icon widget (overrides default dropdown arrow)
  final Widget? suffixIcon;

  /// Whether the dropdown is enabled
  final bool enabled;

  /// Focus node for the dropdown
  final FocusNode? focusNode;

  /// Validator function
  final String? Function(String?)? validator;

  /// Auto validate mode
  final AutovalidateMode? autovalidateMode;

  /// Whether to use default validation (required field)
  final bool defaultValidation;

  /// Whether to show search functionality (for large lists)
  final bool searchable;

  /// Custom dropdown icon
  final Widget? dropdownIcon;

  const CustomDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hintText,
    this.labelText,
    this.fontFamily,
    this.fontSize,
    this.borderRadius,
    this.borderRadiusColor,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.focusNode,
    this.validator,
    this.autovalidateMode,
    this.defaultValidation = true,
    this.searchable = false,
    this.dropdownIcon,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    // Only dispose if we created the focus node
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(
        color: widget.borderRadiusColor ?? AppColors.textFieldBorderColor,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.r),
    );

    final textStyle = TextStyle(
      fontSize: widget.fontSize ?? 14.sp,
      fontFamily: widget.fontFamily ?? "Inter",
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.48,
      height: 1.2,
    );

    return DropdownButtonFormField<String>(
      value: widget.value,
      items: widget.items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: textStyle,
          ),
        );
      }).toList(),
      onChanged: widget.enabled ? widget.onChanged : null,
      focusNode: _focusNode,
      icon: widget.dropdownIcon ??
          Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.primaryColor,
            size: 24.sp,
          ),
      iconSize: 24.sp,
      isExpanded: true,
      style: textStyle,
      dropdownColor: AppColors.white,
      autovalidateMode: widget.autovalidateMode,
      decoration: InputDecoration(
        border: border,
        filled: true,
        fillColor: AppColors.white,
        enabledBorder: border,
        focusedBorder: border,
        disabledBorder: border,
        errorBorder: border,
        focusedErrorBorder: border,
        hintText: widget.hintText,
        labelText: widget.labelText,
        errorStyle: TextStyle(
          fontSize: widget.fontSize ?? 14.sp,
          fontFamily: widget.fontFamily ?? "Inter",
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.48,
          height: 1.2,
        ),
        labelStyle: TextStyle(
          fontSize: widget.fontSize ?? 14.sp,
          fontFamily: widget.fontFamily ?? "Inter",
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.48,
          height: 1.2,
        ),
        hintStyle: TextStyle(
          fontSize: widget.fontSize ?? 14.sp,
          fontFamily: widget.fontFamily ?? "Inter",
          color: AppColors.textFieldHintColor,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.48,
          height: 1.2,
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
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

