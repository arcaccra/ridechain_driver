import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/ui/screens/auth/password_screen.dart';
import '../../../core/core_constants/colors.dart';
import '../../../data/locator.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/dialog_service.dart';
import 'auth_widgets/otp_fields.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  Timer? _timer;
  int _countdown = 30;
  bool _isActive = true;
  bool _canRestart = false;
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  AuthVm? authVm;

  @override
  void initState() {
    authVm = context.read<AuthVm>();
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 30;
      _isActive = true;
      _canRestart = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isActive = false;
          _canRestart = true;
        });
      }
    });
  }

  void _restartCountdown() {
    _timer?.cancel();
    _startCountdown();
    _resendOTP();
  }

  void _resendOTP() async {
    print('Resending OTP...');
    authVm!.resendOTP(authVm?.body['phone_number']);
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    authVm = context.watch<AuthVm>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(16.h),
                  // Back button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[100],
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.black),
                    ),
                  ),
                  Gap(20.h),
                  // Phone icon badge
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Icon(Icons.phone_outlined,
                          color: AppColors.purple, size: 28.w),
                    ),
                  ),
                  Gap(20.h),
                  Text(
                    'Verify your number',
                    style: TextStyle(
                      fontFamily: 'BeauSans',
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    'We sent a 6-digit code to',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                  ),
                  Text(
                    authVm?.body['phone_number'] ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Gap(32.h),
                  // OTP input
                  Form(
                    key: _globalKey,
                    child: OtpFields(otpCtrl: _otpController),
                  ),
                  Gap(24.h),
                  // Resend row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't get the code?  ",
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                      ),
                      GestureDetector(
                        onTap: _canRestart ? _restartCountdown : null,
                        child: Text(
                          _isActive
                              ? 'Resend in ${_formatTime(_countdown)}'
                              : 'Resend',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: _isActive
                                ? Colors.grey[500]
                                : AppColors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bottom Verify button
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 24.h,
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: authVm?.isLoading == true
                      ? null
                      : () async {
                          if (_globalKey.currentState!.validate()) {
                            var code = _otpController.text.trim();
                            final verified = await authVm!.verifyOTP(code);
                            if (verified && mounted) {
                              Get.to(() => const PasswordScreen(),
                                  transition: Transition.leftToRight);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r)),
                    elevation: 0,
                  ),
                  child: authVm?.isLoading == true
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : Text(
                          'Verify',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
