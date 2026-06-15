import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/label.dart';


class DriverInfoUpdate extends StatelessWidget {
  final VoidCallback? updateDriver;
  const DriverInfoUpdate({super.key, this.updateDriver});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: updateDriver,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(21),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.11),
                spreadRadius: 0,
                blurRadius: 13.4,
                offset: Offset(0, 3.27),)
            ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Label.incompleteDriverInformation, style: AppThemes.getCustomTextStyle(fontSize: 16, color: AppColors.white, weight: FontWeight.w700, lineHeight: 1.4)),
            Gap(2),
            Text(Label.incompleteInfoMsg, style: AppThemes.getCustomTextStyle(fontSize: 12, color: AppColors.white, weight: FontWeight.w400, lineHeight: 1.4)),
          ],
        ),
      ),
    );
  }
}
