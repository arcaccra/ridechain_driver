import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../core/core_constants/colors.dart';
import '../data/models/api_response.dart';
import '../ui/shared_widgets/custom_alert_dialog.dart';

/// Global messenger key so snackbars can be shown from anywhere (services,
/// providers) without a BuildContext and without depending on GetX's overlay,
/// which is unreliable across route transitions. Wired into GetMaterialApp.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

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
  //
  // Deferred to the next frame so it survives navigation: callers frequently
  // show a snackbar and then immediately `Get.offAll(...)`, which tears down the
  // overlay the snackbar would attach to. Scheduling it post-frame lets it bind
  // to the destination route's overlay instead, so it reliably shows after an
  // API call completes.
  void showSnackBar(String title, String message, {bool isError = false}) {
    final bg = isError ? const Color(0xFFDC2626) : AppColors.purple;
    // Deferred to the next frame so it is always safe to call — including from
    // initState/build and immediately before navigation — without hitting
    // "showSnackBar() cannot be called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = rootScaffoldMessengerKey.currentState;
      if (messenger == null) return;
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: AppColors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppThemes.getCustomTextStyle(
                        fontFamily: "Inter",
                        fontSize: 15,
                        weight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: AppThemes.getCustomTextStyle(
                        fontFamily: "Inter",
                        fontSize: 13,
                        weight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }



}