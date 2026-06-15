import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/core_constants/colors.dart';
import '../../app/theme.dart';
import '../../services/dialog_service.dart';
import 'dialog_buttons.dart';

class CustomAlertDialog extends StatelessWidget {
  final AlertDialogType type;
  final String? title;
  final String message;
  final String? okayText;
  final String? cancelText;
  final bool? showCancelBtn;
  final bool? showOkayBtn;
  final bool? showTitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onOkayBtnTap;
  final VoidCallback? onCancelBtnTap;

  const CustomAlertDialog({
    Key? key,
    required this.type,
    this.title,
    required this.message,
    this.okayText,
    this.cancelText,
    this.showTitle,
    this.showCancelBtn,
    this.showOkayBtn,
    this.icon,
    this.iconColor,
    this.onOkayBtnTap,
    this.onCancelBtnTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width  = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final title = Text(
      _chooseTitle(),
      textAlign: TextAlign.center,
      style: AppThemes.getCustomTextStyle(
        fontFamily: "Inter",
        fontSize: 18,
        weight: FontWeight.w700,
        color: AppColors.primaryColor
      ),
      textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false),
      softWrap: false,
    );

    final content = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //SizedBox(height: showTitle! ? 16.h : 0),
          //showTitle! ? title : Container(),
          SizedBox(height: 16 ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppThemes.getCustomTextStyle(
                fontFamily: "Inter",
                fontSize: 16,
                weight: FontWeight.w500,
                color: AppColors.primaryColor
            ),
            textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false),
            softWrap: true,
          )
        ],
      ),
    );

    final buttons = Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.only(bottom: 12.h, top: 16.h),
      width: 0.6.sw,
      child: DialogButtons(
        okayText: okayText!,
        cancelText: cancelText!,
        onOkayButtonPressed:
        onOkayBtnTap != null ? onOkayBtnTap! : ()=> pop(context),
        onCancelButtonPressed:
        onCancelBtnTap != null ? onCancelBtnTap! : () => pop(context),
        showCancelBtn: showCancelBtn!,
        showOkayBtn: showOkayBtn!,
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r), color: Colors.transparent
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //top,
            content,
            // Utils.verticalSpacer(),
            buttons,
          ],
        ),
      ),
    );
  }

  Color _chooseColor() {
    if (iconColor == null) {
      if (type == AlertDialogType.success) {
        return Colors.green;
      } else if (type == AlertDialogType.error) {
        return Colors.red;
      } else {
        return Colors.orange;
      }
    } else {
      return iconColor!;
    }
  }

  String _chooseTitle() {
    if (title == null) {
      if (type == AlertDialogType.success) {
        return "Success";
      } else if (type == AlertDialogType.error) {
        return "Error!";
      } else if (type == AlertDialogType.confirm) {
        return "Confirm";
      } else {
        return "Warning";
      }
    } else {
      return title!;
    }
  }


  void pop(context) {
    Navigator.of(context).pop();
  }
}