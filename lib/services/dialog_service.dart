import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme.dart';
import '../core/core_constants/colors.dart';
import '../data/models/api_response.dart';
import '../ui/shared_widgets/custom_alert_dialog.dart';

enum AlertDialogType { success, error, warning, confirm, custom }

class DialogService {
  Future<bool?>? showAlertDialog({
    required BuildContext context,
    required String message,
    required AlertDialogType type,
    String? title,
    String? okayText = "OK",
    String? cancelText = "CANCEL",
    bool? showCancelBtn = false,
    bool? showOkayBtn = true,
    bool? showTitle = false,
    VoidCallback? onOkayBtnTap,
    VoidCallback? onCancelBtnTap,
    bool? barrierDismissible = true,
  }) {
    return showGeneralDialog(
        barrierDismissible: barrierDismissible!,
        context: context,
        pageBuilder: (ctx, a1, a2) {
          return Container();
        },
        barrierColor: AppColors.primaryColor.withValues(alpha: 0.3),
        barrierLabel: "response dialog barrier",
        transitionDuration: const Duration(milliseconds: 400),
        transitionBuilder: (context, a1, a2, child) {
          var curve = Curves.easeInOut.transform(a1.value);
          return Transform.scale(
              scale: curve,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: CustomAlertDialog(
                  message: message,
                  type: type,
                  title: title,
                  okayText: okayText,
                  cancelText: cancelText,
                  showCancelBtn: showCancelBtn,
                  showOkayBtn: showOkayBtn,
                  showTitle: showTitle,
                  onOkayBtnTap: onOkayBtnTap,
                  onCancelBtnTap: onCancelBtnTap,
                ),
              ));
        });
  }

  bool showResponseDialog({
    required BuildContext context,
    required ApiResponse apiResponse,
    bool? disableSuccess = false,
    String? message,
    VoidCallback? onOkayBtnTap,
    bool? barrierDismissible = true,
  }) {
    if (apiResponse.allGood!) {
      if (!disableSuccess!) {
        showAlertDialog(
          context: context,
          message: message ?? apiResponse.message!,
          type: AlertDialogType.success,
          onOkayBtnTap: onOkayBtnTap,
          barrierDismissible: barrierDismissible,
        );
      }
    } else {
      showAlertDialog(
        context: context,
        message: apiResponse.message!,
        type: AlertDialogType.error,
        onOkayBtnTap: onOkayBtnTap,
        barrierDismissible: barrierDismissible,
      );

      return false;
    }
    return true;
  }

  Future<T?>? showCustomDialog<T>({
    required BuildContext context,
    required Widget customDialog,
    bool? barrierDismissible = true,
    bool? automaticallyClosed = false,
  }) {
    return showGeneralDialog(
        context: context,
        pageBuilder: (ctx, a1, a2) {
          return Container();
        },
        barrierDismissible: barrierDismissible!,
        barrierColor: AppColors.primaryColor.withOpacity(0.3),
        barrierLabel: "dialog barrier",
        transitionDuration: const Duration(milliseconds: 400),
        transitionBuilder: (context, a1, a2, child) {
          var curve = Curves.easeInOut.transform(a1.value);
          Future.delayed(const Duration(seconds: 2)).then((value) {
            if (automaticallyClosed!) {
              Navigator.pop(context);
            }
          });
          return Transform.scale(scale: curve, child: customDialog);
        });
  }

  Future<T?>? showCustomModal<T>({
    required BuildContext context,
    required Widget customModal,
    Color? backgroundColor = Colors.transparent,
    Color? barrierColor = Colors.transparent,
    AnimationController? animationController,
    bool isDismissible = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet(
        backgroundColor: backgroundColor,
        isScrollControlled: isScrollControlled,
        barrierColor: barrierColor,
        elevation: 0.0,
        transitionAnimationController: animationController,
        useRootNavigator: true,
        isDismissible: isDismissible,
        context: context,
        builder: (context) {
          return customModal;
        });
  }


  //snackbar for getting dialogs
  showSnackBar(String title, String message) {
    return Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.purple,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      snackStyle: SnackStyle.FLOATING,
      overlayBlur: 10,
      overlayColor: AppColors.purple.withOpacity(0.2),
      titleText: Text(
        title,
        style: AppThemes.getCustomTextStyle(
          fontFamily: "Inter",
          fontSize: 16,
          weight: FontWeight.w700,
          color: AppColors.white
        )
      ),
      messageText: Text(
        message,
        style: AppThemes.getCustomTextStyle(
            fontFamily: "Inter",
            fontSize: 14,
            weight: FontWeight.w400,
            color: AppColors.white
        )
      ),
    );
  }



}