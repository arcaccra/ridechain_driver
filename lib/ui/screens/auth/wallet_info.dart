import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/data/locator.dart';
import 'package:ridechain_driiver/services/dialog_service.dart';
import 'package:ridechain_driiver/ui/screens/auth/auth_widgets/scanning_widget.dart';
import 'package:ridechain_driiver/ui/screens/auth/verification_complete_screen.dart';
import 'package:get/get.dart';

import '../../../core/core_constants/colors.dart';
import '../../../providers/auth_provider.dart';
import '../../shared_widgets/loader.dart';

class WalletInfo extends StatefulWidget {
  const WalletInfo({super.key});

  @override
  State<WalletInfo> createState() => _WalletInfoState();
}

class _WalletInfoState extends State<WalletInfo> {
  AuthVm? authVm;
  final _globalKey = GlobalKey<FormState>();
  final _walletCtrl = TextEditingController();
  MobileScannerController? scannerController;

  @override
  void initState() {
    authVm = context.read<AuthVm>();
    super.initState();
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void didChangeDependencies() {
    setState(() {
      _walletCtrl.text = authVm?.walletAddress ?? "";
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthVm>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: _globalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(16.h),
                  // Top row: back + step counter
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
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
                        const Spacer(),
                        Text(
                          '6/6',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step label row
                        Row(
                          children: [
                            Text(
                              'VERIFICATION · STEP 3 OF 4',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.purple,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Wallet',
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        Gap(8.h),
                        // 6-segment progress bar (all 6 filled)
                        Row(
                          children: List.generate(
                            6,
                            (i) => Expanded(
                              child: Container(
                                height: 4.h,
                                margin: EdgeInsets.only(right: i < 5 ? 4.w : 0),
                                decoration: BoxDecoration(
                                  color: AppColors.purple,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Gap(20.h),
                        Text(
                          'Cardano wallet',
                          style: TextStyle(
                            fontFamily: 'BeauSans',
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        Gap(6.h),
                        Text(
                          "Enter the wallet address where you'll receive your ADA earnings.",
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                        ),
                        Gap(20.h),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Wallet address label
                          Text(
                            'Wallet address',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Gap(8.h),
                          // Multi-line wallet text field
                          TextFormField(
                            controller: _walletCtrl,
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: "Enter your Cardano wallet address",
                              hintStyle: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[400],
                              ),
                              prefixIcon: Icon(
                                Icons.account_balance_wallet_outlined,
                                color: AppColors.purple,
                                size: 20.w,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  locator<DialogService>().showCustomModal(
                                    context: context,
                                    customModal: ScanningWidget(
                                      mobileScannerController: scannerController!,
                                      onCapture: (barcodeCapture) {
                                        setState(() {
                                          _walletCtrl.text =
                                              barcodeCapture.barcodes.first.displayValue ??
                                                  "";
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.qr_code_2_outlined,
                                  color: AppColors.purple,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: AppColors.purple,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide:
                                    const BorderSide(color: Colors.red, width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'The wallet number must not be empty';
                              }
                              return null;
                            },
                          ),
                          Gap(16.h),
                          // Warning box
                          Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 18.w,
                                  color: AppColors.purple,
                                ),
                                Gap(8.w),
                                Expanded(
                                  child: Text(
                                    "Double-check this address. ADA payments are sent on the Cardano blockchain and cannot be reversed.",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.purple,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(12.h),
                          // Paste from clipboard link
                          GestureDetector(
                            onTap: () async {
                              final data = await Clipboard.getData('text/plain');
                              if (data?.text != null) {
                                setState(() => _walletCtrl.text = data!.text!);
                              }
                            },
                            child: Text(
                              'Paste from clipboard',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.purple,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.purple,
                              ),
                            ),
                          ),
                          Gap(80.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Finish button
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 24.h,
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: authVm.isLoading
                      ? null
                      : () async {
                          if (_globalKey.currentState!.validate()) {
                            final wallet = _walletCtrl.text.trim();
                            Map<String, dynamic> walletMap = {'address': wallet};
                            await authVm.updateWalletAddress(walletMap);
                            if (mounted) {
                              Get.offAll(() => const VerificationCompleteScreen());
                            }
                          }
                        },
                  icon: authVm.isLoading
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.check, color: Colors.white, size: 18.w),
                  label: Text(
                    'Finish verification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            if (authVm.isLoading) const Loader(),
          ],
        ),
      ),
    );
  }
}
