import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'dart:ui';

import '../../core/core_constants/colors.dart';

class NavItem extends StatelessWidget {
  final String navData;
  final String navLabel;
  final bool isProfile;
  final Color itemColor;
  const NavItem(
      {super.key,
        required this.navData,
        required this.navLabel,
        this.isProfile = false,
        required this.itemColor});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              navData,
              height: 25,
              width: 25,
              colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
            ),
            Gap(8.h),
          ],
        ));
  }
}