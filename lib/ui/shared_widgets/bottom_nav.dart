import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/core_constants/colors.dart';
import '../../services/nav_service.dart';

class BottomNav extends StatelessWidget {
  final int? currentIndex;
  final void Function(int)? getCurrentIndex;
  const BottomNav({super.key, this.currentIndex, this.getCurrentIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 68.h,
      child: ClipRect(
        child: Container(
          height: 99.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.11),
                spreadRadius: 0,
                blurRadius: 19.9,
                offset: Offset(0, -8),
              )
            ]
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
              var navigatorItem =
              NavService.navigationItems(isSelected: currentIndex == index, userImage: null)[index];
              return GestureDetector(
                onTap: () {
                  getCurrentIndex!(index);
                },
                child: navigatorItem,
              );
            }),
          ),
        ),
      ),
    );
  }
}