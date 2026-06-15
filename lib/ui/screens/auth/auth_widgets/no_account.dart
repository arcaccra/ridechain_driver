import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../app/theme.dart';

class NoAccount extends StatelessWidget {
  const NoAccount({super.key, required this.title, required this.actionTitle, required this.onPressed});

  final String title;
  final String actionTitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: title,
            style: AppThemes.getCustomTextStyle(
              color: AppColors.primaryColor,
              weight: FontWeight.w400,
              fontSize: 12
            )
          ),
          TextSpan(
              text: actionTitle,
              style: AppThemes.getCustomTextStyle(
                color: AppColors.primaryColor,
                weight: FontWeight.w700,
                fontSize: 12
              ),
              recognizer: TapGestureRecognizer()..onTap = onPressed
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
