import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ridechain_driiver/ui/shared_widgets/default_back_button.dart';

import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';

class ScanningWidget extends StatelessWidget {
  final MobileScannerController mobileScannerController;
  final Function(BarcodeCapture) onCapture;
  const ScanningWidget({super.key, required this.onCapture, required this.mobileScannerController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(39.r), topRight: Radius.circular(39.r))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap(0.02.sh),
          Align(alignment: Alignment.centerRight, child: DefaultBackButton(icon: Icons.clear, onBackTap: () => Navigator.pop(context), iconColor: AppColors.black,)),
          Gap(0.03.sh),
          Text(
              "Scan the qr-code to copy the wallet address.",
            style: AppThemes.getCustomTextStyle(fontFamily: "Zain", weight: FontWeight.w700, color: AppColors.primaryColor, fontSize: 20, lineHeight: 1.33),
            textAlign: TextAlign.center,
          )
              .animate(delay: 100.ms)
              .slide(
            begin: const Offset(0, -0.3),
            end: const Offset(0, 0), // End at center
            duration: 600.ms,
            curve: Curves.easeOutBack,
          )
              .fade(begin: 0, end: 1, duration: 600.ms),
          Gap(0.02.sh),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.backgroundColor, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                height: 0.4.sh,
                width: 0.4.sh,
                child: MobileScanner(
                    controller: mobileScannerController,
                    onDetect: onCapture
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
