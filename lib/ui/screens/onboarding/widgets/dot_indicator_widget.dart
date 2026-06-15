import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import '../../../../core/core_constants/colors.dart';

class DotIndicatorWidget extends StatelessWidget {
  const DotIndicatorWidget({super.key, required this.page, required this.dotCount});

  final int page;
  final int dotCount;

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: dotCount == 0 ? 1 : dotCount,
      position: page.toDouble(),
      mainAxisAlignment: MainAxisAlignment.center,
      decorator: DotsDecorator(
          color: AppColors.white,
          size: Size.square(8.0),
          activeSize: Size(18.0, 8),
          activeColor: AppColors.primaryColor,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          )),
    );
  }
}
