import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ridechain_driiver/app/theme.dart';

import '../../../../core/core_constants/colors.dart';

class TopDriverDocumentContainer extends StatelessWidget {
  const TopDriverDocumentContainer({super.key, required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Driver's \nDocument", style: AppThemes.sora(fontWeight: FontWeight.w800, fontSize: 28.5, color: AppColors.primaryColor),),
            SizedBox(
              height: 56,
              width: 56,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
                value: progress,
                backgroundColor: AppColors.lightPurpleD9,
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
              ),
            )
          ],
        ),
        Gap(16.h),
        Text("Driver's \nDocument", style: AppThemes.getCustomTextStyle(weight: FontWeight.w400, fontSize: 20, color: AppColors.greyAd),),
      ],
    );
  }
}
