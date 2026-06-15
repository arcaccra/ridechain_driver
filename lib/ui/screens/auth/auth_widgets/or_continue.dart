import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/label.dart';
import '../../../../app/theme.dart';

class OrContinue extends StatelessWidget {
  const OrContinue({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textFieldHintColor,
            thickness: 1,
          ),),
        Gap(4),
        Text(
          Label.loginContinueLabel,
          style: AppThemes.getCustomTextStyle(
            fontFamily: "Inter",
            weight: FontWeight.w400,
            color: AppColors.textFieldHintColor,
            fontSize: 14,
            lineHeight: 1.33,
          ),
        ),
        Gap(4),
        Expanded(
          child: Divider(
            color: AppColors.textFieldHintColor,
            thickness: 1,
          ),),
      ],
    );
  }
}
