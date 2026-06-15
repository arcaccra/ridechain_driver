import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../app/theme.dart';

class OtpFields extends StatelessWidget {
  const OtpFields({super.key, required this.otpCtrl});

  final TextEditingController otpCtrl;

  @override
  Widget build(BuildContext context) {
    final shadow = BoxShadow(
      color: Colors.black.withValues(alpha: .15),
      blurRadius: 7,
      offset: const Offset(0, 1),
    );
    return PinCodeTextField(
      appContext: context,
      length: 6,
      keyboardType: TextInputType.number,
      controller: otpCtrl,
      autoFocus: true,
      textStyle: AppThemes.getCustomTextStyle(
        fontFamily: "Zain",
        weight: FontWeight.w700,
        color: AppColors.primaryColor,
        fontSize: 16,
        lineHeight: 1.33,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 50,
        fieldWidth: 48,
        activeFillColor: Colors.white,
        selectedFillColor: Colors.white,
        inactiveFillColor: Colors.white,
        activeColor: Colors.white,
        selectedColor: Colors.white,
        inactiveColor: Colors.white,
        activeBoxShadow: [shadow],
        disabledColor: Colors.white,
        inActiveBoxShadow: [shadow],
      ),
      enableActiveFill: true,
      onCompleted: (v) {
        debugPrint("OTP input Completed with $v");
      },
      beforeTextPaste: (text) => true,
    ).animate()
        .slide(
      begin: const Offset(0, 0.3),
      end: const Offset(0, 0), // End at center
      duration: 600.ms,
      curve: Curves.easeOutBack,
    )
        .fade(begin: 0, end: 1, duration: 500.ms);
  }
}