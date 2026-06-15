import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';


class DocumentRequirementWidget extends StatelessWidget {
  final String title;
  const DocumentRequirementWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: AppColors.purple,),
          Gap(6.w),
          Text(
            title,
            style: AppThemes.getCustomTextStyle(fontSize: 12, weight: FontWeight.w400, color: AppColors.greyAd),
          ),
        ],
      ),
    );
  }
}
